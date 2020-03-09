package com.tencent.liteav.demo.trtc.widget.settingitem;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.CheckBox;
import android.widget.TextView;

import com.tencent.liteav.demo.trtc.R;
import com.tencent.rtmp.TXLog;

/**
 * 带checkbox的item
 *
 * @author guanyifeng
 */
public class CheckBoxSettingItem extends BaseSettingItem {
    private static final String TAG = RadioButtonSettingItem.class.getName();

    private final ClickListener  mListener;
    private       ItemViewHolder mItemViewHolder;

    public CheckBoxSettingItem(Context context,
                               @NonNull ItemText itemText,
                               ClickListener listener) {
        super(context, itemText);
        mItemViewHolder = new ItemViewHolder(
                mInflater.inflate(R.layout.trtc_item_setting_checkbox, null)
        );
        mListener = listener;
    }

    public CheckBoxSettingItem setCheck(final boolean check) {
        if (mItemViewHolder != null) {
            mItemViewHolder.mItemCb.post(new Runnable() {
                @Override
                public void run() {
                    mItemViewHolder.mItemCb.setChecked(check);
                }
            });
        }
        return this;
    }

    @Override
    public View getView() {
        if (mItemViewHolder != null) {
            return mItemViewHolder.rootView;
        }
        return null;
    }

    public boolean getChecked() {
        return mItemViewHolder.mItemCb.isChecked();
    }

    public interface ClickListener {
        void onClick();
    }

    public class ItemViewHolder {
        public  View     rootView;
        private TextView mTitle;
        private CheckBox mItemCb;

        public ItemViewHolder(@NonNull final View itemView) {
            rootView = itemView;
            mTitle = (TextView) itemView.findViewById(R.id.title);
            mItemCb = (CheckBox) itemView.findViewById(R.id.cb_item);

            if (mItemText == null) {
                TXLog.e(TAG, "item text get null here");
                return;
            }

            mTitle.setText(mItemText.title);
            mItemCb.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mListener != null) {
                        mListener.onClick();
                    }
                }
            });
        }
    }
}
