package com.tencent.liteav.trtcvideocalldemo.ui;

import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.UserModel;
import com.tencent.liteav.trtcvideocalldemo.R;
import com.tencent.liteav.trtcvideocalldemo.model.ITRTCVideoCall;
import com.tencent.liteav.trtcvideocalldemo.model.TRTCVideoCallImpl;
import com.tencent.liteav.trtcvideocalldemo.model.TRTCVideoCallListener;

import java.util.List;
import java.util.Map;

/**
 * 用于展示历史联系人的界面，目前只有发起通话功能
 *
 * @author guanyifeng
 */
public class TRTCVideoCallHistoryActivity extends AppCompatActivity {
    private static final String TAG = "TRTCVideoCallHistoryActivity";

    private ImageView mStartNewCallImg;
    private TextView  mStartNewCallTv;
    private Toolbar   mToolbar;

    private ITRTCVideoCall        mITRTCVideoCall;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.videocall_activity_call_history);
        initView();
        initPermission();
    }

    private void initPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void initView() {
        mStartNewCallImg = (ImageView) findViewById(R.id.img_start_new_call);
        mStartNewCallTv = (TextView) findViewById(R.id.tv_start_new_call);

        mStartNewCallImg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SelectContactActivity.start(TRTCVideoCallHistoryActivity.this);
            }
        });
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }
}
