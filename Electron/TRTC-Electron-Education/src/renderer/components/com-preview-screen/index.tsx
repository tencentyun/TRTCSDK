import React, { useEffect, useRef } from 'react';
import {
  TRTCScreenCaptureSourceInfo,
  Rect,
  TRTCVideoStreamType,
  TRTCVideoEncParam,
  TRTCVideoResolution,
  TRTCVideoResolutionMode,
} from 'trtc-electron-sdk/liteav/trtc_define';
import { trtcUtil } from '../../utils/trtc-edu-sdk/index';
import './index.scss';

interface PropsType {
  screenInfo: TRTCScreenCaptureSourceInfo | null;
  isSharing: boolean;
}

function ComPreviewScreen(props: PropsType) {
  const { screenInfo, isSharing } = props;
  const refScreenSharing = useRef(null);

  // 根据初始化参数，启动屏幕分享
  useEffect(() => {
    if (isSharing && screenInfo && trtcUtil.trtcEducation?.rtcCloud) {
      const selectRect = new Rect();
      const screenShareEncParam = new TRTCVideoEncParam(
        TRTCVideoResolution.TRTCVideoResolution_1920_1080,
        TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
        15,
        1600,
        0,
        true
      );
      trtcUtil.trtcEducation?.rtcCloud.selectScreenCaptureTarget(
        screenInfo.type,
        screenInfo.sourceId,
        screenInfo.sourceName,
        selectRect,
        true, // mouse
        true // highlight
      );
      trtcUtil.trtcEducation?.rtcCloud.startScreenCapture(
        refScreenSharing.current,
        TRTCVideoStreamType.TRTCVideoStreamTypeSub,
        screenShareEncParam
      );
    }
  }, [isSharing, screenInfo]);

  return (
    <div className="com-preview-screen">
      {isSharing && (
        <div className="screen-sharing-preview" ref={refScreenSharing} />
      )}
    </div>
  );
}

export default ComPreviewScreen;
