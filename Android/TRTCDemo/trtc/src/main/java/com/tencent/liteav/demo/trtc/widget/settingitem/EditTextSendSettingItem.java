package com.tencent.liteav.demo.trtc.widget.settingitem;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.constraint.Guideline;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.CollectionUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.rtmp.TXLog;

/**
 * 带EditText的item
 *
 * @author guanyifeng
 */
public class EditTextSendSettingItem extends BaseSettingItem {
    private static final String TAG = EditTextSendSettingItem.class.getName();

    private final OnSendListener mListener;

    private ItemViewHolder mItemViewHolder;

    public EditTextSendSettingItem(Context context,
                                   @NonNull ItemText itemText,
                                   OnSendListener listener) {
        super(context, itemText);
        mListener = listener;
        mItemViewHolder = new ItemViewHolder(
                mInflater.inflate(R.layout.trtc_item_setting_edittext, null)
        );
    }

    @Override
    public View getView() {
        if (mItemViewHolder != null) {
            return mItemViewHolder.rootView;
        }
        return null;
    }

    public void setText(final String text) {
        mItemViewHolder.mMessageEt.post(new Runnable() {
            @Override
            public void run() {
                mItemViewHolder.mMessageEt.setText(text);
            }
        });
    }

    public void setButtonText(final String text) {
        mItemViewHolder.mSendBtn.post(new Runnable() {
            @Override
            public void run() {
                mItemViewHolder.mSendBtn.setText(text);
            }
        });
    }

    public EditTextSendSettingItem setButtonVisible(int visibility) {
        mItemViewHolder.mSendBtn.setVisibility(visibility);
        return this;
    }

    public String getText() {
        return mItemViewHolder.mMessageEt.getText().toString();
    }

    public interface OnSendListener {
        void send(String msg);
    }

    public class ItemViewHolder {
        public  View         rootView;
        public  TextView     mTitle;
        public  LinearLayout mItemLl;
        private Guideline    mLGl;
        private Guideline    mRGl;
        private Guideline    mEndGl;
        private EditText     mMessageEt;
        private Button       mSendBtn;

        public ItemViewHolder(@NonNull final View itemView) {
            rootView = itemView;
            mTitle = (TextView) itemView.findViewById(R.id.title);
            mItemLl = (LinearLayout) itemView.findViewById(R.id.ll_item);
            mLGl = (Guideline) itemView.findViewById(R.id.gl_l);
            mRGl = (Guideline) itemView.findViewById(R.id.gl_r);
            mEndGl = (Guideline) itemView.findViewById(R.id.gl_end);
            mMessageEt = (EditText) itemView.findViewById(R.id.et_message);
            mSendBtn = (Button) itemView.findViewById(R.id.btn_send);
            if (mItemText == null) {
                TXLog.e(TAG, "item text get null here");
                return;
            }

            mTitle.setText(mItemText.title);
            if (!CollectionUtils.isEmpty(mItemText.contentText)) {
                String text = mItemText.contentText.get(0);
                if(!TextUtils.isEmpty(text)) {
                    mSendBtn.setText(text);
                }
            }
            mSendBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mListener != null) {
                        mListener.send(mMessageEt.getText().toString().trim());
                    }
                }
            });
        }
    }
}
