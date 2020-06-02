#import "UIButton+Glossy.h"


typedef struct
{
	float color[4];
	float caustic[4];
	float expCoefficient;
	float expOffset;
	float expScale;
	float initialWhite;
	float finalWhite;
} GlossyParams;


static void rgb_to_hsv(const float* inputComponents, float* outputComponents)
{
	// Unpack r,g,b for conciseness
	double r = inputComponents[0];
	double g = inputComponents[1];
	double b = inputComponents[2];
	
	// Rather tediously, find the min and max values, and the max component
	char max_elt = 'r';
	double max_val=r, min_val=r;
	if (g > max_val)
	{
		max_val = g;
		max_elt = 'g';
	}
	if (b > max_val)
	{
		max_val = b;
		max_elt = 'b';
	}
	if (g < min_val) min_val = g;
	if (b < min_val) min_val = b;

	// Cached
	double max_minus_min = max_val - min_val;
	
	// Calculate h as a degree (0 - 360) measurement
	double h = 0;
	switch (max_elt)
	{
		case 'r':
			h = !max_minus_min?0:60*(g-b)/max_minus_min + 360;
			if (h >= 360) h -= 360;
			break;
		case 'g':
			h = !max_minus_min?0:60*(b-r)/max_minus_min + 120;
			break;
		case 'b':
		default:
			h = !max_minus_min?0:60*(r-g)/max_minus_min + 240;
			break;
	}
	
	// Normalize h
	h /= 360;
	
	// Calculate s
	double s = 0;
	if (max_val) s = max_minus_min/max_val;
	
	// Store HSV triple; v is just the max
	outputComponents[0] = h;
	outputComponents[1] = s;
	outputComponents[2] = max_val;
}


static float perceptualGlossFractionForColor(float* inputComponents)
{
    static const float REFLECTION_SCALE_NUMBER	= 0.2;
    static const float NTSC_RED_FRACTION		= 0.299;
    static const float NTSC_GREEN_FRACTION		= 0.587;
    static const float NTSC_BLUE_FRACTION		= 0.114;
	
    float glossScale =	NTSC_RED_FRACTION * inputComponents[0] +
						NTSC_GREEN_FRACTION * inputComponents[1] +
						NTSC_BLUE_FRACTION * inputComponents[2];

    return pow(glossScale, REFLECTION_SCALE_NUMBER);
}


static void perceptualCausticColorForColor(float* inputComponents, float* outputComponents)
{
  static const float CAUSTIC_FRACTION				= 0.35;
    static const float COSINE_ANGLE_SCALE			= 1.4;
    static const float MIN_RED_THRESHOLD			= 0.95;
    static const float MAX_BLUE_THRESHOLD			= 0.7;
    static const float GRAYSCALE_CAUSTIC_SATURATION	= 0.2;

	float temp[3];
	
	rgb_to_hsv(inputComponents, temp);
    float hue=temp[0], saturation=temp[1], brightness=temp[2];

	rgb_to_hsv(CGColorGetComponents([[UIColor yellowColor] CGColor]), temp);
    float targetHue=temp[0],  targetBrightness=temp[2];
    
    if (saturation < 1e-3)
    {
        hue = targetHue;
        saturation = GRAYSCALE_CAUSTIC_SATURATION;
    }
	
    if (hue > MIN_RED_THRESHOLD)
    {
        hue -= 1.0;
    }
    else if (hue > MAX_BLUE_THRESHOLD)
    {
		rgb_to_hsv(CGColorGetComponents([[UIColor magentaColor] CGColor]), temp);
		targetHue=temp[0],  targetBrightness=temp[2];
    }
	
    float scaledCaustic = CAUSTIC_FRACTION * 0.5 * (1.0 + cos(COSINE_ANGLE_SCALE * M_PI * (hue - targetHue)));
	UIColor* caustic = [UIColor colorWithHue:hue * (1.0 - scaledCaustic) + targetHue * scaledCaustic
								  saturation:saturation
								  brightness:brightness * (1.0 - scaledCaustic) + targetBrightness * scaledCaustic
									   alpha:inputComponents[3]];
	
	const CGFloat* causticComponents = CGColorGetComponents([caustic CGColor]);
	for (int j = 3; j >= 0; j--) outputComponents[j] = causticComponents[j];
}


static void calc_glossy_color(void* info, const float* in, float* out)
{
	GlossyParams*	params		= (GlossyParams*) info;
	float			progress	= *in;
	
    if (progress < 0.5)
    {
        progress = progress * 2.0;
		
        progress = 1.0 - params->expScale * (expf(progress * -params->expCoefficient) - params->expOffset);
		
        float currentWhite = progress * (params->finalWhite - params->initialWhite) + params->initialWhite;
        
        out[0] = params->color[0] * (1.0 - currentWhite) + currentWhite;
        out[1] = params->color[1] * (1.0 - currentWhite) + currentWhite;
        out[2] = params->color[2] * (1.0 - currentWhite) + currentWhite;
        out[3] = params->color[3] * (1.0 - currentWhite) + currentWhite;
    }
    else
    {
        progress = (progress - 0.5) * 2.0;
		
        progress = params->expScale * (expf((1.0 - progress) * -params->expCoefficient) - params->expOffset);
		
        out[0] = params->color[0] * (1.0 - progress) + params->caustic[0] * progress;
        out[1] = params->color[1] * (1.0 - progress) + params->caustic[1] * progress;
        out[2] = params->color[2] * (1.0 - progress) + params->caustic[2] * progress;
        out[3] = params->color[3] * (1.0 - progress) + params->caustic[3] * progress;
    }
}


