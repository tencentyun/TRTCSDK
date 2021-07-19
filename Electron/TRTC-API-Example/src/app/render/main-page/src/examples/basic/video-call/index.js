import React from 'react';
import Layout from '../../layout';
import './index.scss';

const desc = (
  <React.Fragment>
    <p>视频通话场景，支持720P、1080P高清画质，单个房间最多支持300人同时在线，最高支持50人同时发言。</p>
    <p>适合：[1对1视频通话]、[300人视频会议]、[在线问诊]、[视频聊天]、[远程面试]等。</p>
  </React.Fragment>
);

class VideoCall extends React.Component {
  render() {
    return (
      <div className="basic-scene basic-video-call">
        <Layout
          title="视频通话"
          type="video-call"
          renderDesc={() => desc}
          codePath="code/basic/video-call/index.js"
        >
          <div className="video-view-preview">
            <div className="video-wrapper local-user">
              <div className="user-desc">
                <span className="user-type">本地用户</span>
                <span className="user-role" id="localUserRole"></span>
              </div>
              <div id="localVideoWrapper"></div>
            </div>
            <div className="video-wrapper remote-user">
              <div className="user-desc">
                <span className="user-type">远程用户</span>
                <span className="user-role" id="remoteUserRole"></span>
              </div>
              <div id="remoteVideoWrapper"></div>
            </div>
          </div>
        </Layout>
      </div>
    )
  }
}

export default VideoCall;
