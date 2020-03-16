package com.tencent.live;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

/**
 * 直播场景下，选择分辨率的底部Dialog
 */
public class LiveBottomDialog {

    private Context mContext;
    private Dialog mDialog;
    private TextView mTextTitle;
    private TextView mTextCancel;
    private LinearLayout mLayoutContent;
    private boolean mShowTitle = false;
    private List<DialogItem> mDialogItemList;
    private Display mDisplay;

    public LiveBottomDialog(Context context) {
        this.mContext = context;
        WindowManager windowManager = (WindowManager) context
                .getSystemService(Context.WINDOW_SERVICE);
        mDisplay = windowManager.getDefaultDisplay();
    }

    public LiveBottomDialog builder() {
        View view = LayoutInflater.from(mContext).inflate(
                R.layout.live_bottom_dialog_item, null);

        view.setMinimumWidth(mDisplay.getWidth());

        mLayoutContent = view.findViewById(R.id.ll_content);
        mTextTitle = view.findViewById(R.id.txt_title);
        mTextCancel = view.findViewById(R.id.txt_cancel);
        mTextCancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });

        mDialog = new Dialog(mContext, R.style.DialogStyle);
        mDialog.setContentView(view);
        Window dialogWindow = mDialog.getWindow();
        dialogWindow.setGravity(Gravity.LEFT | Gravity.BOTTOM);
        WindowManager.LayoutParams lp = dialogWindow.getAttributes();
        lp.x = 0;
        lp.y = 0;
        dialogWindow.setAttributes(lp);
        return this;
    }

    public LiveBottomDialog setTitle(String title) {
        mShowTitle = true;
        mTextTitle.setVisibility(View.VISIBLE);
        mTextTitle.setText(title);
        return this;
    }

    public LiveBottomDialog setCancelable(boolean cancel) {
        mDialog.setCancelable(cancel);
        return this;
    }

    public LiveBottomDialog setCanceledOnTouchOutside(boolean cancel) {
        mDialog.setCanceledOnTouchOutside(cancel);
        return this;
    }


    public LiveBottomDialog addDialogItem(String strItem, DialogItemColor color,
                                          OnDialogItemClickListener listener) {
        if (mDialogItemList == null) {
            mDialogItemList = new ArrayList<>();
        }
        mDialogItemList.add(new DialogItem(strItem, color, listener));
        return this;
    }

    private void setDialogItems() {
        if (mDialogItemList == null || mDialogItemList.size() <= 0) {
            return;
        }

        int size = mDialogItemList.size();

        for (int i = 1; i <= size; i++) {
            final int index = i;
            DialogItem dialogItem = mDialogItemList.get(i - 1);
            String strItem = dialogItem.name;
            DialogItemColor color = dialogItem.color;
            final OnDialogItemClickListener listener = dialogItem.itemClickListener;

            TextView textView = new TextView(mContext);
            textView.setText(strItem);
            textView.setTextSize(18);
            textView.setGravity(Gravity.CENTER);

            if (size == 1) {
                if (mShowTitle) {
                    textView.setBackgroundResource(R.drawable.live_dialog_bottom_selector);
                } else {
                    textView.setBackgroundResource(R.drawable.live_dialog_single_selector);
                }
            } else {
                if (mShowTitle) {
                    if (i >= 1 && i < size) {
                        textView.setBackgroundResource(R.drawable.live_dialog_middle_selector);
                    } else {
                        textView.setBackgroundResource(R.drawable.live_dialog_bottom_selector);
                    }
                } else {
                    if (i == 1) {
                        textView.setBackgroundResource(R.drawable.live_dialog_top_selector);
                    } else if (i < size) {
                        textView.setBackgroundResource(R.drawable.live_dialog_middle_selector);
                    } else {
                        textView.setBackgroundResource(R.drawable.live_dialog_bottom_selector);
                    }
                }
            }

            if (color == null) {
                textView.setTextColor(Color.parseColor(DialogItemColor.Blue
                        .getName()));
            } else {
                textView.setTextColor(Color.parseColor(color.getName()));
            }

            float scale = mContext.getResources().getDisplayMetrics().density;
            int height = (int) (45 * scale + 0.5f);
            textView.setLayoutParams(new LayoutParams(
                    LayoutParams.MATCH_PARENT, height));

            textView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onClick(index);
                    mDialog.dismiss();
                }
            });

            mLayoutContent.addView(textView);
        }
    }

    public void show() {
        setDialogItems();
        mDialog.show();
    }

    public interface OnDialogItemClickListener {
        void onClick(int which);
    }

    public class DialogItem {
        String name;
        OnDialogItemClickListener itemClickListener;
        DialogItemColor color;

        public DialogItem(String name, DialogItemColor color,
                          OnDialogItemClickListener itemClickListener) {
            this.name = name;
            this.color = color;
            this.itemClickListener = itemClickListener;
        }
    }

    public enum DialogItemColor {
        Blue("#037BFF");
        private String name;

        DialogItemColor(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }
    }
}
