package com.tencent.liteav.demo.trtc.widget;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.database.DataSetObserver;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Environment;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Adapter;
import android.widget.ArrayAdapter;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.trtc.sdkadapter.TRTCCloudManager;
import com.tencent.liteav.demo.trtc.sdkadapter.beauty.BeautyConfig;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Module:   TRTCBeautySettingPannel
 * <p>
 * 选择美颜，滤镜，动效等参数的界面，其中大眼，瘦脸，动效等功能在企业版SDK才生效
 */
public class TRTCBeautySettingPanel extends FrameLayout implements SeekBar.OnSeekBarChangeListener {
    //    public static final int ITEM_TYPE_BEAUTY_STYLE = 0;
    public static final int    ITEM_TYPE_BEAUTY             = 0;
    public static final int    ITEM_TYPE_FILTTER            = 1;
    public static final int    ITEM_TYPE_MOTION             = 2;
    public static final int    ITEM_TYPE_KOUBEI             = 3;
    public static final int    ITEM_TYPE_GREEN              = 4;
    //    public static final int ITEM_TYPE_BEAUTY_BODY = 5; // 美体
    public static final int ITEM_TYPE_BEAUTY_FACE = 5; // 美妆
    public static final int ITEM_TYPE_GESUTRE = 6;     // 手势
    public static final int    BEAUTYPARAM_EXPOSURE         = 0;
    public static final int    BEAUTYPARAM_BEAUTY           = 1;
    public static final int    BEAUTYPARAM_WHITE            = 2;
    public static final int    BEAUTYPARAM_FACE_LIFT        = 3;
    public static final int    BEAUTYPARAM_BIG_EYE          = 4;
    public static final int    BEAUTYPARAM_FILTER           = 5;
    public static final int    BEAUTYPARAM_FILTER_MIX_LEVEL = 6;
    public static final int    BEAUTYPARAM_MOTION_TMPL      = 7;
    public static final int    BEAUTYPARAM_GREEN            = 8;
    //    public static final int BEAUTYPARAM_BEAUTY_STYLE = 9;
    public static final int    BEAUTYPARAM_RUDDY            = 10;
    public static final int    BEAUTYPARAM_NOSESCALE        = 11;
    public static final int    BEAUTYPARAM_CHINSLIME        = 12;
    public static final int    BEAUTYPARAM_FACEV            = 13;
    public static final int    BEAUTYPARAM_FACESHORT        = 14;
    public static final int    BEAUTYPARAM_SHARPEN          = 15;
    public static final int    BEAUTYPARAM_CAPTURE_MODE     = 16;
    public static final int    BEAUTYPARAM_SKINBEAUTY = 17;
    public static final int    BEAUTYPARAM_EYELIGHTEN = 18;
    public static final int    BEAUTYPARAM_TOOTHWHITEN = 19;
    public static final int    BEAUTYPARAM_WRINKLEREMOVE = 20;
    public static final int    BEAUTYPARAM_POUNCHREMOVE = 21;
    public static final int    BEAUTYPARAM_SMILELINESREMOVE = 22;
    public static final int    BEAUTYPARAM_FOREHEAD = 23;
    public static final int    BEAUTYPARAM_EYEDISTANCE = 24;
    public static final int    BEAUTYPARAM_EYEANGLE = 25;
    public static final int    BEAUTYPARAM_MOUTHSHAPE = 26;
    public static final int    BEAUTYPARAM_NOSEWING = 27;
    public static final int    BEAUTYPARAM_NOSEPOSITION = 28;
    public static final int    BEAUTYPARAM_LIPSTHICKNESS = 29;
    public static final int    BEAUTYPARAM_FACEBEAUTY = 30;
    public static final int    BEAUTYPARAM_LONGLEG = 31;
    public static final int    BEAUTYPARAM_THINWAIST = 32;
    public static final int    BEAUTYPARAM_THINBODY = 33;
    public static final int    BEAUTYPARAM_THINSHOULDER = 34;
    private final       String TAG                          = "BeautySettingPannel";
    private final       int    mFilterBasicLevel            = 5;
    private final       int    mBeautyBasicLevel            = 4;
    private final       int    mWhiteBasicLevel             = 1;
    private final       int    mRuddyBasicLevel             = 0;
    private final       int    mSharpenLevel                = 3;
    // 新界面
    HorizontalScrollView mFirstGradlePicker;
    DataSetObserver      mFirstObserver;
    //    TXHorizontalPickerView mFirstGradlePicker;
    ArrayAdapter<String> mFirstGradleAdapter;
    HorizontalScrollView mSecondGradlePicker;
    DataSetObserver      mSecondObserver;
    //    TXHorizontalPickerView mSecondGradlePicker;
    ArrayAdapter<String> mSecondGradleAdapter;
    LinearLayout         mSeekBarLL = null;

    //    private String[] mCaptureModeString = {
    //            "低采",
    //            "高采"
    //    };
    TextView             mSeekBarValue = null;
    CustomProgressDialog mCustomProgressDialog;
    private int               mSencodGradleType         = ITEM_TYPE_BEAUTY;
    private ArrayList<String> mFirstGradleArrayString   = new ArrayList<String>();
    private ArrayList<String> mSencodeGradleArrayString = new ArrayList<String>();
    private int               mThirdGradleIndex         = 0;
    private int[][]           mSzSeekBarValue           = null;
    private int[]             mSzSecondGradleIndex      = new int[16];
    private String[]          mFirstGradleString        = {
            //            "风格",
            "美颜",
            "滤镜",
            "动效", //liteav_pitu
            "抠背", //liteav_pitu
            "绿幕", //liteav_pitu
            //            "采集"
            "美妆",
            "手势"
    };

//    private String[] mBeautyBodyString = {
//            "长腿",
//            "瘦腰",
//            "瘦体",
//            "瘦肩",
//    };

