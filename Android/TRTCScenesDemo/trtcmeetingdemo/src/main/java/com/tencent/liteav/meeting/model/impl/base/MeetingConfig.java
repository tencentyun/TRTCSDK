package com.tencent.liteav.meeting.model.impl.base;

import com.tencent.trtc.TRTCCloudDef;

public class MeetingConfig {
    public int resolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
    public int fps        = 15;
    public int bitrate    = 1000;
}
