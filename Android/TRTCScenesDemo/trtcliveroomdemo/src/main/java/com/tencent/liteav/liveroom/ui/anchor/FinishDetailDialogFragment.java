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

    private static final String LIVE_TOTAL_TIME      = "live_total_time";       // KEY，表示本场直播的时长
    private static final String ANCHOR_HEART_COUNT   = "anchor_heart_count";    // KEY，表示本场主播收到赞的数量
    private static final String TOTAL_AUDIENCE_COUNT = "total_audience_count";  // KEY，表示本场观众的总人数

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        final Dialog mDetailDialog = new Dialog(getActivity(), R.style.TRTCLiveRoomDialogFragment);
        mDetailDialog.setContentView(R.layout.trtcliveroom_dialog_publish_detail);
        mDetailDialog.setCancelable(false);

        TextView tvCancel = (TextView) mDetailDialog.findViewById(R.id.btn_anchor_cancel);
        tvCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDetailDialog.dismiss();
                getActivity().finish();
            }
        });

        TextView tvDetailTime = (TextView) mDetailDialog.findViewById(R.id.tv_time);
        TextView tvDetailAdmires = (TextView) mDetailDialog.findViewById(R.id.tv_admires);
        TextView tvDetailWatchCount = (TextView) mDetailDialog.findViewById(R.id.tv_members);

        //确认则显示观看detail
        tvDetailTime.setText(getArguments().getString(LIVE_TOTAL_TIME));
        tvDetailAdmires.setText(getArguments().getString(ANCHOR_HEART_COUNT));
        tvDetailWatchCount.setText(getArguments().getString(TOTAL_AUDIENCE_COUNT));

        return mDetailDialog;
    }
}
