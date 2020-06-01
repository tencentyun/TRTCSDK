package com.tencent.liteav.meeting.ui.widget.settingitem;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.blankj.utilcode.util.CollectionUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.rtmp.TXLog;

import java.util.ArrayList;
import java.util.List;

/**
 * 带RadioButton的item
 *
 * @author guanyifeng
 */
public class RadioButtonSettingItem extends BaseSettingItem {
    private static final String TAG = RadioButtonSettingItem.class.getName();

    private RadioItemViewHolder mRadioItemViewHolder;
    private SelectedListener    mSelectedListener;

    public RadioButtonSettingItem(Context context,
                                  @NonNull ItemText itemText,
                                  SelectedListener listener) {
        super(context, itemText);
        mSelectedListener = listener;
        mRadioItemViewHolder = new RadioItemViewHolder(
                mInflater.inflate(R.layout.trtc_item_setting_radio, null)
        );
    }

    public RadioButtonSettingItem setSelect(int index) {
        if (!CollectionUtils.isEmpty(mRadioItemViewHolder.mRadioButtonList)
                && index >= 0 && index < mRadioItemViewHolder.mRadioButtonList.size()) {
            mRadioItemViewHolder.mSelectedIndex = index;
            final RadioButton rb = mRadioItemViewHolder.mRadioButtonList.get(index);
            rb.post(new Runnable() {
                @Override
                public void run() {
                    rb.setChecked(true);
                }
            });
        }
        return this;
    }

    @Override
    public View getView() {
        if (mRadioItemViewHolder != null) {
            return mRadioItemViewHolder.rootView;
        }
        return null;
    }

    public int getSelected() {
        return mRadioItemViewHolder.mSelectedIndex;
    }

    public interface SelectedListener {
        void onSelected(int index);
    }

    public class RadioItemViewHolder {
        public static final int               MIN_SIZE = 2;
        public              View              rootView;
        public              TextView          mTitle;
        public              RadioGroup        mItemRg;
        public              List<RadioButton> mRadioButtonList;
        public              int               mSelectedIndex;

        public RadioItemViewHolder(@NonNull final View itemView) {
            rootView = itemView;
            mTitle = (TextView) itemView.findViewById(R.id.title);
            mItemRg = (RadioGroup) itemView.findViewById(R.id.rg_item);

            if (mItemText == null) {
                TXLog.e(TAG, "item text get null here");
                return;
            }

            mTitle.setText(mItemText.title);
            mRadioButtonList = new ArrayList<>();
            int index = 1;
            for (String text : mItemText.contentText) {
                RadioButton button = createRadioButton(text, mItemRg.hashCode() + index);
                if (index == 1) {
                    button.setChecked(true);
                }
                index++;
                mRadioButtonList.add(button);
                mItemRg.addView(button);
            }

            mItemRg.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(RadioGroup group, int checkedId) {
                    View child = group.findViewById(checkedId);
                    if (!child.isPressed()) {
                        return;
                    }
                    mSelectedIndex = checkedId - mItemRg.hashCode() - 1;
                    TXLog.d(TAG, mTitle.getText() + " select " + mSelectedIndex);
                    if (mSelectedListener != null) {
                        mSelectedListener.onSelected(mSelectedIndex);
                    }
                }
            });
        }

        private RadioButton createRadioButton(String name, int id) {
            RadioButton radioButton = new RadioButton(mContext);
            RadioGroup.LayoutParams mLayoutParams = new RadioGroup.LayoutParams(0,
                    LinearLayout.LayoutParams.WRAP_CONTENT, 1);
            radioButton.setLayoutParams(mLayoutParams);
            radioButton.setClickable(true);
//            radioButton.setBackgroundResource(R.drawable);
            //            radioButton.setButtonDrawable(R.drawable.bg_checkbox);
            radioButton.setId(id);
            radioButton.setText(name);
            radioButton.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15);
            //            radioButton.setTextColor(mContext.getResources().getColor(R.color.colorRadioText));
            radioButton.setGravity(Gravity.CENTER);
            return radioButton;
        }
    }
}
