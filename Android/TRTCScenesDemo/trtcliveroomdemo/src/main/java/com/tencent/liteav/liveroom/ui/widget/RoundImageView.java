package com.tencent.liteav.liveroom.ui.widget;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.widget.ImageView;

import com.tencent.liteav.liveroom.R;

@SuppressLint("AppCompatCustomView")
public class RoundImageView extends ImageView {
    public static final  int CIRCLE         = 0;
    public static final  int FILLET         = 1;
    private static final int DEFAULT_RADIUS = 8;

    private int mShape = CIRCLE;
    private int mCoverColor;
    private int mRadius;

    private Paint mPaint;
    private Path  mPath;

    public RoundImageView(Context context) {
        super(context);
        init(null);
    }

    public RoundImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public RoundImageView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        TypedArray ta = getContext().obtainStyledAttributes(attrs, R.styleable.TRTCLiveRoomRoundImageView);
        mShape = ta.getInt(R.styleable.TRTCLiveRoomRoundImageView_shape, CIRCLE);
        mCoverColor = ta.getColor(R.styleable.TRTCLiveRoomRoundImageView_cover_color, Color.WHITE);
        mRadius = ta.getDimensionPixelOffset(R.styleable.TRTCLiveRoomRoundImageView_radius, (int) TypedValue
                .applyDimension(TypedValue.COMPLEX_UNIT_DIP, DEFAULT_RADIUS, getResources().getDisplayMetrics()));
        ta.recycle();

        mPaint = new Paint();
        mPaint.setColor(mCoverColor);
        mPaint.setAntiAlias(true);
        mPath = new Path();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        switch (mShape) {
            case CIRCLE:
                drawCircleCover(canvas);
                break;
            case FILLET:
                drawFilletCover(canvas);
                break;
        }
    }

    private void drawCircleCover(Canvas canvas) {
        int radius = Math.min(getWidth(), getHeight()) / 2;
        mPath.addRect(0, 0, getWidth(), getHeight(), Path.Direction.CCW);
        mPath.addCircle(getWidth() / 2, getHeight() / 2, radius, Path.Direction.CW);
        canvas.drawPath(mPath, mPaint);
    }

    private void drawFilletCover(Canvas canvas) {
        RectF rectf = new RectF(0, 0, getWidth(), getHeight());
        mPath.addRect(rectf, Path.Direction.CCW);
        mPath.addRoundRect(rectf, mRadius, mRadius, Path.Direction.CW);
        canvas.drawPath(mPath, mPaint);
    }

    public void setShape(int shape) {
        this.mShape = shape;
        invalidate();
    }

    public void setCoverColor(int coverColor) {
        this.mCoverColor = coverColor;
        invalidate();
    }

    public void setRadius(int radius) {
        this.mRadius = radius;
        invalidate();
    }
}
