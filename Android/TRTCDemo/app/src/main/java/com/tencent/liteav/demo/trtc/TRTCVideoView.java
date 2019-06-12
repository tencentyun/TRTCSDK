package com.tencent.liteav.demo.trtc;

import android.content.Context;
import android.os.Build;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 *  概述：
 *  此 TRTCVideoView 继承自 SDK 的 View 类{@link TXCloudVideoView}
 *  搭配 {@link TRTCVideoViewLayout} 可实现自由拖动
 *
 *  作用：
 *  可以实现自由拖动 View 的位置
 *
 *  使用要求：
 *  1. 此 View 的父容器目前仅兼容了 RelativeLayout ，在此容器下能够很容易实现拖动。
 *
 *  2. 此 View 的属性不能使用 {@link RelativeLayout.LayoutParams#addRule(int)} 方法，进行定位。需要手动计算所有的 margin left、right、top、bottom；
 *     可参考 {@link TRTCVideoViewLayout#initFloatLayoutParams()} 实现。
 */
public class TRTCVideoView extends TXCloudVideoView {
    private static final String TAG = "TRTCCloudVideoView";
    private OnClickListener mClickListener;
    private GestureDetector mSimpleOnGestureListener;

    public TRTCVideoView(Context context) {
        this(context, null);
    }

    public TRTCVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mSimpleOnGestureListener = new GestureDetector(context, new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                if (mClickListener != null) {
                    mClickListener.onClick(TRTCVideoView.this);
                }
                return true;
            }

            @Override
            public boolean onDown(MotionEvent e) {
                return true;
            }

            @Override
            public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
                if (!mMoveable) return false;
                ViewGroup.LayoutParams params = TRTCVideoView.this.getLayoutParams();
                // 当 TRTCVideoView 的父容器是 RelativeLayout 的时候，可以实现拖动
                if (params instanceof RelativeLayout.LayoutParams) {
                    RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) TRTCVideoView.this.getLayoutParams();
                    int newX = (int) (layoutParams.leftMargin + (e2.getX() - e1.getX()));
                    int newY = (int) (layoutParams.topMargin + (e2.getY() - e1.getY()));

                    layoutParams.leftMargin = newX;
                    layoutParams.topMargin = newY;

                    TRTCVideoView.this.setLayoutParams(layoutParams);
                }
                return true;
            }
        });
        this.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return mSimpleOnGestureListener.onTouchEvent(event);
            }
        });
    }

    @Override
    public void setOnClickListener(@Nullable OnClickListener l) {
        mClickListener = l;
    }

    private boolean mMoveable;

    public void setMoveable(boolean enable) {
        mMoveable = enable;
    }
}
