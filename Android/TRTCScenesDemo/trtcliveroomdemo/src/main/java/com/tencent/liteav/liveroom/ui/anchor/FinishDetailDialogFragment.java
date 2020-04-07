package com.tencent.liteav.liveroom.ui.anchor;

import android.app.Dialog;
import android.app.DialogFragment;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.tencent.liteav.liveroom.R;

/**
 * Module:   FinishDetailDialogFragment
 * <p>
 * Function: 推流结束的详情页
 * <p>
 * 统计了观看人数、点赞数量、开播时间
 */
public class FinishDetailDialogFragment extends DialogFragment {

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Dialog mDetailDialog = new Dialog(getActivity(), R.style.liveroom_dialog_fragment);
        mDetailDialog.setContentView(R.layout.liveroom_dialog_publish_detail);
        mDetailDialog.setCancelable(false);

        TextView tvCancel = (TextView) mDetailDialog.findViewById(R.id.anchor_btn_cancel);
        tvCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDetailDialog.dismiss();
                getActivity().finish();
            }
        });

        TextView tvDetailTime       = (TextView) mDetailDialog.findViewById(R.id.tv_time);
        TextView tvDetailAdmires    = (TextView) mDetailDialog.findViewById(R.id.tv_admires);
        TextView tvDetailWatchCount = (TextView) mDetailDialog.findViewById(R.id.tv_members);

        //确认则显示观看detail
        tvDetailTime.setText(getArguments().getString("time"));
        tvDetailAdmires.setText(getArguments().getString("heartCount"));
        tvDetailWatchCount.setText(getArguments().getString("totalMemberCount"));

        return mDetailDialog;
    }
}
