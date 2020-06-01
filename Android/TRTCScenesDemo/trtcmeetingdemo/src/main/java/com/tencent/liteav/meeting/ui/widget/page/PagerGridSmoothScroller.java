package com.tencent.liteav.meeting.ui.widget.page;

import android.support.annotation.NonNull;
import android.support.v7.widget.LinearSmoothScroller;
import android.support.v7.widget.RecyclerView;
import android.util.DisplayMetrics;
import android.view.View;

/**
 * 作用：用于处理平滑滚动
 * 作者：GcsSloop
 * 摘要：用于用户手指抬起后页面对齐或者 Fling 事件。
 */
public class PagerGridSmoothScroller extends LinearSmoothScroller {
    private RecyclerView mRecyclerView;

    public PagerGridSmoothScroller(@NonNull RecyclerView recyclerView) {
        super(recyclerView.getContext());
        mRecyclerView = recyclerView;
    }

    @Override
    protected void onTargetFound(View targetView, RecyclerView.State state, Action action) {
        RecyclerView.LayoutManager manager = mRecyclerView.getLayoutManager();
        if (null == manager) return;
        if (manager instanceof MeetingPageLayoutManager) {
            MeetingPageLayoutManager layoutManager = (MeetingPageLayoutManager) manager;
            int                      pos           = mRecyclerView.getChildAdapterPosition(targetView);
            int[]                    snapDistances = layoutManager.getSnapOffset(pos);
            final int                dx            = snapDistances[0];
            final int                dy            = snapDistances[1];
            final int                time          = calculateTimeForScrolling(Math.max(Math.abs(dx), Math.abs(dy)));
            if (time > 0) {
                action.update(dx, dy, time, mDecelerateInterpolator);
            }
        }
    }

    @Override
    protected float calculateSpeedPerPixel(DisplayMetrics displayMetrics) {
        return 60f / displayMetrics.densityDpi;
    }
}