    //    private String[] mBeautyStyleString = {
    //            "光滑",
    //            "自然",
    //            "朦胧"
    //    };
    private String[] mBeautyFaceString = {
            "无",
            "原宿复古"
    };

    private String[] mGestureString = {
            "无",
            "皮卡丘"
    };
    private String[]          mBeautyString             = {
            "美颜(光滑)",
            "美颜(自然)",
            "美颜(天天P图)", //liteav_pitu
            "美白",
            "红润",
            //            "清晰",
            "曝光",
            "大眼",//liteav_pitu
            "瘦脸", //liteav_pitu
            "V脸",//liteav_pitu
            "下巴",//liteav_pitu
            "短脸",//liteav_pitu
            "小鼻",//liteav_pitu
            "亮眼",
            "白牙",
            "祛眼袋",
            "祛皱",
            "祛法令纹",
            "发际线",
            "眼距",
            "眼角",
            "嘴型",
            "鼻翼",
            "鼻子位置",
            "嘴唇厚度",
            "脸型",
    };
    private String[]          mBeautyFilterTypeString   = {
            "无",

            "标准",    // 4
            "樱红",    // 8
            "云裳",    // 8
            "纯真",    // 8
            "白兰",    // 10
            "元气",    // 8
            "超脱",    // 10
            "香氛",    // 5
            "美白",    // 5
            "浪漫",    // 5
            "清新",    // 5
            "唯美",    // 5
            "粉嫩",    // 5
            "怀旧",    // 5
            "蓝调",    // 5
            "清凉",    // 5
            "日系",    // 5
    };
    private String[]          mMotionTypeString         = {
            "无动效",
            "Boom",
            "霓虹鼠",
            "星耳",
            "疯狂打call",
            "Q星座",
            "彩色丝带",
            "刘海发带",
            "变脸",
            "紫色小猫",
            "花仙子",
            "小公举",
    };
    private String[]          mGreenString              = {
            "无",
            "Good Luck"
    };
    private String[]          mKoubeiString             = {
            "无",
            "AI抠背"
    };
    private List<MotionData>  motionDataList            = new ArrayList<>();
    private List<MotionData>  motionDataKoubeiList      = new ArrayList<>();
    private List<MotionData> motionBeautyFaceList = new ArrayList<>();
    private List<MotionData> motionGestureList = new ArrayList<>();
    private MotionData        mMotionData;
    private SharedPreferences mPrefs                    = PreferenceManager.getDefaultSharedPreferences(getContext());
    private int               mExposureLevel            = -1;
    private SeekBar           mThirdGradleSeekBar;
    private Context           mContext;
    private TRTCCloudManager  mTRTCCloudManager;

