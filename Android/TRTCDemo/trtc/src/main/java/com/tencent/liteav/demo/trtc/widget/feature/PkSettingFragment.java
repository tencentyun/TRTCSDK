package com.tencent.liteav.demo.trtc.widget.feature;

import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.demo.trtc.sdkadapter.ConfigHelper;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.PkConfig;
import com.tencent.liteav.demo.trtc.widget.BaseSettingFragment;

/**
 * PK设置页
 *
 * @author guanyifeng
 */
public class PkSettingFragment extends BaseSettingFragment implements View.OnClickListener {
    private EditText          mRoomIdEt;
    private EditText          mUserIdEt;
    private Button            mConfirmBtn;
    private PkConfig          mPkConfig;
    private PkSettingListener mPkSettingListener;

    public void setPkSettingListener(PkSettingListener pkSettingListener) {
        mPkSettingListener = pkSettingListener;
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    protected void initView(View view) {
        mRoomIdEt = (EditText) view.findViewById(R.id.et_room_id);
        mUserIdEt = (EditText) view.findViewById(R.id.et_user_id);
        mConfirmBtn = (Button) view.findViewById(R.id.btn_confirm);
        mConfirmBtn.setOnClickListener(this);
        mPkConfig = ConfigHelper.getInstance().getPkConfig();

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mRoomIdEt.setText(mPkConfig.getConnectRoomId());
                mUserIdEt.setText(mPkConfig.getConnectUserName());
                if (mPkConfig.isConnected()) {
                    mRoomIdEt.setEnabled(false);
                    mUserIdEt.setEnabled(false);
                    mConfirmBtn.setText("断开连接");
                } else {
                    mRoomIdEt.setEnabled(true);
                    mUserIdEt.setEnabled(true);
                    mConfirmBtn.setText("确认");
                }
            }
        });
    }

    @Override
    protected int getLayoutId() {
        return R.layout.trtc_fragment_pk_setting;
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.btn_confirm) {
            String roomStr  = mRoomIdEt.getText().toString().trim();
            String username = mUserIdEt.getText().toString();
            if (TextUtils.isEmpty(roomStr)) {
                ToastUtils.showLong("请输入房间号");
                return;
            }
            if (TextUtils.isEmpty(username)) {
                ToastUtils.showLong("请输入用户名");
                return;
            }

            try {
                Integer.valueOf(roomStr);
            } catch (Exception e) {
                ToastUtils.showLong("请输入正确的房间号");
                return;
            }
            if (mTRTCCloudManager != null) {
                if (!mPkConfig.isConnected()) {
                    mTRTCCloudManager.startLinkMic(roomStr, username);
                } else {
                    mTRTCCloudManager.stopLinkMic();
                }
            }
            if (mPkSettingListener != null) {
                mPkSettingListener.onPkSettingComplete();
            }
        }
    }

    public interface PkSettingListener {
        void onPkSettingComplete();
    }
}