@implementation UIButton (Glossy)

+ (void)setPathToRoundedRect:(CGRect)rect forInset:(NSUInteger)inset inContext:(CGContextRef)context
{
	// Experimentally determined
	static const NSUInteger cornerRadius = 8;

	// Unpack size for compactness, find minimum dimension
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	CGFloat m = w<h?w:h;
	
	// Special case: Degenerate rectangles abort this method
	if (m <= 0) return;
	
	// Bounds
	CGFloat b = rect.origin.y;
	CGFloat t = b + h;
	CGFloat l = rect.origin.x;
	CGFloat r = l + w;

	// Adjust radius for inset, and limit it to 1/2 of the rectangle's shortest axis
	CGFloat d = (inset<cornerRadius)?(cornerRadius-inset):0;
	d = (d>0.5*m)?(0.5*m):d;
	
	// Define a CW path in the CG co-ordinate system (origin at LL)
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, (l+r)/2, t);		// Begin at TDC
	CGContextAddArcToPoint(context, r, t, r, b, d);	// UR corner
	CGContextAddArcToPoint(context, r, b, l, b, d);	// LR corner
	CGContextAddArcToPoint(context, l, b, l, t, d);	// LL corner
	CGContextAddArcToPoint(context, l, t, r, t, d);	// UL corner
	CGContextClosePath(context);					// End at TDC
}


+ (void)drawGlossyRect:(CGRect)rect withColor:(UIColor*)color inContext:(CGContextRef)context
{
	static const float EXP_COEFFICIENT	= 4.0;
	static const float REFLECTION_MAX	= 0.80;
	static const float REFLECTION_MIN	= 0.20;

	static const CGFloat normalizedRanges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
	static const CGFunctionCallbacks callbacks = {0, calc_glossy_color, NULL};

	// Prepare gradient configuration struct
	GlossyParams params;
	// Set the base color
	const CGFloat* colorComponents = CGColorGetComponents([color CGColor]);
	int j = (int) CGColorGetNumberOfComponents([color CGColor]);
	if (j == 4)
	{
		for (j--; j >= 0; j--) params.color[j] = colorComponents[j];
	}
	else if (j == 2)
	{
		for (; j >= 0; j--) params.color[j] = colorComponents[0];
		params.color[3] = colorComponents[1];
	}
	else
	{
		// I dunno
		return;
	}
	// Set the caustic color
	perceptualCausticColorForColor(params.color, params.caustic);
	// Set the exponent curve parameters
	params.expCoefficient	= EXP_COEFFICIENT;
	params.expOffset		= expf(-params.expCoefficient);
	params.expScale			= 1.0/(1.0 - params.expOffset);
	// Set the highlight intensities
	float glossScale		= perceptualGlossFractionForColor(params.color);
	params.initialWhite		= glossScale * REFLECTION_MAX;
	params.finalWhite		= glossScale * REFLECTION_MIN;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFunctionRef function = CGFunctionCreate(&params, 1, normalizedRanges, 4, normalizedRanges, &callbacks);
	
	CGPoint sp = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGPoint ep = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGShadingRef shader = CGShadingCreateAxial(colorSpace, sp, ep, function, NO, NO);

	CGFunctionRelease(function);
	CGColorSpaceRelease(colorSpace);

	CGContextDrawShading(context, shader);
	CGShadingRelease(shader);
}


+ (void)setBackgroundToGlossyButton:(UIButton*)button forColor:(UIColor*)color withBorder:(BOOL)border forState:(UIControlState)state{
	static const float MIN_SIZE = 4;
	
	// Get and check size
	CGSize size = button.frame.size;
	if ((size.width < MIN_SIZE) || (size.height < MIN_SIZE)) return;
	
	// Create and get a pointer to context
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Convert co-ordinate system to Cocoa's (origin in UL, not LL)
	CGContextTranslateCTM(context, 0, size.height);
	CGContextConcatCTM(context, CGAffineTransformMakeScale(1, -1));
	
	// Set stroke color
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:159.0/255 green:159.0/255 blue:159.0/255 alpha:1] CGColor]);
	
	// Draw background image
	if (border)
	{
		// Draw border
		[UIButton setPathToRoundedRect:CGRectMake(0.5, 0.5, size.width-1, size.height-1) forInset:0 inContext:context];
		CGContextStrokePath(context);
		
		// Prepare clipping region
		[UIButton setPathToRoundedRect:CGRectMake(1, 1, size.width-2, size.height-2) forInset:1 inContext:context];
		CGContextClip(context);

		// Draw glossy image
		[UIButton drawGlossyRect:CGRectMake(1, 1, size.width-2, size.height-2) withColor:color inContext:context];
	}
	else
	{
		// Prepare clipping region
		[UIButton setPathToRoundedRect:CGRectMake(0, 0, size.width, size.height) forInset:0 inContext:context];
		CGContextClip(context);
		
		// Draw glossy image
		[UIButton drawGlossyRect:CGRectMake(0, 0, size.width, size.height) withColor:color inContext:context];
	}

	// Create and assign image
	[button setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:state];
	
	// Release image context
	UIGraphicsEndImageContext();
}



@end
