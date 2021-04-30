package com.tencent.liteav.liveroom.ui.anchor;

import android.app.Dialog;
import android.app.DialogFragment;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.tencent.liteav.liveroom.R;

public class ConfirmDialogFragment extends DialogFragment {

    private PositiveClickListener mPositiveClickListener;
    private NegativeClickListener mNegativeClickListener;

    private String                mMessageText;
    private String                mPositiveText;
    private String                mNegativeText;

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Dialog dialog = new Dialog(getActivity(), R.style.TRTCLiveRoomDialogFragment);
        dialog.setContentView(R.layout.trtcliveroom_dialog_confirm);
        dialog.setCancelable(false);
        initTextMessage(dialog);
        initButtonPositive(dialog);
        initButtonNegative(dialog);
        return dialog;
    }

    private void initTextMessage(Dialog dialog){
        TextView textMessage = (TextView) dialog.findViewById(R.id.tv_message);
        textMessage.setText(mMessageText);
    }

    private void initButtonPositive(Dialog dialog){
        Button buttonPositive = (Button) dialog.findViewById(R.id.btn_positive);

        if (mPositiveClickListener == null){
            buttonPositive.setVisibility(View.GONE);
            return;
        }
        if (!TextUtils.isEmpty(mPositiveText)) {
            buttonPositive.setText(mPositiveText);
        }
        buttonPositive.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                    mPositiveClickListener.onClick();
            }
        });
    }

    private void initButtonNegative(Dialog dialog){
        Button buttonNegative = (Button) dialog.findViewById(R.id.btn_negative);

        if (mNegativeClickListener == null){
            buttonNegative.setVisibility(View.GONE);
            return;
        }
        if (!TextUtils.isEmpty(mNegativeText)) {
            buttonNegative.setText(mNegativeText);
        }
        buttonNegative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mNegativeClickListener.onClick();
            }
        });
    }

    public void setMessage(String message){
        mMessageText = message;
    }

    public void setPositiveText(String text){
        mPositiveText = text;
    }

    public void setNegativeText(String text){
        mNegativeText = text;
    }

    public void setPositiveClickListener(PositiveClickListener listener) {
        this.mPositiveClickListener = listener;
    }

    public void setNegativeClickListener(NegativeClickListener listener) {
        this.mNegativeClickListener = listener;
    }

    public interface PositiveClickListener {
        void onClick();
    }

    public interface NegativeClickListener {
        void onClick();
    }

}
