import React from 'react';
import { TRTCRoleType } from 'trtc-electron-sdk';

import Layout from '../../layout';
import './index.scss';

function Desc(){
  return (
    <React.Fragment>
      <p>视频互动直播，支持平滑上下麦，切换过程无需等待，主播延时小于300ms；支持十万级别观众同时播放，播放延时低至1000ms。</p>
      <p>适合：[视频低延时直播]、[十万人互动课堂]、[视频直播 PK]、[视频相亲房]、[互动课堂]、[远程培训]、[超大型会议]等。</p>
      <p>
        直播场景下的角色，默认值：主播
      </p>
      <ul>
        <li>TRTCRoleAnchor: 主播，可以上行视频和音频，一个房间里最多支持50个主播同时上行音视频。</li>
        <li>TRTCRoleAudience: 观众，只能观看，不能上行视频和音频，一个房间里的观众人数没有上限。</li>
      </ul>
      <form name="roleSelectForm" className="role-select-form">
        <span>选择角色：</span>
        <input type="radio" id="roleTypeAnchor" name="roleType" value={TRTCRoleType.TRTCRoleAnchor} defaultChecked/><label htmlFor="roleTypeAnchor">主播</label>
        <input type="radio" id="roleTypeAudience" name="roleType" value={TRTCRoleType.TRTCRoleAudience} /><label htmlFor="roleTypeAudience">观众</label>
      </form>
    </React.Fragment>
  )
};

function VideoCall(props) {
  return (
    <div className="basic-scene basic-video-live">
      <Layout
        title="视频互动直播"
        type="video-live"
        renderDesc={() => <Desc />}
        codePath="code/basic/video-live/index.js"
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

export default VideoCall;
