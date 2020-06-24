package com.tencent.liteav.liveroom.ui.widget;

import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;

public class SpaceDecoration extends RecyclerView.ItemDecoration {
    private int mSpace;
    private int mColNum;

    public SpaceDecoration(int space, int colNum) {
        this.mSpace = space;
        this.mColNum = colNum;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        if (parent.getChildLayoutPosition(view) % mColNum == 0) {
            outRect.set(mSpace, 0, 0, mSpace);
        } else {
            outRect.set(mSpace, 0, 0, mSpace);
        }
    }
}
