package com.tencent.liteav.demo.trtc.widget;

import android.app.Dialog;
import android.content.Context;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;

import com.tencent.liteav.demo.R;

import java.util.ArrayList;

/**
 * Module:   TRTCUserSelectDialog
 *
 * Function: 单选框用于选择userid
 *
 */
public class TRTCUserSelectDialog extends Dialog implements RadioGroup.OnCheckedChangeListener {
    private RadioGroup rgMain;
    private ArrayList<RadioButton> rbList;
    private onItemClickListener itemListener;

    public interface onItemClickListener{
        void onItemClick(int position);
    }

    public TRTCUserSelectDialog(Context context, ArrayList<String> menus) {
        super(context, R.style.common_dlg);

        ScrollView scrollView = new ScrollView(context);
        rgMain = new RadioGroup(context);
        scrollView.addView(rgMain,
                new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        setContentView(scrollView);

        rgMain.setOrientation(LinearLayout.VERTICAL);
        rgMain.setOnCheckedChangeListener(this);
        initMenus(menus);
    }

    @Override
    public void onCheckedChanged(RadioGroup radioGroup, int btnId) {
        if (null != itemListener){
            for (int i=0; i<rbList.size(); i++){
                if (rbList.get(i).getId() == btnId){
                    itemListener.onItemClick(i);
                    break;
                }
            }
        }
        dismiss();
    }

    public void setOnItemClickListener(onItemClickListener listener){
        itemListener = listener;
    }

    private void initMenus(ArrayList<String> menus){
        RadioGroup.LayoutParams layoutParams = new RadioGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        layoutParams.setMargins(5, 10, 5, 10);
        rbList = new ArrayList<>();
        for (String menu : menus){
            RadioButton rbMenu = new RadioButton(getContext());
            rbMenu.setText(menu);
            rbList.add(rbMenu);
            rgMain.addView(rbMenu, layoutParams);
        }
    }
}
