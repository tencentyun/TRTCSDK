package com.tencent.liteav.demo.beauty;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.annotation.IntRange;
import android.support.annotation.NonNull;
import android.support.annotation.StringRes;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.widget.Toast;

import com.tencent.liteav.demo.beauty.constant.BeautyConstants;
import com.tencent.liteav.demo.beauty.download.DownloadListener;
import com.tencent.liteav.demo.beauty.download.MaterialDownloader;
import com.tencent.liteav.demo.beauty.model.BeautyInfo;
import com.tencent.liteav.demo.beauty.model.ItemInfo;
import com.tencent.liteav.demo.beauty.model.TabInfo;
import com.tencent.liteav.demo.beauty.utils.BeautyUtils;
import com.tencent.liteav.demo.beauty.utils.ResourceUtils;
import com.tencent.liteav.demo.beauty.utils.SPUtils;
import com.tencent.liteav.demo.beauty.view.ProgressDialog;

import java.util.List;

public class BeautyImpl implements Beauty {

    private static final String TAG = "BeautyImpl";

    private Context         mContext;
    private BeautyParams    mBeautyParams;
    private IBeautyKit      mBeautyKit;

    public BeautyImpl(@NonNull Context context) {
        mContext = context;
        mBeautyParams = new BeautyParams();
    }

    @Override
    public void setBeautyBik(@NonNull IBeautyKit beautyBik) {
        mBeautyKit = beautyBik;
    }

    @Override
    public void setBeautySpecialEffects(@NonNull TabInfo tabinfo, @IntRange(from = 0) int tabPosition, @NonNull ItemInfo itemInfo, @IntRange(from = 0) int itemPosition) {
        dispatchEffects(tabinfo, tabPosition, itemInfo, itemPosition);
    }

    @Override
    public void setBeautyStyleAndLevel(int style, int level) {
        if (mBeautyKit != null) {
            setBeautyStyle(style);
            setBeautyLevel(level);
        }
    }

    @Override
    public void setFilter(Bitmap filterImage, int index) {
        mBeautyParams.mFilterBmp = filterImage;
        mBeautyParams.mFilterIndex = index;
        if (mBeautyKit != null) {
            mBeautyKit.setFilter(filterImage, index);
        }
    }

    @Override
    public void setSpecialRatio(float specialRatio) {
        mBeautyParams.mFilterMixLevel = specialRatio;
        if (mBeautyKit != null) {
            mBeautyKit.setSpecialRatio(specialRatio);
        }
    }

    @Override
    public void setGreenScreenFile(String path, boolean isLoop) {
        mBeautyParams.mGreenFile = path;
        if (mBeautyKit != null) {
            mBeautyKit.setGreenScreenFile(path, true);
        }
    }

    @Override
    public void setBeautyStyle(int beautyStyle) {
        if (beautyStyle >= 3) {
            return;
        }
        mBeautyParams.mBeautyStyle = beautyStyle;
        if (mBeautyKit != null) {
            mBeautyKit.setBeautyStyle(beautyStyle);
        }
    }

