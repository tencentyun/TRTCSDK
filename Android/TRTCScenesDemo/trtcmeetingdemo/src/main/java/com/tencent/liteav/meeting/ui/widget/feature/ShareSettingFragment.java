package com.tencent.liteav.meeting.ui.widget.feature;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.blankj.utilcode.util.SizeUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.meeting.ui.widget.base.BaseSettingFragment;
import com.tencent.liteav.meeting.ui.widget.settingitem.BaseSettingItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 分享相关配置
 *
 * @author guanyifeng
 */
public class ShareSettingFragment extends BaseSettingFragment implements View.OnClickListener {
    private static final String TAG = ShareSettingFragment.class.getName();

    private LinearLayout          mContentItem;
    private ImageView             mQrImg;
    private Button                mShare;
    private List<BaseSettingItem> mSettingItemList;
    private String                mPlayUrl;

    @Override
    protected void initView(View itemView) {
        mContentItem = (LinearLayout) itemView.findViewById(R.id.item_content);
        mQrImg = (ImageView) itemView.findViewById(R.id.img_qr);
        mShare = (Button) itemView.findViewById(R.id.share);
        mShare.setOnClickListener(this);

        mSettingItemList = new ArrayList<>();

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(5), 0, 0);
            mContentItem.addView(view);
        }

        updateQrView();
    }

    private void updateQrView() {
        mPlayUrl = getPlayUrl();
        if (mQrImg == null) {
            return;
        }
        if (TextUtils.isEmpty(mPlayUrl)) {
            mQrImg.setVisibility(View.GONE);
            mShare.setVisibility(View.GONE);
            return;
        } else {
            mQrImg.setVisibility(View.VISIBLE);
            mShare.setVisibility(View.VISIBLE);
        }
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                final Bitmap bitmap = createQRCodeBitmap(mPlayUrl, 400, 400);
                mQrImg.post(new Runnable() {
                    @Override
                    public void run() {
                        mQrImg.setImageBitmap(bitmap);
                    }
                });
            }
        });
    }

    private String getPlayUrl() {
        return mTRTCMeeting.getLiveBroadcastingURL();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.meeting_fragment_share_setting;
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.share) {
            if (TextUtils.isEmpty(mPlayUrl)) {
                ToastUtils.showShort(getString(R.string.meeting_toast_play_url_not_null));
                return;
            }
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.putExtra(Intent.EXTRA_TEXT, mPlayUrl);
            intent.setType("text/plain");
            startActivity(Intent.createChooser(intent, getString(R.string.meeting_title_sharing)));
        }
    }

    private Bitmap createQRCodeBitmap(String content, int widthPix, int heightPix) {
        try {
            if (content == null || "".equals(content)) {
                return null;
            }
            //配置参数
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
            //容错级别
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);

            // 图像数据转换，使用了矩阵转换
            BitMatrix bitMatrix = new QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, widthPix, heightPix, hints);
            int[]     pixels    = new int[widthPix * heightPix];
            // 下面这里按照二维码的算法，逐个生成二维码的图片，
            // 两个for循环是图片横列扫描的结果
            for (int y = 0; y < heightPix; y++) {
                for (int x = 0; x < widthPix; x++) {
                    if (bitMatrix.get(x, y)) {
                        pixels[y * widthPix + x] = 0xff000000;
                    } else {
                        pixels[y * widthPix + x] = 0xffffffff;
                    }
                }
            }
            // 生成二维码图片的格式，使用ARGB_8888
            Bitmap bitmap = Bitmap.createBitmap(widthPix, heightPix, Bitmap.Config.ARGB_8888);
            bitmap.setPixels(pixels, 0, widthPix, 0, 0, widthPix, heightPix);
            return bitmap;
        } catch (WriterException e) {
            e.printStackTrace();
        }
        return null;
    }
}
