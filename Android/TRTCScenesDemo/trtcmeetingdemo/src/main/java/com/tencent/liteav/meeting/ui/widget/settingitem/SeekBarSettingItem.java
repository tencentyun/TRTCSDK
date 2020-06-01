package com.tencent.liteav.meeting.ui.widget.settingitem;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.liteav.demo.trtc.R;
import com.tencent.rtmp.TXLog;

/**
 * 带seekbar的item
 *
 * @author guanyifeng
 */
public class SeekBarSettingItem extends BaseSettingItem {
    private static final String TAG = SeekBarSettingItem.class.getName();

    private final Listener       mListener;
    private       ItemViewHolder mItemViewHolder;

    public SeekBarSettingItem(Context context,
                              @NonNull ItemText itemText,
                              Listener listener) {
        super(context, itemText);
        mItemViewHolder = new ItemViewHolder(
                mInflater.inflate(R.layout.trtc_item_setting_seekbar, null)
        );
        mListener = listener;
    }

    public int getMax() {
        return mItemViewHolder.mItemSb.getMax();
    }

    public SeekBarSettingItem setMax(final int max) {
        mItemViewHolder.mItemSb.post(new Runnable() {
            @Override
            public void run() {
                mItemViewHolder.mItemSb.setMax(max);
            }
        });
        return this;
    }

    public int getProgress() {
        return mItemViewHolder.mItemSb.getProgress();
    }

    public SeekBarSettingItem setProgress(final int progress) {
        mItemViewHolder.mItemSb.post(new Runnable() {
            @Override
            public void run() {
                mItemViewHolder.mItemSb.setProgress(progress);
            }
        });
        return this;
    }

    public SeekBarSettingItem setTips(final String tips) {
        mItemViewHolder.mTipsTv.setText(tips);
        return this;
    }

    @Override
    public View getView() {
        if (mItemViewHolder != null) {
            return mItemViewHolder.rootView;
        }
        return null;
    }

    public interface Listener {
        void onSeekBarChange(int progress, boolean fromUser);
    }

    public class ItemViewHolder {
        public View     rootView;
        public TextView mTitle;
        public SeekBar  mItemSb;
        public TextView mTipsTv;

        public ItemViewHolder(@NonNull final View itemView) {
            rootView = itemView;
            mTitle = (TextView) itemView.findViewById(R.id.title);
            mItemSb = (SeekBar) itemView.findViewById(R.id.sb_item);
            mTipsTv = (TextView) itemView.findViewById(R.id.tv_tips);
            if (mItemText == null) {
                TXLog.e(TAG, "item text get null here");
                return;
            }
            mTitle.setText(mItemText.title);
            mItemSb.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    if (mListener != null) {
                        mListener.onSeekBarChange(progress, fromUser);
                    }
                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                }
            });
        }
    }
}
