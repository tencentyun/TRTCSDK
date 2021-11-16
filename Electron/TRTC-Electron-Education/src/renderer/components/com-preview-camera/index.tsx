import React, { useRef, useEffect } from 'react';
import { trtcUtil } from '../../utils/trtc-edu-sdk';
import './index.scss';

function ComPreviewCamera(props: Record<string, any>) {
  const { isCameraStarted } = props;
  const ref = useRef(null);

  useEffect(() => {
    if (trtcUtil.trtcEducation?.rtcCloud) {
      if (isCameraStarted) {
        trtcUtil.trtcEducation.rtcCloud.startLocalPreview(ref.current);
      }
    }
  }, [isCameraStarted]);

  return (
    <div className="com-preview-camera">
      <div className="video-content" ref={ref} />
    </div>
  );
}

export default ComPreviewCamera;