    public TRTCBeautySettingPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        View view = LayoutInflater.from(context).inflate(R.layout.beauty_panel, this);
        mContext = context;
        initView(view);
    }

    //    private IOnBeautyParamsChangeListener mTRTCCloudManager;

    public static String unZip(String zipFile, String targetDir) {
        if (TextUtils.isEmpty(zipFile)) {
            return null;
        } else {
            File file = new File(zipFile);
            if (!file.exists()) {
                return null;
            } else {
                File targetFolder = new File(targetDir);
                if (!targetFolder.exists()) {
                    targetFolder.mkdirs();
                }

                String               dataDir = null;
                short                BUFFER  = 4096;
                FileInputStream      fis     = null;
                ZipInputStream       zis     = null;
                FileOutputStream     fos     = null;
                BufferedOutputStream dest    = null;

                try {
                    fis = new FileInputStream(file);
                    zis = new ZipInputStream(new BufferedInputStream(fis));

                    while (true) {
                        while (true) {
                            String   strEntry;
                            ZipEntry entry;
                            do {
                                if ((entry = zis.getNextEntry()) == null) {
                                    return dataDir;
                                }

                                strEntry = entry.getName();
                            } while (strEntry.contains("../"));

                            if (entry.isDirectory()) {
                                String count1 = targetDir + File.separator + strEntry;
                                File   data1  = new File(count1);
                                if (!data1.exists()) {
                                    data1.mkdirs();
                                }

                                if (TextUtils.isEmpty(dataDir)) {
                                    dataDir = data1.getPath();
                                }
                            } else {
                                byte[] data          = new byte[BUFFER];
                                String targetFileDir = targetDir + File.separator + strEntry;
                                File   targetFile    = new File(targetFileDir);

                                try {
                                    fos = new FileOutputStream(targetFile);
                                    dest = new BufferedOutputStream(fos, BUFFER);

                                    int count;
                                    while ((count = zis.read(data)) != -1) {
                                        dest.write(data, 0, count);
                                    }

                                    dest.flush();
                                } catch (IOException var41) {
                                    ;
                                } finally {
                                    try {
                                        if (dest != null) {
                                            dest.close();
                                        }

                                        if (fos != null) {
                                            fos.close();
                                        }
                                    } catch (IOException var40) {
                                        ;
                                    }

                                }
                            }
                        }
                    }
                } catch (IOException var43) {
                    ;
                } finally {
                    try {
                        if (zis != null) {
                            zis.close();
                        }

                        if (fis != null) {
                            fis.close();
                        }
                    } catch (IOException var39) {
                        ;
                    }

                }

                return dataDir;
            }
        }
    }

    private static File getExternalFilesDir(Context context) {
        File file = null;

        String filesDir = "/Android/data/" + context.getPackageName() + "/files/";
        file = new File(Environment.getExternalStorageDirectory().getPath() + filesDir);

        return file;
    }

    public static boolean isNetworkAvailable(Context context) {
        ConnectivityManager connectivity = (ConnectivityManager) context.getSystemService("connectivity");
        if (connectivity == null) {
            return false;
        } else {
            NetworkInfo networkInfo = connectivity.getActiveNetworkInfo();
            return networkInfo != null && networkInfo.isConnectedOrConnecting();
        }
    }

    private void initMotionData() {
        motionDataList.add(new MotionData("none", "无动效", "", ""));        // 0
        motionDataList.add(new MotionData("video_boom", "Boom", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_boomAndroid.zip",
                mPrefs.getString("video_boom", "")));                       // 1
        motionDataList.add(new MotionData("video_nihongshu", "霓虹鼠", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_nihongshuAndroid.zip",
                mPrefs.getString("video_nihongshu", "")));                  // 2
        motionDataList.add(new MotionData("video_starear", "星耳", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_starearAndroid.zip",
                mPrefs.getString("video_starear", "")));  // 3
        motionDataList.add(new MotionData("video_fengkuangdacall", "疯狂打call", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_fengkuangdacallAndroid.zip",
                mPrefs.getString("video_fengkuangdacall", "")));            // 4
        motionDataList.add(new MotionData("video_Qxingzuo", "Q星座", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_QxingzuoAndroid.zip",
                mPrefs.getString("video_Qxingzuo", "")));                   // 5
        motionDataList.add(new MotionData("video_caidai", "彩色丝带", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_caidaiAndroid.zip",
                mPrefs.getString("video_caidai", "")));                     // 6
        motionDataList.add(new MotionData("video_liuhaifadai", "刘海发带", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_liuhaifadaiAndroid.zip",
                mPrefs.getString("video_liuhaifadai", "")));                // 7
        motionDataList.add(new MotionData("video_lianpu", "变脸", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_lianpuAndroid.zip",
                mPrefs.getString("video_lianpu", "")));                    // 8
        motionDataList.add(new MotionData("video_purplecat", "紫色小猫", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_purplecatAndroid.zip",
                mPrefs.getString("video_purplecat", "")));                  // 9
        motionDataList.add(new MotionData("video_huaxianzi", "花仙子", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_huaxianziAndroid.zip",
                mPrefs.getString("video_huaxianzi", "")));                  // 10
        motionDataList.add(new MotionData("video_baby_agetest", "小公举", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_baby_agetestAndroid.zip",
                mPrefs.getString("video_baby_agetest", "")));               // 11
        // 单独把 抠背 的动效拿出来
        motionDataKoubeiList.add(new MotionData("none", "无", "", ""));        // 0
        motionDataKoubeiList.add(new MotionData("video_xiaofu", "校服", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/170/video_xiaofuAndroid.zip",
                mPrefs.getString("video_xiaofu", "")));

        // 美妆
        motionBeautyFaceList.add(new MotionData("none", "无", "", ""));
        motionBeautyFaceList.add(new MotionData("video_yuansufugu", "原宿复古", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/180/video_yuansufugu.zip",
                mPrefs.getString("video_yuansufugu", "")));
        // 手势
        motionGestureList.add(new MotionData("none", "无", "", ""));
        motionGestureList.add(new MotionData("video_pikachu", "皮卡丘", "http://dldir1.qq.com/hudongzhibo/AISpecial/Android/181/video_pikachu.zip",
                mPrefs.getString("video_pikachu", "")));
    }

    public void setTRTCCloudManager(TRTCCloudManager TRTCCloudManager) {
        mTRTCCloudManager = TRTCCloudManager;
    }

    public void disableExposure() {
        mBeautyString = new String[]{
                "美颜(光滑)",
                "美颜(自然)",
                "美颜(天天P图)",
                "美白",
                "红润",
                "大眼",
                "瘦脸",
                "V脸",
                "下巴",
                "短脸",
                "小鼻",
                "亮眼",
                "白牙",
                "祛眼袋",
                "祛皱",
                "祛法令纹",
                "发际线",
                "眼距",
                "眼角",
                "嘴型",
                "鼻翼",
                "鼻子位置",
                "嘴唇厚度",
                "脸型",
        };
        setFirstPickerType(null);
    }

    private void initView(View view) {
        mThirdGradleSeekBar = (SeekBar) view.findViewById(R.id.ThirdGradle_seekbar);
        mThirdGradleSeekBar.setOnSeekBarChangeListener(this);

        mFirstGradlePicker = (HorizontalScrollView) view.findViewById(R.id.FirstGradePicker);
        mFirstObserver = new DataSetObserver() {
            @Override
            public void onChanged() {
                super.onChanged();
                updateAdapter(mFirstGradlePicker, mFirstGradleAdapter);
            }

            @Override
            public void onInvalidated() {
                super.onInvalidated();
                ((ViewGroup) mFirstGradlePicker.getChildAt(0)).removeAllViews();
            }
        };
        mSecondGradlePicker = (HorizontalScrollView) view.findViewById(R.id.secondGradePicker);
        mSecondObserver = new DataSetObserver() {
            @Override
            public void onChanged() {
                super.onChanged();
                updateAdapter(mSecondGradlePicker, mSecondGradleAdapter);
            }

            @Override
            public void onInvalidated() {
                super.onInvalidated();
                ((ViewGroup) mSecondGradlePicker.getChildAt(0)).removeAllViews();
            }
        };
        mSeekBarLL = (LinearLayout) view.findViewById(R.id.layoutSeekBar);

        mSeekBarValue = (TextView) view.findViewById(R.id.TextSeekBarValue);

        setFirstPickerType(view);

        initMotionData();
    }

    private void setFirstPickerType(View view) {
        mFirstGradleArrayString.clear();
        for (int i = 0; i < mFirstGradleString.length; i++) {
            mFirstGradleArrayString.add(mFirstGradleString[i]);
        }
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
                        int       index = (int) view.getTag();
                        ViewGroup group = (ViewGroup) mFirstGradlePicker.getChildAt(0);
                        for (int i = 0; i < mFirstGradleAdapter.getCount(); i++) {
                            View v = group.getChildAt(i);
                            if (v instanceof TextView) {
                                if (i == index) {
                                    ((TextView) v).setTextColor(mContext.getResources().getColor(R.color.colorAccent));
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
        mFirstGradleAdapter.registerDataSetObserver(mFirstObserver);
        updateAdapter(mFirstGradlePicker, mFirstGradleAdapter);
        ((ViewGroup) mFirstGradlePicker.getChildAt(0)).getChildAt(ITEM_TYPE_BEAUTY).performClick();
        //        mFirstGradlePicker.setAdapter(mFirstGradleAdapter);
        //        mFirstGradlePicker.setClicked(ITEM_TYPE_BEAUTY);
    }

    private void setSecondPickerType(int type) {
        mSencodeGradleArrayString.clear();
        mSencodGradleType = type;

        String[] typeString = null;
        switch (type) {
            //            case ITEM_TYPE_BEAUTY_STYLE:
            //                typeString = mBeautyStyleString;
            //                break;
            case ITEM_TYPE_BEAUTY:
                typeString = mBeautyString;
                break;
            case ITEM_TYPE_FILTTER:
                typeString = mBeautyFilterTypeString;
                break;
            case ITEM_TYPE_MOTION:
                typeString = mMotionTypeString;
                break;
            case ITEM_TYPE_KOUBEI:
                typeString = mKoubeiString;
                break;
            case ITEM_TYPE_GREEN:
                typeString = mGreenString;
                break;
//            case ITEM_TYPE_CAPTURE:
//                typeString = mCaptureModeString;
//                break;
//            case ITEM_TYPE_BEAUTY_BODY:
//                typeString = mBeautyBodyString;
//                break;
            case ITEM_TYPE_BEAUTY_FACE:
                typeString = mBeautyFaceString;
                break;
            case ITEM_TYPE_GESUTRE:
                typeString = mGestureString;
                break;
            default:
                break;
        }
        for (int i = 0; i < typeString.length; i++) {
            mSencodeGradleArrayString.add(typeString[i]);
        }
        mSecondGradleAdapter = new ArrayAdapter<String>(mContext, 0, mSencodeGradleArrayString) {
            @Override
            public View getView(final int position, View convertView, ViewGroup parent) {
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
                        final int index = (int) view.getTag();
                        ViewGroup group = (ViewGroup) mSecondGradlePicker.getChildAt(0);
                        for (int i = 0; i < mSecondGradleAdapter.getCount(); i++) {
                            View v = group.getChildAt(i);
                            if (v instanceof TextView) {
                                if (i == index) {
                                    ((TextView) v).setTextColor(mContext.getResources().getColor(R.color.colorAccent));
                                } else {
                                    ((TextView) v).setTextColor(Color.WHITE);
                                }
                            }
                        }
                        if (mSencodGradleType != ITEM_TYPE_MOTION && mSencodGradleType != ITEM_TYPE_KOUBEI
                                && mSencodGradleType != ITEM_TYPE_BEAUTY_FACE && mSencodGradleType != ITEM_TYPE_GESUTRE) {
                            // 除了上述类型的几种没有进度条调节
                            setPickerEffect(mSencodGradleType, index);
                        } else {
                            if (mSencodGradleType == ITEM_TYPE_MOTION) {
                                mMotionData = motionDataList.get(position);
                            } else if (mSencodGradleType == ITEM_TYPE_KOUBEI) {
                                mMotionData = motionDataKoubeiList.get(position);
                            } else if (mSencodGradleType == ITEM_TYPE_BEAUTY_FACE) {
                                mMotionData = motionBeautyFaceList.get(position);
                            } else if (mSencodGradleType == ITEM_TYPE_GESUTRE) {
                                mMotionData = motionGestureList.get(position);
                            }

                            if (mMotionData.motionId.equals("none") || !TextUtils.isEmpty(mMotionData.motionPath)) {
                                setPickerEffect(mSencodGradleType, index);
                            } else if (TextUtils.isEmpty(mMotionData.motionPath)) {
                                VideoMaterialDownloadProgress videoMaterialDownloadProgress = new VideoMaterialDownloadProgress(mContext, mMotionTypeString[position], mMotionData.motionUrl);
                                videoMaterialDownloadProgress.start(new Downloadlistener() {
                                    @Override
                                    public void onDownloadFail(final String errorMsg) {
                                        ((Activity) mContext).runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                if (mCustomProgressDialog != null) {
                                                    mCustomProgressDialog.dismiss();
                                                }
                                                Toast.makeText(mContext, errorMsg, Toast.LENGTH_SHORT).show();
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
                                                    mCustomProgressDialog.createLoadingDialog(mContext, "");
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
                                        mMotionData.motionPath = filePath;
                                        mPrefs.edit().putString(mMotionData.motionId, filePath).apply();
                                        ((Activity) mContext).runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                if (mCustomProgressDialog != null) {
                                                    mCustomProgressDialog.dismiss();
                                                    mCustomProgressDialog = null;
                                                }
                                                setPickerEffect(mSencodGradleType, index);
                                            }
                                        });
                                    }
                                });
                            }
                        }
                    }
                });
                return convertView;
            }
        };

        mSecondGradleAdapter.registerDataSetObserver(mSecondObserver);
        updateAdapter(mSecondGradlePicker, mSecondGradleAdapter);
        ((ViewGroup) mSecondGradlePicker.getChildAt(0)).getChildAt(mSzSecondGradleIndex[mSencodGradleType]).performClick();
        //        mSecondGradlePicker.setAdapter(mSecondGradleAdapter);
        //        mSecondGradlePicker.setClicked(mSzSecondGradleIndex[mSencodGradleType]);
    }

    private void setPickerEffect(int type, int index) {
        initSeekBarValue();
        mSzSecondGradleIndex[type] = index;
        mThirdGradleIndex = index;

        switch (type) {
            //            case ITEM_TYPE_BEAUTY_STYLE:
            //                mThirdGradleSeekBar.setVisibility(View.GONE);
            //                mSeekBarValue.setVisibility(View.GONE);
            //                setBeautyStyle(index);
            //                break;
            case ITEM_TYPE_BEAUTY:
                mThirdGradleSeekBar.setVisibility(View.VISIBLE);
                mSeekBarValue.setVisibility(View.VISIBLE);
                mThirdGradleSeekBar.setProgress(mSzSeekBarValue[type][index]);
                setBeautyStyle(index, mSzSeekBarValue[type][index]);
                break;
            case ITEM_TYPE_FILTTER:
                setFilter(index);
                mThirdGradleSeekBar.setVisibility(View.VISIBLE);
                mSeekBarValue.setVisibility(View.VISIBLE);
                mThirdGradleSeekBar.setProgress(mSzSeekBarValue[type][index]);
                break;
            case ITEM_TYPE_MOTION:
                mThirdGradleSeekBar.setVisibility(View.GONE);
                mSeekBarValue.setVisibility(View.GONE);
                setDynamicEffect(type, index);
                break;
            case ITEM_TYPE_KOUBEI:
            case ITEM_TYPE_BEAUTY_FACE: // 美妆
            case ITEM_TYPE_GESUTRE:     // 手势
                mThirdGradleSeekBar.setVisibility(View.GONE);
                mSeekBarValue.setVisibility(View.GONE);
                setDynamicEffect(type, index);
                break;
            case ITEM_TYPE_GREEN:
                mThirdGradleSeekBar.setVisibility(View.GONE);
                mSeekBarValue.setVisibility(View.GONE);
                setGreenScreen(index);
                break;
            //            case ITEM_TYPE_CAPTURE:
            //                mThirdGradleSeekBar.setVisibility(View.GONE);
            //                mSeekBarValue.setVisibility(View.GONE);
            //                setCaptureMode(index);
            //                break;
            default:
                break;
        }

    }

    public void initProgressValue(int type, int index, int progress) {
        switch (type) {
            case ITEM_TYPE_BEAUTY:
            case ITEM_TYPE_FILTTER:
                mSzSeekBarValue[type][index] = progress;
                setPickerEffect(type, index);
                // 复位
                setPickerEffect(type, 0);
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

    public int getFilterProgress(int index) {
        return mSzSeekBarValue[ITEM_TYPE_FILTTER][index];
    }

    //设置滤镜
    private void setFilter(int index) {
        Bitmap bmp = getFilterBitmapByIndex(index);
        if (mTRTCCloudManager != null) {
            BeautyConfig params = new BeautyConfig();
            params.mFilterBmp = bmp;
            params.filterIndex = index;
            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_FILTER);
        }
    }

    public void setCurrentFilterIndex(int index) {
        mSzSecondGradleIndex[ITEM_TYPE_FILTTER] = index;
        if (mSencodGradleType == ITEM_TYPE_FILTTER) { //当前就是这个Type
            ViewGroup group = (ViewGroup) mSecondGradlePicker.getChildAt(0);
            for (int i = 0; i < mSecondGradleAdapter.getCount(); i++) {
                View v = group.getChildAt(i);
                if (v instanceof TextView) {
                    if (i == index) {
                        ((TextView) v).setTextColor(mContext.getResources().getColor(R.color.colorAccent));
                    } else {
                        ((TextView) v).setTextColor(Color.WHITE);
                    }
                }
            }

            mThirdGradleIndex = index;
            mThirdGradleSeekBar.setVisibility(View.VISIBLE);
            mSeekBarValue.setVisibility(View.VISIBLE);
            mThirdGradleSeekBar.setProgress(mSzSeekBarValue[ITEM_TYPE_FILTTER][index]);
        }
    }

    //切换采集模式
    private void setCaptureMode(int index) {
        if (mTRTCCloudManager != null) {
            BeautyConfig params = new BeautyConfig();
            params.mCaptureMode = index;
            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_CAPTURE_MODE);
        }
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
        if (mTRTCCloudManager != null) {
            BeautyConfig params = new BeautyConfig();
            params.mGreenFile = file;
            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_GREEN);
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
            if (motionData.motionId.equals("video_pikachu")) {
                Toast.makeText(mContext, "伸出手掌", Toast.LENGTH_SHORT).show();
            }
        }
        String path = motionData.motionPath;
        if (mTRTCCloudManager != null) {
            BeautyConfig params = new BeautyConfig();
            params.mMotionTmplPath = path;
            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_MOTION_TMPL);
        }
    }

    // 设置美颜类型
    private void setBeautyStyle(int index, int beautyLevel) {
        int style = index;
        if (index >= 3) {
            return;
        }
        if (mTRTCCloudManager != null) {
            BeautyConfig params = new BeautyConfig();
            params.mBeautyStyle = style;
            params.mBeautyLevel = beautyLevel;
            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_BEAUTY);
        }
    }

    public void setViewVisibility(int id, int visible) {
        LinearLayout contentLayout = (LinearLayout) getChildAt(0);
        int          count         = contentLayout.getChildCount();
        for (int i = 0; i < count; ++i) {
            View view = contentLayout.getChildAt(i);
            if (view.getId() == id) {
                view.setVisibility(visible);
                return;
            }
        }
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        initSeekBarValue();
        mSzSeekBarValue[mSencodGradleType][mThirdGradleIndex] = progress;   // 记录设置的值
        mSeekBarValue.setText(String.valueOf(progress));

        if (seekBar.getId() == R.id.ThirdGradle_seekbar) {
            if (mSencodGradleType == ITEM_TYPE_BEAUTY) {
                switch (mSencodeGradleArrayString.get(mThirdGradleIndex)) {
                    case "美颜(光滑)":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mBeautyLevel = progress;
                            params.mBeautyStyle = BeautyConfig.BEAUTYPARAM_BEAUTY_STYLE_SMOOTH;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_BEAUTY);
                        }
                        break;
                    case "美颜(自然)":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mBeautyLevel = progress;
                            params.mBeautyStyle = BeautyConfig.BEAUTYPARAM_BEAUTY_STYLE_NATURAL;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_BEAUTY);
                        }
                        break;
                    case "美颜(天天P图)":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mBeautyLevel = progress;
                            params.mBeautyStyle = BeautyConfig.BEAUTYPARAM_BEAUTY_STYLE_HAZY;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_BEAUTY);
                        }
                        break;
                    case "美白":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mWhiteLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_WHITE);
                        }
                        break;
                    case "红润":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mRuddyLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_RUDDY);
                        }
                        break;
                    //                    case "清晰":
                    //                        if (mTRTCCloudManager != null) {
                    //                            BeautyParams params = new BeautyParams();
                    //                            params.mSharpenLevel = progress;
                    //                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_SHARPEN);
                    //                        }
                    //                        break;
                    case "曝光":
                        if (mTRTCCloudManager != null && (0 != progress || mExposureLevel > 0)) {
                            mExposureLevel = progress;
                            BeautyConfig params = new BeautyConfig();
                            params.mExposure = ((float) progress - 10.0f) / 10.0f;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_EXPOSURE);
                        }
                        break;
                    case "大眼":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mBigEyeLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_BIG_EYE);
                        }
                        break;
                    case "瘦脸":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mFaceSlimLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_FACE_LIFT);
                        }
                        break;
                    case "V脸":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mFaceVLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_FACEV);
                        }
                        break;
                    case "下巴":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mChinSlimLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_CHINSLIME);
                        }
                        break;
                    case "短脸":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mFaceShortLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_FACESHORT);
                        }
                        break;
                    case "小鼻":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mNoseScaleLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_NOSESCALE);
                        }
                        break;
                    case "亮眼":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mEyeLightenLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_EYELIGHTEN);
                        }
                        break;
                    case "白牙":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mToothWhitenLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_TOOTHWHITEN);
                        }
                        break;
                    case "祛眼袋":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mPounchRemoveLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_POUNCHREMOVE);
                        }
                        break;
                    case "祛皱":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mWrinkleRemoveLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_WRINKLEREMOVE);
                        }
                        break;
                    case "祛法令纹":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mSmileLinesRemoveLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_SMILELINESREMOVE);
                        }
                        break;
                    case "发际线":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mForeheadLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_FOREHEAD);
                        }
                        break;
                    case "眼距":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mEyeDistanceLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_EYEDISTANCE);
                        }
                        break;
                    case "眼角":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mEyeAngleLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_EYEANGLE);
                        }
                        break;
                    case "嘴型":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mMouthShapeLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_MOUTHSHAPE);
                        }
                        break;
                    case "鼻翼":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mNoseWingLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_NOSEWING);
                        }
                        break;
                    case "鼻子位置":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mNosePositionLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_NOSEPOSITION);
                        }
                        break;
                    case "嘴唇厚度":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mLipsThicknessLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_LIPSTHICKNESS);
                        }
                        break;
                    case "脸型":
                        if (mTRTCCloudManager != null) {
                            BeautyConfig params = new BeautyConfig();
                            params.mFaceBeautyLevel = progress;
                            mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_FACEBEAUTY);
                        }
                        break;
                    default:
                        break;
                }
            } else if (mSencodGradleType == ITEM_TYPE_FILTTER) {
                if (mTRTCCloudManager != null) {
                    BeautyConfig params = new BeautyConfig();
                    params.mFilterMixLevel = progress;
                    mTRTCCloudManager.onBeautyParamsChange(params, BEAUTYPARAM_FILTER_MIX_LEVEL);
                }
            }
        }

    }

    private void initSeekBarValue() {
        if (null == mSzSeekBarValue) {
            mSzSeekBarValue = new int[16][32];
            for (int i = 1; i < mSzSeekBarValue[ITEM_TYPE_FILTTER].length; i++) {
                mSzSeekBarValue[ITEM_TYPE_FILTTER][i] = mFilterBasicLevel; // 一般滤镜的推荐值
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


            for (int i = 0; i < mSzSeekBarValue[ITEM_TYPE_BEAUTY].length; i++) {
                if (i >= mSencodeGradleArrayString.size()) {
                    break;
                }
                switch (mSencodeGradleArrayString.get(i)) {
                    case "美颜(光滑)":
                        mSzSeekBarValue[ITEM_TYPE_BEAUTY][i] = mBeautyBasicLevel;
                        break;
                    case "美颜(自然)":
                        mSzSeekBarValue[ITEM_TYPE_BEAUTY][i] = mBeautyBasicLevel;
                        break;
                    case "美颜(天天P图)":
                        mSzSeekBarValue[ITEM_TYPE_BEAUTY][i] = mBeautyBasicLevel;
                        break;
                    case "美白":
                        mSzSeekBarValue[ITEM_TYPE_BEAUTY][i] = mWhiteBasicLevel;
                        break;
                    case "红润":
                        mSzSeekBarValue[ITEM_TYPE_BEAUTY][i] = mRuddyBasicLevel;
                        break;
                    case "曝光":
                        mSzSeekBarValue[ITEM_TYPE_BEAUTY][i] = mExposureLevel;
                        break;
                    //                    case "清晰":
                    //                        mSzSeekBarValue[ITEM_TYPE_BEAUTY][i] = mSharpenLevel;
                    //                        break;

                    default:
                        break;
                }
            }
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

    public String[] getBeautyFilterArr() {
        return mBeautyFilterTypeString;
    }

    private void updateAdapter(ViewGroup parent, Adapter adapter) {
        if (parent == null || adapter == null) return;
        ViewGroup group = (ViewGroup) parent.getChildAt(0);
        group.removeAllViews();

        for (int i = 0; i < adapter.getCount(); i++) {
            View view = adapter.getView(i, null, group);
            group.addView(view);
        }
    }

    private interface Downloadlistener {
        void onDownloadFail(String errorMsg);

        void onDownloadProgress(final int progress);

        void onDownloadSuccess(String filePath);
    }

    static private interface HttpFileListener {
        public void onProgressUpdate(int progress);

        public void onSaveSuccess(File file);

        public void onSaveFailed(File file, Exception e);

        public void onProcessEnd();
    }

    class MotionData {
        public String motionId;
        public String motionName;
        public String motionUrl;
        public String motionPath;

        public MotionData(String motionId, String motionName, String motionUrl, String motionPath) {
            this.motionId = motionId;
            this.motionName = motionName;
            this.motionUrl = motionUrl;
            this.motionPath = motionPath;
        }
    }

    private class VideoMaterialDownloadProgress {
        public static final String  DOWNLOAD_FILE_POSTFIX  = ".zip";
        public static final String  ONLINE_MATERIAL_FOLDER = "cameraVideoAnimal";
        private final       int     CPU_COUNT              = Runtime.getRuntime().availableProcessors();
        private final       int     CORE_POOL_SIZE         = CPU_COUNT + 1;
        private             Context mContext;
        private             boolean mProcessing;

        private String             mUrl;
        private Downloadlistener   mListener;
        private DownloadThreadPool sDownloadThreadPool;
        private String             mMaterialId;

        public VideoMaterialDownloadProgress(Context context, String materialId, String url) {
            mContext = context;
            this.mMaterialId = materialId;
            this.mUrl = url;
            mProcessing = false;
        }

        public void start(Downloadlistener listener) {
            if (listener == null || TextUtils.isEmpty(mUrl) || mProcessing) {
                return;
            }
            this.mListener = listener;
            mProcessing = true;
            mListener.onDownloadProgress(0);
            HttpFileListener fileListener = new HttpFileListener() {
                @Override
                public void onSaveSuccess(File file) {

                    //删除该素材目录下的旧文件
                    File path = new File(file.toString().substring(0, file.toString().indexOf(DOWNLOAD_FILE_POSTFIX)));
                    if (path.exists() && path.isDirectory()) {
                        File[] oldFiles = path.listFiles();
                        if (oldFiles != null) {
                            for (File f : oldFiles) {
                                f.delete();
                            }
                        }
                    }

                    String dataDir = unZip(file.getPath(), file.getParentFile().getPath());
                    if (TextUtils.isEmpty(dataDir)) {
                        mListener.onDownloadFail("素材解压失败");
                        stop();
                        return;
                    }
                    file.delete();
                    mListener.onDownloadSuccess(dataDir);
                    stop();
                }

                @Override
                public void onSaveFailed(File file, Exception e) {
                    mListener.onDownloadFail("下载失败");
                    stop();
                }

                @Override
                public void onProgressUpdate(int progress) {
                    mListener.onDownloadProgress(progress);
                }

                @Override
                public void onProcessEnd() {
                    mProcessing = false;
                }

            };
            File onlineMaterialDir = getExternalFilesDir(mContext);
            if (onlineMaterialDir == null || onlineMaterialDir.getName().startsWith("null")) {
                mListener.onDownloadFail("存储空间不足");
                stop();
                return;
            }
            if (!onlineMaterialDir.exists()) {
                onlineMaterialDir.mkdirs();
            }

            ThreadPoolExecutor threadPool = getThreadExecutor();
            threadPool.execute(new HttpFileUtil(mContext, mUrl, onlineMaterialDir.getPath(), mMaterialId + DOWNLOAD_FILE_POSTFIX, fileListener, true));
        }

        public void stop() {
            mListener = null;
        }

        public synchronized ThreadPoolExecutor getThreadExecutor() {
            if (sDownloadThreadPool == null || sDownloadThreadPool.isShutdown()) {
                sDownloadThreadPool = new DownloadThreadPool(CORE_POOL_SIZE);
            }
            return sDownloadThreadPool;
        }

        public class DownloadThreadPool extends ThreadPoolExecutor {

            @TargetApi(Build.VERSION_CODES.GINGERBREAD)
            public DownloadThreadPool(int poolSize) {
                super(poolSize, poolSize, 0L, TimeUnit.MILLISECONDS,
                        new LinkedBlockingDeque<Runnable>(),
                        //                    Utils.hasGingerbread() ? new LinkedBlockingDeque<Runnable>() : new LinkedBlockingQueue<Runnable>(),
                        Executors.defaultThreadFactory(), new DiscardOldestPolicy());
            }
        }


    }

    private class TXHorizontalPickerView extends android.widget.HorizontalScrollView {

        private DataSetObserver observer;
        private Adapter         adapter;

        public TXHorizontalPickerView(Context context) {
            super(context);
            initialize();
        }

        public TXHorizontalPickerView(Context context, AttributeSet attrs) {
            super(context, attrs);
            initialize();
        }

        public TXHorizontalPickerView(Context context, AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
            initialize();
        }

        public void setAdapter(Adapter adapter) {
            if (this.adapter != null) {
                this.adapter.unregisterDataSetObserver(observer);
            }
            this.adapter = adapter;
            adapter.registerDataSetObserver(observer);
            updateAdapter();
        }

        private void updateAdapter() {
            ViewGroup group = (ViewGroup) getChildAt(0);
            group.removeAllViews();

            for (int i = 0; i < adapter.getCount(); i++) {
                View view = adapter.getView(i, null, group);
                group.addView(view);
            }
        }

        void initialize() {
            observer = new DataSetObserver() {
                @Override
                public void onChanged() {
                    super.onChanged();
                    updateAdapter();
                }

                @Override
                public void onInvalidated() {
                    super.onInvalidated();
                    ((ViewGroup) getChildAt(0)).removeAllViews();
                }
            };
        }

        public void setClicked(int position) {
            ((ViewGroup) getChildAt(0)).getChildAt(position).performClick();
        }
    }

    private class CustomProgressDialog {
        private Dialog   mDialog;
        private TextView tvMsg;

        /**
         * 得到自定义的progressDialog
         *
         * @param context
         * @param msg
         * @return
         */
        public void createLoadingDialog(Context context, String msg) {

            LayoutInflater inflater = LayoutInflater.from(context);
            View           v        = inflater.inflate(R.layout.layout_loading_progress, null);// 得到加载view
            LinearLayout   layout   = (LinearLayout) v.findViewById(R.id.layout_progress);// 加载布局

            ImageView spaceshipImage = (ImageView) v.findViewById(R.id.progress_img);
            tvMsg = (TextView) v.findViewById(R.id.msg_tv);
            // 加载动画
            Animation hyperspaceJumpAnimation = AnimationUtils.loadAnimation(
                    context, R.anim.load_progress_animation);
            // 使用ImageView显示动画
            spaceshipImage.startAnimation(hyperspaceJumpAnimation);

            mDialog = new Dialog(context, R.style.loading_dialog);// 创建自定义样式dialog

            mDialog.setCancelable(false);// 不可以用“返回键”取消
            mDialog.setContentView(layout, new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.MATCH_PARENT));// 设置布局
        }

        public void setCancelable(boolean cancelable) {
            if (mDialog != null) {
                mDialog.setCancelable(cancelable);
            }
        }

        public void setCanceledOnTouchOutside(boolean canceledOnTouchOutside) {
            if (mDialog != null) {
                mDialog.setCanceledOnTouchOutside(canceledOnTouchOutside);
            }
        }

        public void show() {
            if (mDialog != null) {
                mDialog.show();
            }
        }

        public void dismiss() {
            if (mDialog != null) {
                mDialog.dismiss();
            }
        }

        public void setMsg(String msg) {
            if (tvMsg == null) {
                return;
            }
            if (tvMsg.getVisibility() == View.GONE) {
                tvMsg.setVisibility(View.VISIBLE);
            }
            tvMsg.setText(msg);
        }
    }

    private class HttpFileUtil implements Runnable {

        private static final int TIMEOUT = 30000;

        private static final int BUFFERED_READER_SIZE = 8192;

        private Context          mContext;
        private String           mUrl;
        private String           mFolder;
        private String           mFilename;
        private HttpFileListener mListener;
        private long             mContentLength;
        private long             mDownloadingSize;
        private boolean          mNeedProgress;

        public HttpFileUtil(Context context, String url, String folder, String filename, HttpFileListener listener, boolean needProgress) {
            mContext = context;
            mUrl = url;
            mFolder = folder;
            mFilename = filename;
            mListener = listener;
            mNeedProgress = needProgress;
        }

        @Override
        public void run() {
            if (!isNetworkAvailable(mContext) ||
                    TextUtils.isEmpty(mUrl) || TextUtils.isEmpty(mFolder) || TextUtils.isEmpty(mFilename) || !mUrl.startsWith("http")) {
                fail(null, 0);
                return;
            }
            File dstFolder = new File(mFolder);
            if (!dstFolder.exists()) {
                dstFolder.mkdirs();
            } else {
                if (dstFolder.isFile()) {
                    if (mListener != null) {
                        mListener.onSaveFailed(dstFolder, null);
                        return;
                    }
                }
            }
            File              dstFile       = new File(mFolder + File.separator + mFilename);
            HttpURLConnection client        = null;
            InputStream       responseIs    = null;
            FileOutputStream  fos           = null;
            int               statusCode    = -1;
            boolean           success       = false;
            Exception         failException = null;

            try {
                if (dstFile.exists()) {
                    dstFile.delete();
                }
                dstFile.createNewFile();
                client = (HttpURLConnection) new URL(mUrl).openConnection();

                // 设置网络超时参数
                client.setConnectTimeout(TIMEOUT);
                client.setReadTimeout(TIMEOUT);
                client.setDoInput(true);
                client.setRequestMethod("GET");

                statusCode = client.getResponseCode();
                success = client.getResponseCode() == HttpURLConnection.HTTP_OK;

                if (success) {
                    if (mNeedProgress) {
                        mContentLength = client.getContentLength();
                    }
                    responseIs = client.getInputStream();
                    int    length = -1;
                    byte[] buffer = new byte[BUFFERED_READER_SIZE];
                    fos = new FileOutputStream(dstFile);
                    mDownloadingSize = 0;
                    while ((length = responseIs.read(buffer)) != -1) {
                        fos.write(buffer, 0, length);
                        if (mNeedProgress) {
                            int pre = (int) (mDownloadingSize * 100 / mContentLength);
                            mDownloadingSize += length;
                            int now = (int) (mDownloadingSize * 100 / mContentLength);
                            if (pre != now && mListener != null) {
                                mListener.onProgressUpdate(now);
                            }
                        }
                    }
                    fos.flush();
                    if (mListener != null) {
                        mListener.onProgressUpdate(100);
                        mListener.onSaveSuccess(dstFile);
                    }
                } else {
                    failException = new Exception("http status got exception. code = " + statusCode);
                }
            } catch (Exception e) {
                failException = e;
            } finally {
                try {
                    if (fos != null) {
                        fos.close();
                    }
                    if (responseIs != null) {
                        responseIs.close();
                    }
                    if (client != null) {
                        client.disconnect();
                    }
                    mListener.onProcessEnd();
                } catch (IOException e) {

                }
            }

            if (!success || null != failException) {
                mListener.onSaveFailed(dstFile, null);
            }
        }

        private void fail(Exception e, int statusCode) {
            if (mListener != null) {
                mListener.onSaveFailed(null, e);
            }
            mListener = null;
        }
    }

}
