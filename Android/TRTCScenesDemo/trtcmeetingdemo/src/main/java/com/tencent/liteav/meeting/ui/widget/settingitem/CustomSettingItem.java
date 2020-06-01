package com.tencent.liteav.meeting.ui.widget.settingitem;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.constraint.Guideline;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.liteav.demo.trtc.R;
import com.tencent.rtmp.TXLog;

import java.util.List;

/**
 * 可自己定制的settingitem
 *
 * @author guanyifeng
 */
public class CustomSettingItem extends BaseSettingItem {
    public static final  int        ALIGN_LEFT   = 1;
    public static final  int        ALIGN_RIGHT  = 2;
    public static final  int        ALIGN_CENTER = 3;
    private static final String     TAG          = CustomSettingItem.class.getName();
    private final        List<View> mViewList;

    private ItemViewHolder mItemViewHolder;

    public CustomSettingItem(Context context,
                             @NonNull ItemText itemText,
                             List<View> viewList) {
        super(context, itemText);
        mViewList = viewList;
        mItemViewHolder = new ItemViewHolder(
                mInflater.inflate(R.layout.trtc_item_setting_custom, null)
        );
    }

    /**
     * 对齐模式，xml中默认是right
     * 界面中的 ll_item 按如下分布
     * gl_l   gl_r    gl_end
     * | left | right |
     * |    center    |
     */
    public void setAlign(int align) {
        mItemViewHolder.setAlign(align);
    }

    @Override
    public View getView() {
        if (mItemViewHolder != null) {
            return mItemViewHolder.rootView;
        }
        return null;
    }

    public class ItemViewHolder {
        public  View         rootView;
        public  TextView     mTitle;
        public  LinearLayout mItemLl;
        private Guideline    mLGl;
        private Guideline    mRGl;
        private Guideline    mEndGl;

        public ItemViewHolder(@NonNull final View itemView) {
            rootView = itemView;
            mTitle = (TextView) itemView.findViewById(R.id.title);
            mItemLl = (LinearLayout) itemView.findViewById(R.id.ll_item);
            mLGl = (Guideline) itemView.findViewById(R.id.gl_l);
            mRGl = (Guideline) itemView.findViewById(R.id.gl_r);
            mEndGl = (Guideline) itemView.findViewById(R.id.gl_end);

            if (mItemText == null) {
                TXLog.e(TAG, "item text get null here");
                return;
            }

            mTitle.setText(mItemText.title);
            for (View view : mViewList) {
                mItemLl.addView(view);
            }
        }

        public void setAlign(int align) {
            ConstraintLayout.LayoutParams layoutParams = new ConstraintLayout.LayoutParams(mItemLl.getLayoutParams());
            if (align == ALIGN_CENTER) {
                layoutParams.startToStart = R.id.gl_l;
                layoutParams.endToEnd = R.id.gl_end;
            } else if (align == ALIGN_RIGHT) {
                layoutParams.startToStart = R.id.gl_r;
                layoutParams.endToEnd = R.id.gl_end;
            } else if (align == ALIGN_LEFT) {
                layoutParams.startToStart = R.id.gl_l;
                layoutParams.endToEnd = R.id.gl_r;
            }
            layoutParams.topToTop = ConstraintLayout.LayoutParams.PARENT_ID;
            layoutParams.bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID;
            mItemLl.setLayoutParams(layoutParams);
        }
    }
}
