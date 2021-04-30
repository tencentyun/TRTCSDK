package com.tencent.liteav.demo.common.widget;

import android.app.Dialog;
import android.app.DialogFragment;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.tencent.liteav.demo.R;

public class ShowTipDialogFragment extends DialogFragment {

    private String                mMessageText;

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Dialog dialog = new Dialog(getActivity(), R.style.TRTCLiveRoomDialogFragment);
        dialog.setContentView(R.layout.app_show_tip_dialog_confirm);
        dialog.setCancelable(false);
        initTextMessage(dialog);
        initButtonNegative(dialog);
        return dialog;
    }

    private void initTextMessage(Dialog dialog){
        TextView textMessage = (TextView) dialog.findViewById(R.id.tv_message);
        textMessage.setText(mMessageText);
    }



    private void initButtonNegative(Dialog dialog){
        Button btnNegative = (Button) dialog.findViewById(R.id.btn_negative);
        btnNegative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
    }

    public void setMessage(String message){
        mMessageText = message;
    }


    public interface PositiveClickListener {
        void onClick();
    }

    public interface NegativeClickListener {
        void onClick();
    }

}

