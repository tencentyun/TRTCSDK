package com.tencent.liteav.trtcvoiceroom.ui.widget;

import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;

public class SpaceDecoration extends RecyclerView.ItemDecoration {
    private int space;
    private int colNum;

    public SpaceDecoration(int space, int colNum) {
        this.space = space;
        this.colNum = colNum;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        if (parent.getChildLayoutPosition(view) % colNum == 0) {
            outRect.right = space / 2;
            outRect.bottom = space;
        } else {
            outRect.left = space / 2;
            outRect.bottom = space;
        }
    }
}
