package com.tencent.liteav.demo.beauty;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.FrameLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Module:   BeautyPanel
 * <p>
 * Function: 美颜的控制 View 控件
 */
public class BeautyPanel extends FrameLayout implements SeekBar.OnSeekBarChangeListener, View.OnClickListener {
    private final String TAG = "BeautyPanel";
    // 美容
    public static final int ITEM_TYPE_BEAUTY = 0;
    // 滤镜
    public static final int ITEM_TYPE_FILTTER = 1;
    // 动效贴纸
    public static final int ITEM_TYPE_MOTION = 2;
    // 美妆
    public static final int ITEM_TYPE_BEAUTY_FACE = 3;
    // 手势
    public static final int ITEM_TYPE_GESUTRE = 4;
    // 抠背
    public static final int ITEM_TYPE_KOUBEI = 5;
    // 绿幕
    public static final int ITEM_TYPE_GREEN = 6;
    // 美体
    public static final int ITEM_TYPE_BEAUTY_BODY = 7;

    private int mSencodGradleType = ITEM_TYPE_BEAUTY;
    private int mThirdGradleIndex = 0;
    private int[][] mSzSeekBarValue = null;
    private int[] mSzSecondGradleIndex = new int[16];
    private TextView mSeekBarValue;
    private SeekBar mSeekbar;
    private CustomProgressDialog mCustomProgressDialog;
    private final int mFilterBasicLevel = 5;

    private final int mBeautyBasicLevel = 4;
    private final int mWhiteBasicLevel = 1;
    private final int mRuddyBasicLevel = 0;

    private Context mContext;
    public static final int BEAUTYPARAM_BEAUTY_STYLE_SMOOTH = 0; // 光滑
    public static final int BEAUTYPARAM_BEAUTY_STYLE_NATURAL = 1; // 自然
    public static final int BEAUTYPARAM_BEAUTY_STYLE_HAZY = 2; // 天天P图(朦胧)
    private ArrayAdapter<String> mFirstGradleAdapter;
    private ArrayList<BeautyData> mFilterBeautyDataList;
    private ArrayList<BeautyData> mBeautyDataList;
    private ArrayList<BeautyData> mGreenScreenDataList;
    private ArrayList<BeautyData> mKoubeiDataList;
    private ArrayList<BeautyData> mFaceBeautyDataList;
    private ArrayList<BeautyData> mGestureDataLit;
    private IconTextAdapter mItemAdapter;

    private String[] mBeautyStyleString;
    private String[] mFilterTypeString;

    private ArrayList<String> mFirstGradleArrayString = new ArrayList<String>();
    private List<MotionData> motionDataList = new ArrayList<>();
    private List<MotionData> motionDataKoubeiList = new ArrayList<>();
    private List<MotionData> motionBeautyFaceList = new ArrayList<>();
    private List<MotionData> motionGestureList = new ArrayList<>();

    private TCHorizontalScrollView mFirstGradlePicker;
    private TCHorizontalScrollView mSecondGradlePicker;
    private SharedPreferences mPrefs;
    private ArrayList<BeautyData> mMotionDataList;
    private MotionData motionData;
    private ArrayList<BeautyData> beautyDataList;
    private int mTextColorPrimary;

    private IBeautyKit mProxy;
    private BeautyParams mBeautyParams;

    public BeautyPanel(Context context, AttributeSet attrs) {
        super(context, attrs);

        mContext = context;
        mBeautyParams = new BeautyParams();
        mBeautyStyleString = context.getResources().getStringArray(R.array.beauty_category);
        mFilterTypeString = context.getResources().getStringArray(R.array.filter_type);

        mPrefs = PreferenceManager.getDefaultSharedPreferences(mContext);
        LayoutInflater.from(context).inflate(R.layout.beauty_panel, this);
        initView();
    }

    public void setProxy(IBeautyKit proxy) {
        mProxy = proxy;
    }

    private void initView() {
        mTextColorPrimary = UIAttributeUtil.getColorRes(mContext, R.attr.beautyPanelColorPrimary, R.color.colorRed);

        mSeekbar = (SeekBar) findViewById(R.id.seekbarThird);
        mSeekbar.setOnSeekBarChangeListener(this);
                
        mFirstGradlePicker = (TCHorizontalScrollView) findViewById(R.id.horizontalPickerViewFirst);
        mSecondGradlePicker = (TCHorizontalScrollView) findViewById(R.id.horizontalPickerViewSecond);
        mSeekBarValue = (TextView) findViewById(R.id.tvSeekbarValue);
        mSeekBarValue.setTextColor(mTextColorPrimary);

        mItemAdapter = new IconTextAdapter(mContext);
        mItemAdapter.setTextColor(mTextColorPrimary);
        initBeautyData();
        initFilterData();
        initMotionData();
        initMotionLink();
        initGreenScreenData();
        initKoubeiData();
        initFaceBeautyData();
        initGestureData();
        setFirstPickerType();
    }

