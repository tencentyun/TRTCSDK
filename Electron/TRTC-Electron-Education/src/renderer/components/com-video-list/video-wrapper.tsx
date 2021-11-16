import React, { useEffect, useRef } from 'react';
import VideocamOffIcon from '@material-ui/icons/VideocamOff';
import MicIcon from '@material-ui/icons/Mic';
import MicOffIcon from '@material-ui/icons/MicOff';
import IconButton from '@material-ui/core/IconButton';
import { TRTCVideoStreamType } from 'trtc-electron-sdk/liteav/trtc_define';
import { trtcUtil } from '../../utils/trtc-edu-sdk';

function VideoWrapper(props: Record<string, any>) {
  const { user, toggleMicMuteState } = props;
  const {
    userID,
    isCameraStarted,
    isCameraMuted,
    isMicStarted,
    isMicMuted,
    isLocal,
  } = user;
  const ref = useRef(null);

  useEffect(() => {
    if (userID && trtcUtil.trtcEducation?.rtcCloud) {
      if (isCameraStarted && !isCameraMuted) {
        if (isLocal) {
          trtcUtil.trtcEducation.rtcCloud.startLocalPreview(ref.current);
        } else {
          trtcUtil.trtcEducation.rtcCloud.startRemoteView(
            userID,
            ref.current,
            TRTCVideoStreamType.TRTCVideoStreamTypeBig
          );
        }
      } else if (isLocal) {
        trtcUtil.trtcEducation.rtcCloud.stopLocalPreview();
      } else {
        trtcUtil.trtcEducation.rtcCloud.stopRemoteView(
          userID,
          TRTCVideoStreamType.TRTCVideoStreamTypeBig
        );
      }
    }
  }, [userID, isLocal, isCameraStarted, isCameraMuted]);

  return (
    <div className="trtc-edu-video-wrapper">
      {user && userID && (
        <>
          {isCameraStarted && !isCameraMuted ? (
            <div className="video-content" ref={ref} />
          ) : (
            <div className="video-muted">
              <VideocamOffIcon />
            </div>
          )}
          <div className="video-op-bar" data-user-id={user.userID}>
            <div className="icon-group">
              <IconButton
                onClick={() => toggleMicMuteState(user)}
                className={`trtc-edu-icon-button ${
                  isMicStarted && !isMicMuted ? 'unmuted' : 'muted'
                }`}
              >
                {isMicStarted && !isMicMuted ? <MicIcon /> : <MicOffIcon />}
              </IconButton>
              <span className="user-info">{`${user.userID}`}</span>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

export default VideoWrapper;
