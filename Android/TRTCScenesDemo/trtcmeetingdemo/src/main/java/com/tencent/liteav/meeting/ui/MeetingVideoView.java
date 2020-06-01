package com.tencent.liteav.meeting.ui;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import com.tencent.rtmp.ui.TXCloudVideoView;

import java.lang.ref.WeakReference;

/**
 * 用来展示自己和远端的 TXCloudVideoView
 */
public class MeetingVideoView extends TXCloudVideoView {
    private static final String TAG = "MeetingVideoView";

    private Listener                 mListener;
    private GestureDetector          mSimpleOnGestureListener;
    private boolean                  isPlaying;
    private WeakReference<ViewGroup> preViewGroup;
    private ViewGroup                curViewGroup;
    private ViewGroup                waitBindGroup;
    private SurfaceView              mSurfaceView;
    private boolean                  isSelfView;
    private String                   mMeetingUserId;
    private boolean                  mNeedAttach = false;

    public boolean isNeedAttach() {
        return mNeedAttach;
    }

    public void setNeedAttach(boolean needAttach) {
        this.mNeedAttach = needAttach;
    }

    public boolean isPlaying() {
        return isPlaying;
    }

    public void setPlayingWithoutSetVisible(boolean playing) {
        isPlaying = playing;
    }

    public void setPlaying(boolean playing) {
        Log.d(TAG, "setPlaying: " + getMeetingUserId() + " " + playing);
        isPlaying = playing;
        if (!isPlaying) {
            setVisibility(GONE);
        } else {
            setVisibility(VISIBLE);
        }
    }

    public String getMeetingUserId() {
        return mMeetingUserId;
    }

    public void setMeetingUserId(String meetingUserId) {
        mMeetingUserId = meetingUserId;
    }

    public boolean isSelfView() {
        return isSelfView;
    }

    public void setSelfView(boolean selfView) {
        isSelfView = selfView;
        if (mSurfaceView == null && isSelfView) {
            mSurfaceView = new SurfaceView(getContext());
            mSurfaceView.setOnTouchListener(new OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    return mSimpleOnGestureListener.onTouchEvent(event);
                }
            });
        }
    }

    public void detach() {
        if (!isSelfView) {
            ViewGroup viewGroup = (ViewGroup) getParent();
            Log.d(TAG, "detach: " + getMeetingUserId() + " " + viewGroup);
            if (viewGroup != null) {
                preViewGroup = new WeakReference<>(viewGroup);
                viewGroup.removeView(this);
            }
        } else {
            ViewGroup viewGroup = (ViewGroup) mSurfaceView.getParent();
            Log.d(TAG, "detach: " + getMeetingUserId() + " " + viewGroup);
            if (viewGroup != null) {
                preViewGroup = new WeakReference<>(viewGroup);
                viewGroup.removeView(mSurfaceView);
            }
        }
    }

    public WeakReference<ViewGroup> getPreViewGroup() {
        return preViewGroup;
    }

    public ViewGroup getWaitBindGroup() {
        return waitBindGroup;
    }

    public void setWaitBindGroup(ViewGroup waitBindGroup) {
        this.waitBindGroup = waitBindGroup;
    }

    public MeetingVideoView(Context context) {
        this(context, null);
    }

    public TXCloudVideoView getPlayVideoView() {
        return this;
    }

    public TXCloudVideoView getLocalPreviewView() {
        if (mSurfaceView != null) {
            return new TXCloudVideoView(mSurfaceView);
        } else {
            return this;
        }
    }

    public MeetingVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mSimpleOnGestureListener = new GestureDetector(context, new GestureDetector.SimpleOnGestureListener() {

            @Override
            public boolean onSingleTapConfirmed(MotionEvent e) {
                if (mListener != null) {
                    mListener.onSingleClick(MeetingVideoView.this);
                }
                return true;
            }

            @Override
            public boolean onDoubleTap(MotionEvent e) {
                if (mListener != null) {
                    mListener.onDoubleClick(MeetingVideoView.this);
                }
                return true;
            }

            @Override
            public boolean onDown(MotionEvent e) {
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

    public void setListener(Listener listener) {
        mListener = listener;
    }

    public void refreshParent() {
        if (!isSelfView) {
            ViewGroup viewGroup = (ViewGroup) getParent();
            if (!mNeedAttach) {
                if (viewGroup != null) {
                    Log.d(TAG, getMeetingUserId() + "detach :" + viewGroup);
                    viewGroup.removeView(this);
                }
                return;
            }
            Log.d(TAG, getMeetingUserId() + "start attach old:" + viewGroup);
            if (viewGroup == null) {
                if (waitBindGroup != null) {
                    Log.d(TAG, "refreshParent " + getMeetingUserId() + " to: " + waitBindGroup);
                    curViewGroup = waitBindGroup;
                    waitBindGroup.addView(this);
                }
                return;
            }
            if (viewGroup != waitBindGroup) {
                Log.d(TAG, "refreshParent " + getMeetingUserId() + " to: " + waitBindGroup);
                viewGroup.removeView(this);
                preViewGroup = new WeakReference<>(viewGroup);
                curViewGroup = waitBindGroup;
                waitBindGroup.addView(this);
            }
        } else {
            ViewGroup viewGroup = (ViewGroup) mSurfaceView.getParent();
            if (!mNeedAttach) {
                if (viewGroup != null) {
                    Log.d(TAG, getMeetingUserId() + "detach :" + viewGroup);
                    viewGroup.removeView(mSurfaceView);
                }
                return;
            }
            Log.d(TAG, getMeetingUserId() + "start attach old:" + viewGroup);
            if (viewGroup == null) {
                if (waitBindGroup != null) {
                    Log.d(TAG, "refreshParent " + getMeetingUserId() + " to: " + waitBindGroup);
                    curViewGroup = waitBindGroup;
                    waitBindGroup.addView(mSurfaceView);
                }
                return;
            }
            if (viewGroup != waitBindGroup) {
                Log.d(TAG, "refreshParent " + getMeetingUserId() + " to: " + waitBindGroup);
                viewGroup.removeView(mSurfaceView);
                preViewGroup = new WeakReference<>(viewGroup);
                curViewGroup = waitBindGroup;
                waitBindGroup.addView(mSurfaceView);
            }
        }
    }

    public ViewParent getViewParent() {
        if (isSelfView) {
            return mSurfaceView.getParent();
        } else {
            return this.getParent();
        }
    }

    public void addViewToViewGroup(ViewGroup viewGroup) {
        if (isSelfView) {
            viewGroup.addView(mSurfaceView);
        } else {
            viewGroup.addView(this);
        }
    }

    public interface Listener {
        void onSingleClick(View view);

        void onDoubleClick(View view);
    }

    private final Runnable measureAndLayout = new Runnable() {
        @Override
        public void run() {
            measure(
                    MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
            layout(getLeft(), getTop(), getRight(), getBottom());
        }
    };

    @Override
    public void requestLayout() {
        super.requestLayout();
        post(measureAndLayout);
    }
}
