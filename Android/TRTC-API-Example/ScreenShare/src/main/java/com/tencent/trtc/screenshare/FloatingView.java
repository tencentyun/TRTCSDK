package com.tencent.trtc.screenshare;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.PixelFormat;
import android.graphics.drawable.BitmapDrawable;
import android.os.Build;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.PopupWindow;

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class FloatingView extends FrameLayout implements GestureDetector.OnGestureListener {

    private Context                     mContext;
    private WindowManager               mWindowManager;
    private GestureDetector             mGestureDetector;
    private WindowManager.LayoutParams  mLayoutParams;
    private float                       mLastX;
    private float                       mLastY;
    private PopupWindow                 mPopupWindow;
    private long                        mTapOutsideTime;
    private boolean                     mIsShowing = false;

    public FloatingView(Context context) {
        super(context);
        this.mContext = context;
        this.mGestureDetector = new GestureDetector(context, this);
    }

    public FloatingView(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.mContext = context;
        this.mGestureDetector = new GestureDetector(context, this);
    }

    public FloatingView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.mContext = context;
        this.mGestureDetector = new GestureDetector(context, this);
    }

    public FloatingView(Context context, int viewResId) {
        super(context);
        this.mContext = context;
        View.inflate(context, viewResId, this);
        this.mGestureDetector = new GestureDetector(context, this);
    }

    public void showView(View view) {
        showView(view, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
    }

    public void showView(View view, int width, int height) {
        mWindowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
        int type = WindowManager.LayoutParams.TYPE_TOAST;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N) {
            type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        mLayoutParams = new WindowManager.LayoutParams(type);
        mLayoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        mLayoutParams.flags |= WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH;
        mLayoutParams.width = width;
        mLayoutParams.height = height;
        mLayoutParams.format = PixelFormat.TRANSLUCENT;
        mWindowManager.addView(view, mLayoutParams);
    }

    public void hideView() {
        if (null != mWindowManager) {
            mWindowManager.removeViewImmediate(this);
        }
        mWindowManager = null;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return mGestureDetector.onTouchEvent(event);
    }

    @Override
    public boolean onDown(MotionEvent e) {
        mLastX = e.getRawX();
        mLastY = e.getRawY();
        return false;
    }

    @Override
    public void onShowPress(MotionEvent e) {
    }

    @Override
    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
        float nowX, nowY, tranX, tranY;
        nowX = e2.getRawX();
        nowY = e2.getRawY();
        tranX = nowX - mLastX;
        tranY = nowY - mLastY;
        mLayoutParams.x += tranX;
        mLayoutParams.y += tranY;
        mWindowManager.updateViewLayout(this, mLayoutParams);
        mLastX = nowX;
        mLastY = nowY;
        return false;
    }

    @Override
    public void onLongPress(MotionEvent e) {
    }

    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
        return false;
    }

    public void setPopupWindow(int id) {
        mPopupWindow = new PopupWindow(this);
        mPopupWindow.setWidth(ViewGroup.LayoutParams.WRAP_CONTENT);
        mPopupWindow.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        mPopupWindow.setTouchable(true);
        mPopupWindow.setOutsideTouchable(true);
        mPopupWindow.setFocusable(false);
        mPopupWindow.setBackgroundDrawable(new BitmapDrawable());
        mPopupWindow.setContentView(LayoutInflater.from(getContext()).inflate(id, null));
        mPopupWindow.setTouchInterceptor(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_OUTSIDE) {
                    mPopupWindow.dismiss();
                    mTapOutsideTime = System.currentTimeMillis();
                    return true;
                }
                return false;
            }
        });
    }

    public View getPopupView() {
        return mPopupWindow.getContentView();
    }

    public void setOnPopupItemClickListener(View.OnClickListener listener) {
        if (mPopupWindow == null)
            return;

        ViewGroup layout = (ViewGroup) mPopupWindow.getContentView();
        for (int i = 0; i < layout.getChildCount(); i++) {
            layout.getChildAt(i).setOnClickListener(listener);
        }
    }

    public void show() {
        if (!mIsShowing) {
            showView(this);
        }
        mIsShowing = true;
    }

    public void dismiss() {
        if (mIsShowing) {
            hideView();
        }
        mIsShowing = false;
        ViewGroup layout = (ViewGroup) mPopupWindow.getContentView();
        for (int i = 0; i < layout.getChildCount(); i++) {
            layout.getChildAt(i).setOnClickListener(null);
        }
    }

    @Override
    public boolean onSingleTapUp(MotionEvent e) {
        if (null != mPopupWindow)
            mPopupWindow.dismiss();
        if (!(System.currentTimeMillis() - mTapOutsideTime < 80)) {
            mPopupWindow.showAtLocation(this, Gravity.NO_GRAVITY, 100, 0);
        }
        return false;
    }


}
