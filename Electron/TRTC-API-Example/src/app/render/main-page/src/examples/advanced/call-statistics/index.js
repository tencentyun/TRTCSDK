import React from 'react';
import ExampleLayout from '../../layout';
import './index.scss';

function CallStatistics() {
  return (
    <div className="advanced-scene call-statistics">
      <ExampleLayout
        title="通话技术指标统计"
        renderDesc={() => {
          return (
            <React.Fragment>
              <p>
                展示 SDK 的所有技术指标, 包括本地和远程的, 每2秒回调一次
              </p>
            </React.Fragment>
          );
        }}
        showPreview={false}
        type="call-statistics"
        codePath="code/advanced/call-statistics/index.js"
      >
        <div className="video-view-preview">
          <div className="summary-statistics">
            <div className="summary-wrapper">
              上行丢包率: <span className='statistic-upLoss'></span>
            </div>
            <div className="summary-wrapper">
              下行丢包率: <span className='statistic-downLoss'></span>
            </div>
            <div className="summary-wrapper">
              App CPU 使用率: <span className='statistic-app-cpu'></span>
            </div>
            <div className="summary-wrapper">
              系统 CPU 使用率: <span className='statistic-system-cpu'></span>
            </div>
            <div className="summary-wrapper">
              延迟: <span className='statistic-rtt'></span>
            </div>
            <div className="summary-wrapper">
              总接收字节数: <span className='statistic-received-bytes'></span>
            </div>
          </div>
          <div className="video-list-section">
            <div className="video-wrapper local-user">
              <div className="user-desc">
                <span className="user-type">本地用户</span>
                <span className="user-role" id="localUserRole"></span>
              </div>
              <div id="localVideoWrapper"></div>
              <div className="local-statistic">
                userid: <span className='statistic-userid'></span><br/>
                width: <span className='statistic-width'></span><br/>
                height: <span className='statistic-height'></span><br/>
                frameRate: <span className='statistic-frameRate'></span><br/>
                videoBitrate: <span className='statistic-videoBitrate'></span><br/>
                streamType: <span className='statistic-streamType'></span><br/>
              </div>
            </div>
            <div className="video-wrapper remote-user">
              <div className="user-desc">
                <span className="user-type">远程用户</span>
                <span className="user-role" id="remoteUserRole"></span>
              </div>
              <div id="remoteVideoWrapper"></div>
              <div className="remote-statistic">
                userid: <span className='statistic-userid'></span><br/>
                width: <span className='statistic-width'></span><br/>
                height: <span className='statistic-height'></span><br/>
                frameRate: <span className='statistic-frameRate'></span><br/>
                videoBitrate: <span className='statistic-videoBitrate'></span><br/>
                streamType: <span className='statistic-streamType'></span><br/>
              </div>
            </div>
          </div>
        </div>
      </ExampleLayout>
    </div>
  )
}

export default CallStatistics;
