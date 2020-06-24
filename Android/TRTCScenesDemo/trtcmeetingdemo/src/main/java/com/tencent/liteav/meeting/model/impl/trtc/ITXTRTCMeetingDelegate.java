package com.tencent.liteav.meeting.model.impl.trtc;

import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;

public interface ITXTRTCMeetingDelegate {
    void onTRTCAnchorEnter(String userId);

    void onTRTCAnchorExit(String userId);

    void onTRTCVideoAvailable(String userId, boolean available);

    void onTRTCAudioAvailable(String userId, boolean available);

    void onError(int errorCode, String errorMsg);

    void onNetworkQuality(TRTCCloudDef.TRTCQuality trtcQuality, ArrayList<TRTCCloudDef.TRTCQuality> arrayList);

    void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume);

    void onTRTCSubStreamAvailable(String userId, boolean available);

    void onScreenCaptureStarted();

    void onScreenCapturePaused();

    void onScreenCaptureResumed();

    void onScreenCaptureStopped(int reason);
}
