import React from 'react';
import './index.scss';

import ExampleLayout from '../../layout';
function ScreenShare() {
  return (
    <div className="basic-scene basic-screen-share">
      <ExampleLayout
        title="屏幕分享"
        renderDesc={() => {
          return (
            <React.Fragment>
              <p>屏幕分享, 支持选择使用主路或辅路进行屏幕分享</p>
              <p>
                一个用户同时最多只能上传一条主路（TRTCVideoStreamTypeBig）画面和一条辅路（TRTCVideoStreamTypeSub）画面，默认情况下，
                屏幕分享使用辅路画面，如果使用主路画面，建议您提前停止摄像头采集（stopLocalPreview）避免相互冲突
              </p>
            </React.Fragment>
          )
        }}
        showPreview={false}
        type="screen-share"
        codePath="code/basic/screen-share/index.js"
      >
        <div className="screen-list"></div>
        <div className="screen-share-view">
          <div className="localScreenShareWrapper share-preview-item">Local Screen Share Preview</div>
          <div className="remoteScreenShareWrapper share-preview-item">Remote Screen Share Preview</div>
        </div>
      </ExampleLayout>
    </div>
  )
}

export default ScreenShare;
