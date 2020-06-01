package com.tencent.liteav.meeting.ui.widget.settingitem;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;

import com.tencent.liteav.demo.trtc.R;
import com.tencent.rtmp.TXLog;

/**
 * 带selection的item
 *
 * @author guanyifeng
 */
public class SelectionSettingItem extends BaseSettingItem {
    private static final String TAG = SelectionSettingItem.class.getName();

    private final Listener       mListener;
    private       ItemViewHolder mItemViewHolder;

    public SelectionSettingItem(Context context,
                                @NonNull ItemText itemText,
                                Listener listener) {
        super(context, itemText);
        mItemViewHolder = new ItemViewHolder(
                mInflater.inflate(R.layout.trtc_item_setting_selection, null)
        );
        mListener = listener;
    }

    public SelectionSettingItem setSelect(final int index) {
        if (mItemViewHolder == null) {
            return this;
        }
        mItemViewHolder.mItemSp.post(new Runnable() {
            @Override
            public void run() {
                mItemViewHolder.mItemSp.setSelection(index);
            }
        });
        return this;
    }

    @Override
    public View getView() {
        if (mItemViewHolder != null) {
            return mItemViewHolder.rootView;
        }
        return null;
    }

    public int getSelected() {
        return mItemViewHolder.mItemSp.getSelectedItemPosition();
    }

    public interface Listener {
        void onItemSelected(int position, String text);
    }

    public class ItemViewHolder {
        public  View                 rootView;
        public  ArrayAdapter<String> mAdapter;
        private TextView             mTitle;
        private Spinner              mItemSp;
        private SpinnerListener      mSpinnerListener;

        public ItemViewHolder(@NonNull final View itemView) {
            rootView = itemView;
            mTitle = (TextView) itemView.findViewById(R.id.title);
            mItemSp = (Spinner) itemView.findViewById(R.id.sp_item);

            if (mItemText == null) {
                TXLog.e(TAG, "item text get null here");
                return;
            }
            mTitle.setText(mItemText.title);
            mAdapter = new ArrayAdapter<>(mContext, R.layout.trtc_item_setting_selection_textview, mItemText.contentText);
            mItemSp.setAdapter(mAdapter);
            mSpinnerListener = new SpinnerListener();
            mItemSp.setOnTouchListener(mSpinnerListener);
            mItemSp.setOnItemSelectedListener(mSpinnerListener);
        }
    }

    public class SpinnerListener implements AdapterView.OnItemSelectedListener, View.OnTouchListener {
        private boolean fromUser = false;

        @Override
        public boolean onTouch(View v, MotionEvent event) {
            fromUser = true;
            return false;
        }

        @Override
        public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
            if (fromUser) {
                fromUser = false;
                if (mListener != null) {
                    mListener.onItemSelected(position, mItemText.contentText.get(position));
                }
            }
        }

        @Override
        public void onNothingSelected(AdapterView<?> parent) {

        }
    }
}
