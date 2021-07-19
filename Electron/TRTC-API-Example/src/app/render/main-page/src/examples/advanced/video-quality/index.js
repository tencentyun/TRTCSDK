import React from 'react';
import ExampleLayout from '../../layout';

import './index.scss';

function VideoQuality() {
  return (
    <div className="advanced-scene video-quality">
      <ExampleLayout
        title="画质设定"
        renderDesc={() => {
          return (
            <React.Fragment>
              <p>
                画面质量可通过设置视频编码器相关参数<br />
                该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
              </p>
            </React.Fragment>
          );
        }}
        showPreview={false}
        type="video-quality"
        codePath="code/advanced/video-quality/index.js"
      >
        <div className="video-view-preview">
          <div className="video-wrapper local-user">
            <div className="user-desc">
              <span className="user-type">本地用户</span>
              <span className="user-role" id="localUserRole"></span>
            </div>
            <div id="localVideoWrapper"></div>
            <div className="local-statistic">
              userid: <span className='statistic-userid'></span><br />
              width: <span className='statistic-width'></span><br />
              height: <span className='statistic-height'></span><br />
              frameRate: <span className='statistic-frameRate'></span><br />
              videoBitrate: <span className='statistic-videoBitrate'></span><br />
              streamType: <span className='statistic-streamType'></span><br />
            </div>
          </div>
          <div className="video-wrapper remote-user">
            <div className="user-desc">
              <span className="user-type">远程用户</span>
              <span className="user-role" id="remoteUserRole"></span>
            </div>
            <div id="remoteVideoWrapper"></div>
            <div className="remote-statistic">
              userid: <span className='statistic-userid'></span><br />
              width: <span className='statistic-width'></span><br />
              height: <span className='statistic-height'></span><br />
              frameRate: <span className='statistic-frameRate'></span><br />
              videoBitrate: <span className='statistic-videoBitrate'></span><br />
              streamType: <span className='statistic-streamType'></span><br />
            </div>
          </div>
        </div>
      </ExampleLayout>

    </div>
  )
}

export default VideoQuality;