    private void initMotionLink() {
        motionDataList.add(new MotionData("none", "无动效", "", ""));
        motionDataList.add(new MotionData("video_boom", "Boom", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_boomAndroid.zip", mPrefs.getString("video_boom", "")));
        motionDataList.add(new MotionData("video_nihongshu", "霓虹鼠", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_nihongshuAndroid.zip", mPrefs.getString("video_nihongshu", "")));
        motionDataList.add(new MotionData("video_fengkuangdacall", "疯狂打call", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_fengkuangdacallAndroid.zip", mPrefs.getString("video_fengkuangdacall", "")));
        motionDataList.add(new MotionData("video_Qxingzuo", "Q星座", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_QxingzuoAndroid.zip", mPrefs.getString("video_Qxingzuo", "")));
        motionDataList.add(new MotionData("video_caidai", "彩色丝带", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_caidaiAndroid.zip", mPrefs.getString("video_caidai", "")));
        motionDataList.add(new MotionData("video_liuhaifadai", "刘海发带", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_liuhaifadaiAndroid.zip", mPrefs.getString("video_liuhaifadai", "")));
        motionDataList.add(new MotionData("video_purplecat", "紫色小猫", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_purplecatAndroid.zip", mPrefs.getString("video_purplecat", "")));
        motionDataList.add(new MotionData("video_huaxianzi", "花仙子", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_huaxianziAndroid.zip", mPrefs.getString("video_huaxianzi", "")));
        motionDataList.add(new MotionData("video_baby_agetest", "小公举", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_baby_agetestAndroid.zip", mPrefs.getString("video_baby_agetest", "")));
        motionDataKoubeiList.add(new MotionData("none", "无", "", ""));
        motionDataKoubeiList.add(new MotionData("video_xiaofu", "校服", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_xiaofuAndroid.zip", mPrefs.getString("video_xiaofu", "")));
        motionDataList.add(new MotionData("video_starear", "星耳", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_starearAndroid.zip", mPrefs.getString("video_starear", "")));
        motionDataList.add(new MotionData("video_lianpu", "变脸", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_lianpuAndroid.zip", mPrefs.getString("video_lianpu", "")));

        // 美妆
        motionBeautyFaceList.add(new MotionData("none", "无", "", ""));
        motionBeautyFaceList.add(new MotionData("video_cherries", "樱桃", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_cherriesAndroid.zip", mPrefs.getString("video_cherries", "")));
        motionBeautyFaceList.add(new MotionData("video_haiyang2", "海洋", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_haiyang2Android.zip", mPrefs.getString("video_haiyang2", "")));
        motionBeautyFaceList.add(new MotionData("video_fenfenxia_square", "粉粉霞", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_fenfenxia_squareAndroid.zip", mPrefs.getString("video_fenfenxia_square", "")));
        motionBeautyFaceList.add(new MotionData("video_guajiezhuang", "寡姐妆", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_guajiezhuangAndroid.zip", mPrefs.getString("video_guajiezhuang", "")));
        motionBeautyFaceList.add(new MotionData("video_qixichun", "七夕唇印", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_qixichunAndroid.zip", mPrefs.getString("video_qixichun", "")));
        motionBeautyFaceList.add(new MotionData("video_gufengzhuang", "古风妆", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_gufengzhuangAndroid.zip", mPrefs.getString("video_gufengzhuang", "")));
        motionBeautyFaceList.add(new MotionData("video_dxxiaochounv", "小丑女", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_dxxiaochounvAndroid.zip", mPrefs.getString("video_dxxiaochounv", "")));
        motionBeautyFaceList.add(new MotionData("video_remix1", "混合妆", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_remix1Android.zip", mPrefs.getString("video_remix1", "")));
        motionBeautyFaceList.add(new MotionData("video_yuansufugu", "原宿复古", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/180/video_yuansufugu.zip", mPrefs.getString("video_yuansufugu", "")));

        // 手势
        motionGestureList.add(new MotionData("none", "无", "", ""));
        motionGestureList.add(new MotionData("video_pikachu", "皮卡丘", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/181/video_pikachu.zip", mPrefs.getString("video_pikachu", "")));
        motionGestureList.add(new MotionData("video_liuxingyu", "流星雨", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_liuxingyuAndroid.zip", mPrefs.getString("video_liuxingyu", "")));
        motionGestureList.add(new MotionData("video_kongxue2", "控雪", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_kongxue2Android.zip", mPrefs.getString("video_kongxue2", "")));
        motionGestureList.add(new MotionData("video_dianshizhixing", "电视之星", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_dianshizhixingAndroid.zip", mPrefs.getString("video_dianshizhixing", "")));
        motionGestureList.add(new MotionData("video_bottle1", "瓶盖挑战", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/video_bottle1Android.zip", mPrefs.getString("video_bottle1", "")));
    }

    private void initMotionData() {
        mMotionDataList = new ArrayList<BeautyData>();
        mMotionDataList.add(new BeautyData(R.drawable.ic_effect_non, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_none)));
        mMotionDataList.add(new BeautyData(R.drawable.video_boom, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_boom)));
        mMotionDataList.add(new BeautyData(R.drawable.video_nihongshu, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_neon_mouse)));
        mMotionDataList.add(new BeautyData(R.drawable.video_fengkuangdacall, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_crazy_cheer_up)));
        mMotionDataList.add(new BeautyData(R.drawable.video_qxingzuo, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_Q_cancelonstellation)));
        mMotionDataList.add(new BeautyData(R.drawable.video_caidai, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_colored_ribbon)));
        mMotionDataList.add(new BeautyData(R.drawable.video_liuhaifadai, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_bands_hairband)));
        mMotionDataList.add(new BeautyData(R.drawable.video_purplecat, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_purple_kitten)));
        mMotionDataList.add(new BeautyData(R.drawable.video_huaxianzi, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_flower_faerie)));
        mMotionDataList.add(new BeautyData(R.drawable.video_baby_agetest, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_little_Princess)));
        mMotionDataList.add(new BeautyData(R.drawable.video_starear, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_star_ear)));
        mMotionDataList.add(new BeautyData(R.drawable.video_lianpu, getResources().getString(R.string.beauty_setting_pannel_dynamic_effect_change_face)));
        // TODO:眼镜狗，彩虹云
    }

    /**
     * 初始化美容数据
     */
    private void initBeautyData() {
        int beauty_smooth = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelSmoothIcon, R.drawable.ic_beauty_smooth);
        int beauty_natural = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelNaturalIcon, R.drawable.ic_beauty_natural);
        int beauty_pitu = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelPituIcon, R.drawable.ic_beauty_pitu);
        int beauty_white = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelWhiteIcon, R.drawable.ic_beauty_white);
        int beauty_ruddy = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelRuddyIcon, R.drawable.ic_beauty_ruddy);
        int beauty_bigeye = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelBigeyeIcon, R.drawable.ic_beauty_bigeye);
        int beauty_faceslim = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelFaceslimIcon, R.drawable.ic_beauty_faceslim);
        int beauty_facev = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelFacevIcon, R.drawable.ic_beauty_facev);
        int beauty_chin = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelChinIcon, R.drawable.ic_beauty_chin);
        int beauty_faceshort = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelFaceshortIcon, R.drawable.ic_beauty_faceshort);
        int beauty_noseslim = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelNoseslimIcon, R.drawable.ic_beauty_noseslim);
        int beauty_eyebright = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelEyeLightenIcon, R.drawable.ic_eye_bright);
        int beauty_toothwhite = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelToothWhiteIcon, R.drawable.ic_tooth_white);
        int beauty_pounchremove = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelPounchRemoveIcon, R.drawable.ic_pounch_remove);
        int beauty_wrinkles = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelWrinkleIcon, R.drawable.ic_wrinkles);
        int beauty_smileLines = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelSmileLinesRemoveIcon, R.drawable.ic_smilelines);
        int beauty_forehead = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelForeheadIcon, R.drawable.ic_forehead);
        int beauty_eyedistance = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelEyeDistanceIcon, R.drawable.ic_eye_distance);
        int beauty_eyeangle = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelEyeAngleIcon, R.drawable.ic_eye_angle);
        int beauty_mouthshape = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelMouthShapeIcon, R.drawable.ic_mouseshape);
        int beauty_nosewing = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelNoseWingIcon, R.drawable.ic_nose_wing);
        int beauty_noseposition = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelNosePositionIcon, R.drawable.ic_nose_position);
        int beauty_mousewidth = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelMouseWidthIcon, R.drawable.ic_mouse_width);
        int beauty_faceshape = UIAttributeUtil.getResResources(getContext(), R.attr.beautyPanelFaceShapeIcon, R.drawable.ic_faceshape);

        mBeautyDataList = new ArrayList<BeautyData>();
        mBeautyDataList.add(new BeautyData(beauty_smooth, getResources().getString(R.string.beauty_pannel_style_smooth)));
        mBeautyDataList.add(new BeautyData(beauty_natural, getResources().getString(R.string.beauty_pannel_style_natural)));
        mBeautyDataList.add(new BeautyData(beauty_pitu, getResources().getString(R.string.beauty_pannel_style_pitu)));
        mBeautyDataList.add(new BeautyData(beauty_white, getResources().getString(R.string.beauty_pannel_white)));
        mBeautyDataList.add(new BeautyData(beauty_ruddy, getResources().getString(R.string.beauty_pannel_ruddy)));
        mBeautyDataList.add(new BeautyData(beauty_bigeye, getResources().getString(R.string.beauty_pannel_bigeye)));
        mBeautyDataList.add(new BeautyData(beauty_faceslim, getResources().getString(R.string.beauty_pannel_faceslim)));
        mBeautyDataList.add(new BeautyData(beauty_facev, getResources().getString(R.string.beauty_pannel_facev)));
        mBeautyDataList.add(new BeautyData(beauty_chin, getResources().getString(R.string.beauty_pannel_chin)));
        mBeautyDataList.add(new BeautyData(beauty_faceshort, getResources().getString(R.string.beauty_pannel_faceshort)));
        mBeautyDataList.add(new BeautyData(beauty_noseslim, getResources().getString(R.string.beauty_pannel_noseslim)));
        mBeautyDataList.add(new BeautyData(beauty_eyebright, getResources().getString(R.string.beauty_pannel_eyelighten)));
        mBeautyDataList.add(new BeautyData(beauty_toothwhite, getResources().getString(R.string.beauty_pannel_toothwhite)));
        mBeautyDataList.add(new BeautyData(beauty_wrinkles, getResources().getString(R.string.beauty_pannel_wrinkleremove)));
        mBeautyDataList.add(new BeautyData(beauty_pounchremove, getResources().getString(R.string.beauty_pannel_pounchremove)));
        mBeautyDataList.add(new BeautyData(beauty_smileLines, getResources().getString(R.string.beauty_pannel_smilelinesremove)));
        mBeautyDataList.add(new BeautyData(beauty_forehead, getResources().getString(R.string.beauty_pannel_forehead)));
        mBeautyDataList.add(new BeautyData(beauty_eyedistance, getResources().getString(R.string.beauty_pannel_eyedistance)));
        mBeautyDataList.add(new BeautyData(beauty_eyeangle, getResources().getString(R.string.beauty_pannel_eyeangle)));
        mBeautyDataList.add(new BeautyData(beauty_mouthshape, getResources().getString(R.string.beauty_pannel_mouthshape)));
        mBeautyDataList.add(new BeautyData(beauty_nosewing, getResources().getString(R.string.beauty_pannel_nosewing)));
        mBeautyDataList.add(new BeautyData(beauty_noseposition, getResources().getString(R.string.beauty_pannel_noseposition)));
        mBeautyDataList.add(new BeautyData(beauty_mousewidth, getResources().getString(R.string.beauty_pannel_mousewidth)));
        mBeautyDataList.add(new BeautyData(beauty_faceshape, getResources().getString(R.string.beauty_pannel_faceshape)));
    }

    /**
     * 初始化滤镜数据
     */
    private void initFilterData() {
        mFilterBeautyDataList = new ArrayList<BeautyData>();
        mFilterBeautyDataList.add(new BeautyData(R.drawable.ic_effect_non, getResources().getString(R.string.beauty_setting_pannel_filter_none)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.biaozhun, getResources().getString(R.string.beauty_setting_pannel_filter_standard)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.yinghong, getResources().getString(R.string.beauty_setting_pannel_filter_cheery)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.yunshang, getResources().getString(R.string.beauty_setting_pannel_filter_cloud)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.chunzhen, getResources().getString(R.string.beauty_setting_pannel_filter_pure)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.bailan, getResources().getString(R.string.beauty_setting_pannel_filter_orchid)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.yuanqi, getResources().getString(R.string.beauty_setting_pannel_filter_vitality)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.chaotuo, getResources().getString(R.string.beauty_setting_pannel_filter_super)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.xiangfen, getResources().getString(R.string.beauty_setting_pannel_filter_fragrance)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.fwhite, getResources().getString(R.string.beauty_setting_pannel_filter_white)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.langman, getResources().getString(R.string.beauty_setting_pannel_filter_romantic)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.qingxin, getResources().getString(R.string.beauty_setting_pannel_filter_fresh)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.weimei, getResources().getString(R.string.beauty_setting_pannel_filter_beautiful)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.fennen, getResources().getString(R.string.beauty_setting_pannel_filter_pink)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.huaijiu, getResources().getString(R.string.beauty_setting_pannel_filter_reminiscence)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.landiao, getResources().getString(R.string.beauty_setting_pannel_filter_blues)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.qingliang, getResources().getString(R.string.beauty_setting_pannel_filter_cool)));
        mFilterBeautyDataList.add(new BeautyData(R.drawable.rixi, getResources().getString(R.string.beauty_setting_pannel_filter_Japanese)));
    }

    /**
     * 初始化绿幕数据
     */
    private void initGreenScreenData() {
        mGreenScreenDataList = new ArrayList<BeautyData>();
        mGreenScreenDataList.add(new BeautyData(R.drawable.ic_effect_non, getResources().getString(R.string.beauty_setting_pannel_green_screen_none)));
        mGreenScreenDataList.add(new BeautyData(R.drawable.ic_beauty_goodluck, getResources().getString(R.string.beauty_setting_pannel_green_screen_good_luck)));
    }

    private void initKoubeiData() {
        mKoubeiDataList = new ArrayList<BeautyData>();
        mKoubeiDataList.add(new BeautyData(R.drawable.ic_effect_non, getResources().getString(R.string.beauty_setting_pannel_key_none)));
        mKoubeiDataList.add(new BeautyData(R.drawable.ic_beauty_koubei, getResources().getString(R.string.beauty_setting_pannel_key_AI_key)));
    }

    private void initGestureData() {
        mGestureDataLit = new ArrayList<BeautyData>();
        mGestureDataLit.add(new BeautyData(R.drawable.ic_effect_non, getResources().getString(R.string.beauty_setting_pannel_key_none)));
        mGestureDataLit.add(new BeautyData(R.drawable.video_pikachu, getResources().getString(R.string.beauty_setting_pannel_pikaqiu)));
        mGestureDataLit.add(new BeautyData(R.drawable.video_liuxingyu, getResources().getString(R.string.beauty_setting_pannel_liuxingyu)));
        mGestureDataLit.add(new BeautyData(R.drawable.video_kongxue2, getResources().getString(R.string.beauty_setting_pannel_kongxue)));
        mGestureDataLit.add(new BeautyData(R.drawable.video_dianshizhixing, getResources().getString(R.string.beauty_setting_pannel_dianshizhixing)));
        mGestureDataLit.add(new BeautyData(R.drawable.video_bottle1, getResources().getString(R.string.beauty_setting_pannel_bottle)));
    }

    private void initFaceBeautyData() {
        mFaceBeautyDataList = new ArrayList<BeautyData>();
        mFaceBeautyDataList.add(new BeautyData(R.drawable.ic_effect_non, getResources().getString(R.string.beauty_setting_pannel_key_none)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_cherries, getResources().getString(R.string.beauty_setting_pannel_cherries)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_haiyang2, getResources().getString(R.string.beauty_setting_pannel_haiyang)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_fenfenxia_square, getResources().getString(R.string.beauty_setting_pannel_fenfenxia)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_guajiezhuang, getResources().getString(R.string.beauty_setting_pannel_guajiezhuang)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_qixichun, getResources().getString(R.string.beauty_setting_pannel_qixichun)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_gufengzhuang, getResources().getString(R.string.beauty_setting_pannel_gufengzhuang)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_dxxiaochounv, getResources().getString(R.string.beauty_setting_pannel_xiaochounv)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_remix1, getResources().getString(R.string.beauty_setting_pannel_hunhezhuang)));
        mFaceBeautyDataList.add(new BeautyData(R.drawable.video_yuansufugu, getResources().getString(R.string.beauty_setting_pannel_yuansufugu)));
    }

    private void setFirstPickerType() {
        mFirstGradleArrayString.clear();
        mFirstGradleArrayString.addAll(Arrays.asList(mBeautyStyleString));
        mFirstGradleAdapter = new ArrayAdapter<String>(mContext, 0, mFirstGradleArrayString) {
            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                String value = getItem(position);
                if (convertView == null) {
                    LayoutInflater inflater = LayoutInflater.from(getContext());
                    convertView = inflater.inflate(android.R.layout.simple_list_item_1, null);
                }
                TextView view = (TextView) convertView.findViewById(android.R.id.text1);
                view.setTag(position);
                view.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
                view.setText(value);
                view.setPadding(15, 5, 30, 5);
                view.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        int index = (int) view.getTag();
                        ViewGroup group = (ViewGroup) mFirstGradlePicker.getChildAt(0);
                        for (int i = 0; i < mFirstGradleAdapter.getCount(); i++) {
                            View v = group.getChildAt(i);
                            if (v instanceof TextView) {
                                if (i == index) {
                                    ((TextView) v).setTextColor(mTextColorPrimary);
//                                    ((TextView) v).setTextColor(mContext.getResources().getColor(R.color.colorRed));
                                } else {
                                    ((TextView) v).setTextColor(Color.WHITE);
                                }
                            }
                        }
                        setSecondPickerType(index);
                    }
                });
                return convertView;

            }
        };
        mFirstGradlePicker.setAdapter(mFirstGradleAdapter);
        mFirstGradlePicker.setClicked(ITEM_TYPE_BEAUTY);
    }

    private void setSecondPickerType(int type) {
        mSencodGradleType = type;

        beautyDataList = null;
        switch (type) {
            case ITEM_TYPE_BEAUTY:
                beautyDataList = mBeautyDataList;
                break;
            case ITEM_TYPE_FILTTER:
                beautyDataList = mFilterBeautyDataList;
                break;
            case ITEM_TYPE_MOTION:
                beautyDataList = mMotionDataList;
                break;
            case ITEM_TYPE_KOUBEI:
                beautyDataList = mKoubeiDataList;
                break;
            case ITEM_TYPE_GREEN:
                beautyDataList = mGreenScreenDataList;
                break;
            case ITEM_TYPE_BEAUTY_FACE:
                beautyDataList = mFaceBeautyDataList;
                break;
            case ITEM_TYPE_GESUTRE:
                beautyDataList = mGestureDataLit;
                break;
            default:
                break;
        }
        mItemAdapter.addAll(beautyDataList);
        mItemAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(BeautyData beautyData, int pos) {
                switch (mSencodGradleType) {
                    case ITEM_TYPE_BEAUTY:
                    case ITEM_TYPE_FILTTER:
                    case ITEM_TYPE_GREEN:
                        setPickerEffect(mSencodGradleType, pos);
                        break;
                    case ITEM_TYPE_KOUBEI:
                        if (pos > motionDataKoubeiList.size() - 1) {
                            return;
                        }
                        motionData = motionDataKoubeiList.get(pos);
                        if (motionData.mMotionId.equals("none") || !TextUtils.isEmpty(motionData.mMotionPath)) {
                            setPickerEffect(mSencodGradleType, pos);
                        } else if ((TextUtils.isEmpty(motionData.mMotionPath))) {
                            downloadVideoMaterial(beautyData, motionData, pos);
                        }
                        break;
                    case ITEM_TYPE_MOTION:
                        if (pos > motionDataList.size() - 1) {
                            return;
                        }
                        motionData = motionDataList.get(pos);
                        if (motionData.mMotionId.equals("none") || !TextUtils.isEmpty(motionData.mMotionPath)) {
                            setPickerEffect(mSencodGradleType, pos);
                        } else if ((TextUtils.isEmpty(motionData.mMotionPath))) {
                            downloadVideoMaterial(beautyData, motionData, pos);
                        }
                        break;
                    case ITEM_TYPE_BEAUTY_FACE:
                        if (pos > motionBeautyFaceList.size() - 1) {
                            return;
                        }
                        motionData = motionBeautyFaceList.get(pos);
                        if (motionData.mMotionId.equals("none") || !TextUtils.isEmpty(motionData.mMotionPath)) {
                            setPickerEffect(mSencodGradleType, pos);
                        } else if ((TextUtils.isEmpty(motionData.mMotionPath))) {
                            downloadVideoMaterial(beautyData, motionData, pos);
                        }
                        break;
                    case ITEM_TYPE_GESUTRE:
                        if (pos > motionGestureList.size() - 1) {
                            return;
                        }
                        motionData = motionGestureList.get(pos);
                        if (motionData.mMotionId.equals("none") || !TextUtils.isEmpty(motionData.mMotionPath)) {
                            setPickerEffect(mSencodGradleType, pos);
                        } else if ((TextUtils.isEmpty(motionData.mMotionPath))) {
                            downloadVideoMaterial(beautyData, motionData, pos);
                        }
                        break;
                }
            }
        });
        mSecondGradlePicker.setAdapter(mItemAdapter);
        mSecondGradlePicker.setClicked(mSzSecondGradleIndex[mSencodGradleType]);
    }

    private void downloadVideoMaterial(BeautyData beautyData, final MotionData motionData, final int pos) {
        MaterialDownloader materialDownloader = new MaterialDownloader(mContext, beautyData.text, motionData.mMotionUrl);
        materialDownloader.start(new Downloadlistener() {
            @Override
            public void onDownloadFail(final String errorMsg) {
                ((Activity) mContext).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mCustomProgressDialog != null) {
                            mCustomProgressDialog.dismiss();
                        }
                        Toast.makeText(mContext, errorMsg, Toast.LENGTH_SHORT);
                    }
                });
            }

            @Override
            public void onDownloadProgress(final int progress) {
                ((Activity) mContext).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Log.i(TAG, "onDownloadProgress, progress = " + progress);
                        if (mCustomProgressDialog == null) {
                            mCustomProgressDialog = new CustomProgressDialog();
                            mCustomProgressDialog.createLoadingDialog(mContext);
                            mCustomProgressDialog.setCancelable(false); // 设置是否可以通过点击Back键取消
                            mCustomProgressDialog.setCanceledOnTouchOutside(false); // 设置在点击Dialog外是否取消Dialog进度条
                            mCustomProgressDialog.show();
                        }
                        mCustomProgressDialog.setMsg(progress + "%");
                    }
                });
            }

            @Override
            public void onDownloadSuccess(String filePath) {
                motionData.mMotionPath = filePath;
                mPrefs.edit().putString(motionData.mMotionId, filePath).apply();

                ((Activity) mContext).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mCustomProgressDialog != null) {
                            mCustomProgressDialog.dismiss();
                            mCustomProgressDialog = null;
                        }
                        setPickerEffect(mSencodGradleType, pos);
                    }
                });
            }
        });

    }

    public void setMotionTmplEnable(boolean enable) {
        if (mProxy != null) {
            if (enable) {
                mProxy.setMotionTmpl(null);
            } else {
                mProxy.setMotionTmpl(mBeautyParams.mMotionTmplPath);
            }
        }
    }

    /**
     * 清空美颜配置，如果SDK是新创建的则不需要最后清理，如果SDK是单例，需要调用此方法清空上次设置的美颜参数<br/>
     * 示例：TXUGCRecord是单例，需要调用，TXLivePusher每次创建新的，不需要调用
     */
    public void clear() {
        mBeautyParams = new BeautyParams();
        if (mProxy != null) {
            mProxy.setFilter(mBeautyParams.mFilterBmp, mBeautyParams.mFilterIndex);
            mProxy.setSpecialRatio(mBeautyParams.mFilterMixLevel);
            mProxy.setGreenScreenFile(mBeautyParams.mGreenFile, true);
            mProxy.setBeautyStyle(mBeautyParams.mBeautyStyle);
            mProxy.setBeautyLevel(mBeautyParams.mBeautyLevel);
            mProxy.setWhitenessLevel(mBeautyParams.mWhiteLevel);
            mProxy.setRuddyLevel(mBeautyParams.mRuddyLevel);
            mProxy.setEyeScaleLevel(mBeautyParams.mBigEyeLevel);
            mProxy.setFaceSlimLevel(mBeautyParams.mFaceSlimLevel);
            mProxy.setFaceVLevel(mBeautyParams.mFaceVLevel);
            mProxy.setChinLevel(mBeautyParams.mChinSlimLevel);
            mProxy.setFaceShortLevel(mBeautyParams.mFaceShortLevel);
            mProxy.setNoseSlimLevel(mBeautyParams.mNoseSlimLevel);
            mProxy.setEyeLightenLevel(mBeautyParams.mEyeLightenLevel);
            mProxy.setToothWhitenLevel(mBeautyParams.mToothWhitenLevel);
            mProxy.setWrinkleRemoveLevel(mBeautyParams.mWrinkleRemoveLevel);
            mProxy.setPounchRemoveLevel(mBeautyParams.mPounchRemoveLevel);
            mProxy.setSmileLinesRemoveLevel(mBeautyParams.mSmileLinesRemoveLevel);
            mProxy.setForeheadLevel(mBeautyParams.mForeheadLevel);
            mProxy.setEyeDistanceLevel(mBeautyParams.mEyeDistanceLevel);
            mProxy.setEyeAngleLevel(mBeautyParams.mEyeAngleLevel);
            mProxy.setMouthShapeLevel(mBeautyParams.mMouthShapeLevel);
            mProxy.setNoseWingLevel(mBeautyParams.mNoseWingLevel);
            mProxy.setNosePositionLevel(mBeautyParams.mNosePositionLevel);
            mProxy.setLipsThicknessLevel(mBeautyParams.mLipsThicknessLevel);
            mProxy.setFaceBeautyLevel(mBeautyParams.mFaceBeautyLevel);
            mProxy.setMotionTmpl(mBeautyParams.mMotionTmplPath);
        }
    }

    public interface OnItemClickListener {
        void onItemClick(BeautyData beautyData, int pos);
    }

    private void setPickerEffect(int type, int index) {
        initSeekBarValue();
        mSzSecondGradleIndex[type] = index;
        mThirdGradleIndex = index;

        switch (type) {
            case ITEM_TYPE_BEAUTY:
                mSeekbar.setVisibility(View.VISIBLE);
                mSeekBarValue.setVisibility(View.VISIBLE);
                mSeekbar.setProgress(mSzSeekBarValue[type][index]);
                setBeautyStyle(index, mSzSeekBarValue[type][index]);
                break;
            case ITEM_TYPE_FILTTER:
                setFilter(index);
                mSeekbar.setVisibility(View.VISIBLE);
                mSeekBarValue.setVisibility(View.VISIBLE);
                mSeekbar.setProgress(mSzSeekBarValue[type][index]);
                break;
            case ITEM_TYPE_MOTION:
            case ITEM_TYPE_BEAUTY_FACE:
            case ITEM_TYPE_GESUTRE:
                mSeekbar.setVisibility(View.GONE);
                mSeekBarValue.setVisibility(View.GONE);
                setDynamicEffect(type, index);
                break;
            case ITEM_TYPE_KOUBEI:
                mSeekbar.setVisibility(View.GONE);
                mSeekBarValue.setVisibility(View.GONE);
                setDynamicEffect(type, index);
                break;
            case ITEM_TYPE_GREEN:
                mSeekbar.setVisibility(View.GONE);
                mSeekBarValue.setVisibility(View.GONE);
                setGreenScreen(index);
                break;
            default:
                break;
        }

    }

    private Bitmap decodeResource(Resources resources, int id) {
        TypedValue value = new TypedValue();
        resources.openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(resources, id, opts);
    }

    //设置滤镜
    private void setFilter(int index) {
        Bitmap bmp = getFilterBitmapByIndex(index);
        mBeautyParams.mFilterBmp = bmp;
        mBeautyParams.mFilterIndex = index;
        if (mProxy != null) {
            mProxy.setFilter(bmp, index);
        }
    }

    public Bitmap getFilterBitmapByIndex(int index) {
        Bitmap bmp = null;
        switch (index) {
            case 1:
                bmp = decodeResource(getResources(), R.drawable.filter_biaozhun);
                break;
            case 2:
                bmp = decodeResource(getResources(), R.drawable.filter_yinghong);
                break;
            case 3:
                bmp = decodeResource(getResources(), R.drawable.filter_yunshang);
                break;
            case 4:
                bmp = decodeResource(getResources(), R.drawable.filter_chunzhen);
                break;
            case 5:
                bmp = decodeResource(getResources(), R.drawable.filter_bailan);
                break;
            case 6:
                bmp = decodeResource(getResources(), R.drawable.filter_yuanqi);
                break;
            case 7:
                bmp = decodeResource(getResources(), R.drawable.filter_chaotuo);
                break;
            case 8:
                bmp = decodeResource(getResources(), R.drawable.filter_xiangfen);
                break;
            case 9:
                bmp = decodeResource(getResources(), R.drawable.filter_white);
                break;
            case 10:
                bmp = decodeResource(getResources(), R.drawable.filter_langman);
                break;
            case 11:
                bmp = decodeResource(getResources(), R.drawable.filter_qingxin);
                break;
            case 12:
                bmp = decodeResource(getResources(), R.drawable.filter_weimei);
                break;
            case 13:
                bmp = decodeResource(getResources(), R.drawable.filter_fennen);
                break;
            case 14:
                bmp = decodeResource(getResources(), R.drawable.filter_huaijiu);
                break;
            case 15:
                bmp = decodeResource(getResources(), R.drawable.filter_landiao);
                break;
            case 16:
                bmp = decodeResource(getResources(), R.drawable.filter_qingliang);
                break;
            case 17:
                bmp = decodeResource(getResources(), R.drawable.filter_rixi);
                break;
            default:
                bmp = null;
                break;
        }
        return bmp;
    }

    //设置绿幕
    private void setGreenScreen(int index) {
        String file = "";
        switch (index) {
            case 1:
                file = "green_1.mp4";
                break;
            default:
                break;
        }
        mBeautyParams.mGreenFile = file;
        if (mProxy != null) {
            mProxy.setGreenScreenFile(file, true);
        }
    }

    //设置动效
    private void setDynamicEffect(int type, int index) {
        MotionData motionData = null;
        if (type == ITEM_TYPE_MOTION) {
            motionData = motionDataList.get(index);
        } else if (type == ITEM_TYPE_KOUBEI) {
            motionData = motionDataKoubeiList.get(index);
        } else if (type == ITEM_TYPE_BEAUTY_FACE) {
            motionData = motionBeautyFaceList.get(index);
        } else if (type == ITEM_TYPE_GESUTRE) {
            motionData = motionGestureList.get(index);
            if (motionData.mMotionId.equals("video_pikachu")) {
                Toast.makeText(mContext, "伸出手掌", Toast.LENGTH_SHORT).show();
            }
        }
        mBeautyParams.mMotionTmplPath = motionData.mMotionPath;
        if (mProxy != null) {
            mProxy.setMotionTmpl(motionData.mMotionPath);
        }
    }

    // 设置美颜类型
    private void setBeautyStyle(int style, int beautyLevel) {
        if (style >= 3) {
            return;
        }
        mBeautyParams.mBeautyStyle = style;
        mBeautyParams.mBeautyLevel = beautyLevel;
        if (mProxy != null) {
            mProxy.setBeautyStyle(style);
            mProxy.setBeautyLevel(beautyLevel);
        }
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        initSeekBarValue();
        mSzSeekBarValue[mSencodGradleType][mThirdGradleIndex] = progress;   // 记录设置的值
        mSeekBarValue.setText(String.valueOf(progress));

        if (seekBar.getId() == R.id.seekbarThird) {
            if (mSencodGradleType == ITEM_TYPE_BEAUTY) {
                BeautyData beautyData = beautyDataList.get(mThirdGradleIndex);
                String beautyType = beautyData.text;
                if (beautyType.equals(getResources().getString(R.string.beauty_pannel_style_smooth))) {
                    mBeautyParams.mBeautyStyle = BEAUTYPARAM_BEAUTY_STYLE_SMOOTH;
                    mBeautyParams.mBeautyLevel = progress;
                    if (mProxy != null) {
                        mProxy.setBeautyStyle(BEAUTYPARAM_BEAUTY_STYLE_SMOOTH);
                        mProxy.setBeautyLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_style_natural))) {
                    mBeautyParams.mBeautyStyle = BEAUTYPARAM_BEAUTY_STYLE_NATURAL;
                    mBeautyParams.mBeautyLevel = progress;
                    if (mProxy != null) {
                        mProxy.setBeautyStyle(BEAUTYPARAM_BEAUTY_STYLE_NATURAL);
                        mProxy.setBeautyLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_style_pitu))) {
                    mBeautyParams.mBeautyStyle = BEAUTYPARAM_BEAUTY_STYLE_HAZY;
                    mBeautyParams.mBeautyLevel = progress;
                    if (mProxy != null) {
                        mProxy.setBeautyStyle(BEAUTYPARAM_BEAUTY_STYLE_HAZY);
                        mProxy.setBeautyLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_white))) {
                    mBeautyParams.mWhiteLevel = progress;
                    if (mProxy != null) {
                        mProxy.setWhitenessLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_ruddy))) {
                    mBeautyParams.mRuddyLevel = progress;
                    if (mProxy != null) {
                        mProxy.setRuddyLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_bigeye))) {
                    mBeautyParams.mBigEyeLevel = progress;
                    if (mProxy != null) {
                        mProxy.setEyeScaleLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_faceslim))) {
                    mBeautyParams.mFaceSlimLevel = progress;
                    if (mProxy != null) {
                        mProxy.setFaceSlimLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_facev))) {
                    mBeautyParams.mFaceVLevel = progress;
                    if (mProxy != null) {
                        mProxy.setFaceVLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_chin))) {
                    mBeautyParams.mChinSlimLevel = progress;
                    if (mProxy != null) {
                        mProxy.setChinLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_faceshort))) {
                    mBeautyParams.mFaceShortLevel = progress;
                    if (mProxy != null) {
                        mProxy.setFaceShortLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_noseslim))) {
                    mBeautyParams.mNoseSlimLevel = progress;
                    if (mProxy != null) {
                        mProxy.setNoseSlimLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_eyelighten))) {
                    mBeautyParams.mEyeLightenLevel = progress;
                    if (mProxy != null) {
                        mProxy.setEyeLightenLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_toothwhite))) {
                    mBeautyParams.mToothWhitenLevel = progress;
                    if (mProxy != null) {
                        mProxy.setToothWhitenLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_pounchremove))) {
                    mBeautyParams.mPounchRemoveLevel = progress;
                    if (mProxy != null) {
                        mProxy.setPounchRemoveLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_wrinkleremove))) {
                    mBeautyParams.mWrinkleRemoveLevel = progress;
                    if (mProxy != null) {
                        mProxy.setWrinkleRemoveLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_smilelinesremove))) {
                    mBeautyParams.mSmileLinesRemoveLevel = progress;
                    if (mProxy != null) {
                        mProxy.setSmileLinesRemoveLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_forehead))) {
                    mBeautyParams.mForeheadLevel = progress;
                    if (mProxy != null) {
                        mProxy.setForeheadLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_eyedistance))) {
                    mBeautyParams.mEyeDistanceLevel = progress;
                    if (mProxy != null) {
                        mProxy.setEyeDistanceLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_eyeangle))) {
                    mBeautyParams.mEyeAngleLevel = progress;
                    if (mProxy != null) {
                        mProxy.setEyeAngleLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_mouthshape))) {
                    mBeautyParams.mMouthShapeLevel = progress;
                    if (mProxy != null) {
                        mProxy.setMouthShapeLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_nosewing))) {
                    mBeautyParams.mNoseWingLevel = progress;
                    if (mProxy != null) {
                        mProxy.setNoseWingLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_noseposition))) {
                    mBeautyParams.mNosePositionLevel = progress;
                    if (mProxy != null) {
                        mProxy.setNosePositionLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_mousewidth))) {
                    mBeautyParams.mMouthShapeLevel = progress;
                    if (mProxy != null) {
                        mProxy.setLipsThicknessLevel(progress);
                    }
                } else if (beautyType.equals(getResources().getString(R.string.beauty_pannel_faceshape))) {
                    mBeautyParams.mFaceBeautyLevel = progress;
                    if (mProxy != null) {
                        mProxy.setFaceBeautyLevel(progress);
                    }
                }
            } else if (mSencodGradleType == ITEM_TYPE_FILTTER) {
                if (mProxy != null) {
                    mProxy.setSpecialRatio(progress);
                }
            }

        }

    }

    private void initSeekBarValue() {
        if (null == mSzSeekBarValue) {
            mSzSeekBarValue = new int[16][24];
            for (int i = 1; i < mSzSeekBarValue[ITEM_TYPE_FILTTER].length; i++) {
                mSzSeekBarValue[ITEM_TYPE_FILTTER][i] = mFilterBasicLevel;
            }
            // 前八个滤镜的推荐值 （其他默认为5）
            mSzSeekBarValue[ITEM_TYPE_FILTTER][1] = 4;
            mSzSeekBarValue[ITEM_TYPE_FILTTER][2] = 8;
            mSzSeekBarValue[ITEM_TYPE_FILTTER][3] = 8;
            mSzSeekBarValue[ITEM_TYPE_FILTTER][4] = 8;
            mSzSeekBarValue[ITEM_TYPE_FILTTER][5] = 10;
            mSzSeekBarValue[ITEM_TYPE_FILTTER][6] = 8;
            mSzSeekBarValue[ITEM_TYPE_FILTTER][7] = 10;
            mSzSeekBarValue[ITEM_TYPE_FILTTER][8] = 5;
            // 设置美颜默认值
            mSzSeekBarValue[ITEM_TYPE_BEAUTY][0] = mBeautyBasicLevel;
            mSzSeekBarValue[ITEM_TYPE_BEAUTY][1] = mBeautyBasicLevel;
            mSzSeekBarValue[ITEM_TYPE_BEAUTY][2] = mBeautyBasicLevel;
            mSzSeekBarValue[ITEM_TYPE_BEAUTY][3] = mWhiteBasicLevel;
            mSzSeekBarValue[ITEM_TYPE_BEAUTY][4] = mRuddyBasicLevel;
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

    public int getFilterProgress(int index) {
        return mSzSeekBarValue[ITEM_TYPE_FILTTER][index];
    }

    public String[] getBeautyFilterArr() {
        return mFilterTypeString;
    }

    @Override
    public void onClick(View v) {

    }

    public void setCurrentFilterIndex(int index) {
        mSzSecondGradleIndex[ITEM_TYPE_FILTTER] = index;
        if (mSencodGradleType == ITEM_TYPE_FILTTER) {
            ViewGroup group = (ViewGroup) mSecondGradlePicker.getChildAt(0);
            int size = mItemAdapter.getCount();
            for (int i = 0; i < size; i++) {
                View v = group.getChildAt(i);
                if (v instanceof TextView) {
                    if (i == index) {
                        ((TextView) v).setTextColor(mTextColorPrimary);
//                        ((TextView) v).setTextColor(mContext.getResources().getColor(R.color.colorRed));
                    } else {
                        ((TextView) v).setTextColor(Color.WHITE);
                    }
                }
            }

            mThirdGradleIndex = index;
            mSeekbar.setVisibility(View.VISIBLE);
            mSeekBarValue.setVisibility(View.VISIBLE);
            mSeekbar.setProgress(mSzSeekBarValue[ITEM_TYPE_FILTTER][index]);
        }
    }
}
