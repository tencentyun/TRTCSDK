package com.tencent.liteav.demo.beauty;

import android.app.Dialog;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class CustomProgressDialog {
    private Dialog mDialog;
    private TextView tvMsg;

    public void createLoadingDialog(Context context) {
        LayoutInflater inflater = LayoutInflater.from(context);
        View v = inflater.inflate(R.layout.layout_loading_progress, null);
        LinearLayout layout = (LinearLayout) v.findViewById(R.id.layout_progress);

        ImageView spaceshipImage = (ImageView) v.findViewById(R.id.progress_img);
        tvMsg = (TextView) v.findViewById(R.id.msg_tv);
        Animation hyperspaceJumpAnimation = AnimationUtils.loadAnimation(context, R.anim.load_progress_animation);
        spaceshipImage.startAnimation(hyperspaceJumpAnimation);

        mDialog = new Dialog(context, R.style.loading_dialog);
        mDialog.setCancelable(false);
        mDialog.setContentView(layout, new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT));// 设置布局
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
