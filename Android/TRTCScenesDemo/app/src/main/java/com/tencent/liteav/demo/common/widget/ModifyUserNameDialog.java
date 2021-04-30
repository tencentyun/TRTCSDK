package com.tencent.liteav.demo.common.widget;

import android.content.Context;
import android.support.design.widget.BottomSheetDialog;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.R;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.model.UserModel;

public class ModifyUserNameDialog extends BottomSheetDialog {
    private EditText mEditUserName;
    private TextView mTvInputTips;
    private UserModel mUserModel;
    private Context mContext;
    private ModifySuccessListener mListener;


    public ModifyUserNameDialog(Context context, ModifySuccessListener listener) {
        super(context, R.style.AppBottomDialog);
        mUserModel = ProfileManager.getInstance().getUserModel();
        if (mUserModel == null) {
            dismiss();
            return;
        }
        mContext = context;
        mListener = listener;
        setContentView(R.layout.app_view_modify_nickname_dialog);
        mTvInputTips = (TextView) findViewById(R.id.tips);
        mEditUserName = (EditText) findViewById(R.id.et_nickname);
        mEditUserName.setText(mUserModel.userName);
        findViewById(R.id.confirm).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setProfile();
            }
        });
    }

    private void setProfile() {
        String userName = mEditUserName.getText().toString().trim();
        if (TextUtils.isEmpty(userName) || mUserModel.userId == null) {
            ToastUtils.showLong(mContext.getString(R.string.app_toast_set_username));
            return;
        }
        String reg = "^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$";
        if (!userName.matches(reg)) {
            mTvInputTips.setTextColor(mContext.getResources().getColor(R.color.app_color_input_no_match));
            return;
        }
        mTvInputTips.setTextColor(mContext.getResources().getColor(R.color.app_color_input_normal));
        ProfileManager.getInstance().setNickName(userName, new ProfileManager.ActionCallback() {
            @Override
            public void onSuccess() {
                ToastUtils.showLong(mContext.getString(R.string.app_toast_success_to_set_username));
                mListener.onSuccess();
                dismiss();
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(mContext.getString(R.string.app_toast_failed_to_set_username, msg));
            }
        });
    }

    public interface ModifySuccessListener {
        void onSuccess();
    }
}