    @Override
    public void setBeautyLevel(int beautyLevel) {
        mBeautyParams.mBeautyLevel = beautyLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setBeautyLevel(beautyLevel);
        }
    }

    @Override
    public void setWhitenessLevel(int whitenessLevel) {
        mBeautyParams.mWhiteLevel = whitenessLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setWhitenessLevel(whitenessLevel);
        }
    }

    @Override
    public void setRuddyLevel(int ruddyLevel) {
        mBeautyParams.mRuddyLevel = ruddyLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setRuddyLevel(ruddyLevel);
        }
    }

    @Override
    public void setEyeScaleLevel(int eyeScaleLevel) {
        mBeautyParams.mBigEyeLevel = eyeScaleLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setEyeScaleLevel(eyeScaleLevel);
        }
    }

    @Override
    public void setFaceSlimLevel(int faceSlimLevel) {
        mBeautyParams.mFaceSlimLevel = faceSlimLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setFaceSlimLevel(faceSlimLevel);
        }
    }

    @Override
    public void setFaceVLevel(int faceVLevel) {
        mBeautyParams.mFaceVLevel = faceVLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setFaceVLevel(faceVLevel);
        }
    }

    @Override
    public void setChinLevel(int chinLevel) {
        mBeautyParams.mChinSlimLevel = chinLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setChinLevel(chinLevel);
        }
    }

    @Override
    public void setFaceShortLevel(int faceShortLevel) {
        mBeautyParams.mFaceShortLevel = faceShortLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setFaceShortLevel(faceShortLevel);
        }
    }

    @Override
    public void setNoseSlimLevel(int noseSlimLevel) {
        mBeautyParams.mNoseSlimLevel = noseSlimLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setNoseSlimLevel(noseSlimLevel);
        }
    }

    @Override
    public void setEyeLightenLevel(int eyeLightenLevel) {
        mBeautyParams.mEyeLightenLevel = eyeLightenLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setEyeLightenLevel(eyeLightenLevel);
        }
    }

    @Override
    public void setToothWhitenLevel(int toothWhitenLevel) {
        mBeautyParams.mToothWhitenLevel = toothWhitenLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setToothWhitenLevel(toothWhitenLevel);
        }
    }

    @Override
    public void setWrinkleRemoveLevel(int wrinkleRemoveLevel) {
        mBeautyParams.mWrinkleRemoveLevel = wrinkleRemoveLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setWrinkleRemoveLevel(wrinkleRemoveLevel);
        }
    }

    @Override
    public void setPounchRemoveLevel(int pounchRemoveLevel) {
        mBeautyParams.mPounchRemoveLevel = pounchRemoveLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setPounchRemoveLevel(pounchRemoveLevel);
        }
    }

    @Override
    public void setSmileLinesRemoveLevel(int smileLinesRemoveLevel) {
        mBeautyParams.mSmileLinesRemoveLevel = smileLinesRemoveLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setSmileLinesRemoveLevel(smileLinesRemoveLevel);
        }
    }

    @Override
    public void setForeheadLevel(int foreheadLevel) {
        mBeautyParams.mForeheadLevel = foreheadLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setForeheadLevel(foreheadLevel);
        }
    }

    @Override
    public void setEyeDistanceLevel(int eyeDistanceLevel) {
        mBeautyParams.mEyeDistanceLevel = eyeDistanceLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setEyeDistanceLevel(eyeDistanceLevel);
        }
    }

    @Override
    public void setEyeAngleLevel(int eyeAngleLevel) {
        mBeautyParams.mEyeAngleLevel = eyeAngleLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setEyeAngleLevel(eyeAngleLevel);
        }
    }

    @Override
    public void setMouthShapeLevel(int mouthShapeLevel) {
        mBeautyParams.mMouthShapeLevel = mouthShapeLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setMouthShapeLevel(mouthShapeLevel);
        }
    }

    @Override
    public void setNoseWingLevel(int noseWingLevel) {
        mBeautyParams.mNoseWingLevel = noseWingLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setNoseWingLevel(noseWingLevel);
        }
    }

    @Override
    public void setNosePositionLevel(int nosePositionLevel) {
        mBeautyParams.mNosePositionLevel = nosePositionLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setNosePositionLevel(nosePositionLevel);
        }
    }

    @Override
    public void setLipsThicknessLevel(int lipsThicknessLevel) {
        mBeautyParams.mMouthShapeLevel = lipsThicknessLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setLipsThicknessLevel(lipsThicknessLevel);
        }
    }

    @Override
    public void setFaceBeautyLevel(int faceBeautyLevel) {
        mBeautyParams.mFaceBeautyLevel = faceBeautyLevel;
        if (mBeautyKit != null) {
            mBeautyKit.setFaceBeautyLevel(faceBeautyLevel);
        }
    }

    @Override
    public void setMotionTmpl(String tmplPath) {
        mBeautyParams.mMotionTmplPath = tmplPath;
        if (mBeautyKit != null) {
            mBeautyKit.setMotionTmpl(tmplPath);
        }
    }

    @Override
    public void setMotionMute(boolean motionMute) {

    }

    @Override
    public void setMotionTmplEnable(boolean enable) {
        if (mBeautyKit != null) {
            if (enable) {
                mBeautyKit.setMotionTmpl(null);
            } else {
                mBeautyKit.setMotionTmpl(mBeautyParams.mMotionTmplPath);
            }
        }
    }

    @Override
    public void fillingMaterialPath(@NonNull BeautyInfo beautyInfo) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            List<ItemInfo> tabItemList = tabInfo.getTabItemList();
            for (ItemInfo itemInfo : tabItemList) {
                itemInfo.setItemMaterialPath(SPUtils.get().getString(getMaterialPathKey(itemInfo)));
            }
        }
    }

    @Override
    public void setCurrentFilterIndex(BeautyInfo beautyInfo, int index) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
                ItemInfo itemInfo = tabInfo.getTabItemList().get(index);
                dispatchFilterEffects(itemInfo, index);
            }
        }
    }

    /**
     * 清空美颜配置，如果SDK是新创建的则不需要最后清理，如果SDK是单例，需要调用此方法清空上次设置的美颜参数<br/>
     * 示例：TXUGCRecord是单例，需要调用，TXLivePusher每次创建新的，不需要调用
     */
    @Override
    public void clear() {
        mBeautyParams = new BeautyParams();
        if (mBeautyKit != null) {
            mBeautyKit.setFilter(mBeautyParams.mFilterBmp, mBeautyParams.mFilterIndex);
            mBeautyKit.setSpecialRatio(mBeautyParams.mFilterMixLevel);
            mBeautyKit.setGreenScreenFile(mBeautyParams.mGreenFile, true);
            mBeautyKit.setBeautyStyle(mBeautyParams.mBeautyStyle);
            mBeautyKit.setBeautyLevel(mBeautyParams.mBeautyLevel);
            mBeautyKit.setWhitenessLevel(mBeautyParams.mWhiteLevel);
            mBeautyKit.setRuddyLevel(mBeautyParams.mRuddyLevel);
            mBeautyKit.setEyeScaleLevel(mBeautyParams.mBigEyeLevel);
            mBeautyKit.setFaceSlimLevel(mBeautyParams.mFaceSlimLevel);
            mBeautyKit.setFaceVLevel(mBeautyParams.mFaceVLevel);
            mBeautyKit.setChinLevel(mBeautyParams.mChinSlimLevel);
            mBeautyKit.setFaceShortLevel(mBeautyParams.mFaceShortLevel);
            mBeautyKit.setNoseSlimLevel(mBeautyParams.mNoseSlimLevel);
            mBeautyKit.setEyeLightenLevel(mBeautyParams.mEyeLightenLevel);
            mBeautyKit.setToothWhitenLevel(mBeautyParams.mToothWhitenLevel);
            mBeautyKit.setWrinkleRemoveLevel(mBeautyParams.mWrinkleRemoveLevel);
            mBeautyKit.setPounchRemoveLevel(mBeautyParams.mPounchRemoveLevel);
            mBeautyKit.setSmileLinesRemoveLevel(mBeautyParams.mSmileLinesRemoveLevel);
            mBeautyKit.setForeheadLevel(mBeautyParams.mForeheadLevel);
            mBeautyKit.setEyeDistanceLevel(mBeautyParams.mEyeDistanceLevel);
            mBeautyKit.setEyeAngleLevel(mBeautyParams.mEyeAngleLevel);
            mBeautyKit.setMouthShapeLevel(mBeautyParams.mMouthShapeLevel);
            mBeautyKit.setNoseWingLevel(mBeautyParams.mNoseWingLevel);
            mBeautyKit.setNosePositionLevel(mBeautyParams.mNosePositionLevel);
            mBeautyKit.setLipsThicknessLevel(mBeautyParams.mLipsThicknessLevel);
            mBeautyKit.setFaceBeautyLevel(mBeautyParams.mFaceBeautyLevel);
            mBeautyKit.setMotionTmpl(mBeautyParams.mMotionTmplPath);
        }
    }

    @Override
    public int getFilterProgress(@NonNull BeautyInfo beautyInfo, int index) {
        if (index < 0) {
            return 0;
        }
        List<TabInfo> beautyTabList = beautyInfo.getBeautyTabList();
        for (TabInfo tabInfo : beautyTabList) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
                List<ItemInfo> tabItemList = tabInfo.getTabItemList();
                if (index < tabItemList.size()) {
                    ItemInfo itemInfo = tabItemList.get(index);
                    return itemInfo.getItemLevel();
                } else {
                    return 0;
                }
            }
        }
        return 0;
    }

    @Override
    public ItemInfo getFilterItemInfo(BeautyInfo beautyInfo, int index) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
                return tabInfo.getTabItemList().get(index);
            }
        }
        return null;
    }

    @Override
    public int getFilterSize(@NonNull BeautyInfo beautyInfo) {
        for (TabInfo tabInfo : beautyInfo.getBeautyTabList()) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
                return tabInfo.getTabItemList().size();
            }
        }
        return 0;
    }

    @Override
    public Bitmap getFilterResource(@NonNull BeautyInfo beautyInfo, int index) {
        return decodeFilterResource(getFilterItemInfo(beautyInfo, index));
    }

    @Override
    public BeautyInfo getDefaultBeauty() {
        return BeautyUtils.getDefaultBeautyInfo();
    }

    private void dispatchEffects(@NonNull TabInfo tabInfo, @IntRange(from = 0) int tabPosition, @NonNull ItemInfo itemInfo, @IntRange(from = 0) int itemPosition) {
        int tabType = tabInfo.getTabType();
        switch (tabType) {
            case BeautyConstants.TAB_TYPE_BEAUTY:
                dispatchBeautyEffects(itemInfo);
                break;
            case BeautyConstants.TAB_TYPE_FILTER:
                dispatchFilterEffects(itemInfo, itemPosition);
                break;
            case BeautyConstants.TAB_TYPE_MOTION:
            case BeautyConstants.TAB_TYPE_BEAUTY_FACE:
            case BeautyConstants.TAB_TYPE_GESTURE:
            case BeautyConstants.TAB_TYPE_CUTOUT_BACKGROUND:
                setMaterialEffects(tabInfo, itemInfo);
                break;
            case BeautyConstants.TAB_TYPE_GREEN:
                String file = "";
                if (itemInfo.getItemType() == BeautyConstants.ITEM_TYPE_GREEN_GOOD_LUCK) {
                    file = "green_1.mp4";
                }
                setGreenScreenFile(file, true);
                break;
            default:
                break;
        }
    }

    private void dispatchBeautyEffects(@NonNull ItemInfo itemInfo) {
        int itemType = itemInfo.getItemType();
        int level = itemInfo.getItemLevel();
        switch (itemType) {
            case BeautyConstants.ITEM_TYPE_BEAUTY_SMOOTH:           // 光滑
                setBeautyStyleAndLevel(1, level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_NATURAL:          // 自然
                setBeautyStyleAndLevel(2, level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_PITU:             // 天天p图
                setBeautyStyleAndLevel(3, level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_WHITE:            // 美白
                setWhitenessLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_RUDDY:            // 红润
                setRuddyLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_BIG_EYE:          // 大眼
                setEyeScaleLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACES_LIM:        // 瘦脸
                setFaceSlimLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACEV:            // V脸
                setFaceVLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_CHIN:             // 下巴
                setChinLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACE_SHORT:       // 短脸
                setFaceShortLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_NOSES_LIM:        // 瘦鼻
                setNoseSlimLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_EYE_BRIGHT:       // 亮眼
                setEyeLightenLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_TOOTH_WHITE:      // 白牙
                setToothWhitenLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_WRINKLE_REMOVE:   // 祛皱
                setWrinkleRemoveLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_POUCH_REMOVE:     // 祛眼袋
                setPounchRemoveLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_SMILE_LINES:      // 袪法令纹
                setSmileLinesRemoveLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FOREHEAD:         // 发际线
                setForeheadLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_EYE_DISTANCE:     // 眼距
                setEyeDistanceLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_EYE_ANGLE:        // 眼角
                setEyeAngleLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_MOUTH_SHAPE:      // 嘴型
                setMouthShapeLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_NOSEWING:         // 鼻翼
                setNoseWingLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_NOSE_POSITION:    // 鼻子位置
                setNosePositionLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_MOUSE_WIDTH:      // 嘴唇厚度
                setLipsThicknessLevel(level);
                break;
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACE_SHAPE:       // 脸型
                setFaceBeautyLevel(level);
                break;
        }
    }

    private void dispatchFilterEffects(@NonNull ItemInfo itemInfo, int position) {
        Bitmap bitmap = decodeFilterResource(itemInfo);
        mBeautyParams.mFilterBmp = bitmap;
        mBeautyParams.mFilterIndex = position;
        setFilter(bitmap, position);
        setSpecialRatio(itemInfo.getItemLevel());
    }

    private void setMaterialEffects(@NonNull final TabInfo tabInfo, @NonNull final ItemInfo itemInfo) {
        String itemMaterialPath = itemInfo.getItemMaterialPath();
        if (!TextUtils.isEmpty(itemMaterialPath)) {
            if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_GESTURE
                    && itemInfo.getItemId() == 2) { // 皮卡丘 item 特殊逻辑
                showToast(ResourceUtils.getString(R.string.beauty_palm_out));
            }
            setMotionTmpl(itemMaterialPath);
            return;
        }
        int itemType = itemInfo.getItemType();
        switch (itemType) {
            case BeautyConstants.ITEM_TYPE_MOTION_NONE:
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACE_NONE:
            case BeautyConstants.ITEM_TYPE_GESTURE_NONE:
            case BeautyConstants.ITEM_TYPE_CUTOUT_BACKGROUND_NONE:
                setMotionTmpl("");
                break;
            case BeautyConstants.ITEM_TYPE_MOTION_MATERIAL:
            case BeautyConstants.ITEM_TYPE_BEAUTY_FACE_MATERIAL:
            case BeautyConstants.ITEM_TYPE_GESTURE_MATERIAL:
            case BeautyConstants.ITEM_TYPE_CUTOUT_BACKGROUND_MATERIAL:
                downloadVideoMaterial(tabInfo, itemInfo);
                break;
        }
    }

    private void downloadVideoMaterial(@NonNull final TabInfo tabInfo, @NonNull final ItemInfo itemInfo) {
        MaterialDownloader materialDownloader = new MaterialDownloader(mContext, ResourceUtils.getString(itemInfo.getItemName()), itemInfo.getItemMaterialUrl());
        materialDownloader.start(new DownloadListener() {

            private ProgressDialog mProgressDialog;

            @Override
            public void onDownloadFail(final String errorMsg) {
                ((Activity) mContext).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mProgressDialog != null) {
                            mProgressDialog.dismiss();
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
                        if (mProgressDialog == null) {
                            mProgressDialog = new ProgressDialog();
                            mProgressDialog.createLoadingDialog(mContext);
                            mProgressDialog.setCancelable(false);               // 设置是否可以通过点击Back键取消
                            mProgressDialog.setCanceledOnTouchOutside(false);   // 设置在点击Dialog外是否取消Dialog进度条
                            mProgressDialog.show();
                        }
                        mProgressDialog.setMsg(progress + "%");
                    }
                });
            }

            @Override
            public void onDownloadSuccess(String filePath) {
                itemInfo.setItemMaterialPath(filePath);
                SPUtils.get().put(getMaterialPathKey(itemInfo), filePath);

                ((Activity) mContext).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mProgressDialog != null) {
                            mProgressDialog.dismiss();
                            mProgressDialog = null;
                        }
                        setMaterialEffects(tabInfo, itemInfo);
                    }
                });
            }
        });
    }

    private Bitmap decodeFilterResource(@NonNull ItemInfo itemInfo) {
        int itemType = itemInfo.getItemType();
        int resId = 0;
        switch (itemType) {
            case BeautyConstants.ITEM_TYPE_FILTER_FACE_SHAPE:
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_STANDARD:
                resId = R.drawable.beauty_filter_biaozhun;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_CHEERY:
                resId = R.drawable.beauty_filter_yinghong;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_CLOUD:
                resId = R.drawable.beauty_filter_yunshang;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_PURE:
                resId = R.drawable.beauty_filter_chunzhen;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_ORCHID:
                resId = R.drawable.beauty_filter_bailan;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_VITALITY:
                resId = R.drawable.beauty_filter_yuanqi;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_SUPER:
                resId = R.drawable.beauty_filter_chaotuo;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_FRAGRANCE:
                resId = R.drawable.beauty_filter_xiangfen;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_WHITE:
                resId = R.drawable.beauty_filter_white;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_ROMANTIC:
                resId = R.drawable.beauty_filter_langman;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_FRESH:
                resId = R.drawable.beauty_filter_qingxin;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_BEAUTIFUL:
                resId = R.drawable.beauty_filter_weimei;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_PINK:
                resId = R.drawable.beauty_filter_fennen;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_REMINISCENCE:
                resId = R.drawable.beauty_filter_huaijiu;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_BLUES:
                resId = R.drawable.beauty_filter_landiao;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_COOL:
                resId = R.drawable.beauty_filter_qingliang;
                break;
            case BeautyConstants.ITEM_TYPE_FILTER_JAPANESE:
                resId = R.drawable.beauty_filter_rixi;
                break;
        }
        if (resId != 0) {
            return decodeResource(resId);
        } else {
            return null;
        }
    }

    private Bitmap decodeResource(int id) {
        TypedValue value = new TypedValue();
        ResourceUtils.getResources().openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(ResourceUtils.getResources(), id, opts);
    }

    private String getMaterialPathKey(@NonNull ItemInfo itemInfo) {
        return itemInfo.getItemId() + "-" + itemInfo.getItemType();
    }

    private void showToast(@StringRes int resId) {
        showToast(ResourceUtils.getString(resId));
    }

    private void showToast(@NonNull String text) {
        Toast.makeText(mContext, text, Toast.LENGTH_SHORT).show();
    }
}
