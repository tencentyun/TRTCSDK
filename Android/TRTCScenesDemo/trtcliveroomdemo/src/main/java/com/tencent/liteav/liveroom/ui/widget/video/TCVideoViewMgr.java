package com.tencent.liteav.liveroom.ui.widget.video;


import java.util.List;

/**
 * Module:   TCVideoViewMgr
 * <p>
 * Function: 视频播放View的管理类
 * <p>
 * {@link TCVideoView}  的管理类
 */
public class TCVideoViewMgr {
    private List<TCVideoView> mVideoViews;
    private TCVideoView       mPKVideoView;

    public TCVideoViewMgr(List<TCVideoView> videoViewList, final TCVideoView.OnRoomViewListener l) {
        // 连麦拉流
        mVideoViews = videoViewList;
        for (TCVideoView videoView : mVideoViews) {
            videoView.setOnRoomViewListener(l);
        }
    }

    public synchronized void clearPKView() {
        mPKVideoView = null;
    }

    public synchronized TCVideoView getPKUserView() {
        if (mPKVideoView != null) {
            return mPKVideoView;
        }
        boolean foundUsed = false;
        for (TCVideoView item : mVideoViews) {
            if (item.isUsed) {
                foundUsed = true;
                mPKVideoView = item;
                break;
            }
        }
        if (!foundUsed) {
            mPKVideoView = mVideoViews.get(0);
        }
        return mPKVideoView;
    }

    public synchronized boolean containUserId(String id) {
        for (TCVideoView item : mVideoViews) {
            if (item.isUsed && item.userId.equals(id)) {
                return true;
            }
        }
        return false;
    }

    public synchronized TCVideoView applyVideoView(String id) {
        if (id == null) {
            return null;
        }

        if (mPKVideoView != null) {
            mPKVideoView.setUsed(true);
            mPKVideoView.showKickoutBtn(false);
            mPKVideoView.userId = id;
            return mPKVideoView;
        }

        for (TCVideoView item : mVideoViews) {
            if (!item.isUsed) {
                item.setUsed(true);
                item.userId = id;
                return item;
            } else {
                if (item.userId != null && item.userId.equals(id)) {
                    item.setUsed(true);
                    return item;
                }
            }
        }
        return null;
    }

    public synchronized void recycleVideoView(String id) {
        for (TCVideoView item : mVideoViews) {
            if (item.userId != null && item.userId.equals(id)) {
                item.userId = null;
                item.setUsed(false);
            }
        }
    }

    public synchronized void recycleVideoView() {
        for (TCVideoView item : mVideoViews) {
            item.userId = null;
            item.setUsed(false);
        }
    }

    public synchronized void showLog(boolean show) {
        for (TCVideoView item : mVideoViews) {
            if (item.isUsed) {
                item.showLog(show);
            }
        }
    }
}
