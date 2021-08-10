import a18n from 'a18n'
import React from 'react';
import ExampleLayout from '../../layout';
import './index.scss';

function SwitchRole() {
  return (
    <div className="advanced-scene switch-role">
      <ExampleLayout
        title={a18n('切换角色')}
        renderDesc={() => {
          return (
            <React.Fragment>
              <p>
                {a18n('仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）')}<br/>
                {a18n('在直播场景下，一个用户可能需要在“观众”和“主播”之间来回切换。')}<br/>
                {a18n('您可以在进房前通过 TRTCParams 中的 role 字段确定角色，也可以通过 switchRole 在进房后切换角色。')}
              </p>
              <p>
                {a18n('TRTCRoleAnchor: 主播，可以上行视频和音频，一个房间里最多支持50个主播同时上行音视频。')}<br/>
                {a18n('TRTCRoleAudience: 观众，只能观看，不能上行视频和音频，一个房间里的观众人数没有上限。')}
              </p>
            </React.Fragment>
          );
        }}
        showPreview={false}
        type="switch-role"
        codePath="code/advanced/switch-role/index.js"
      >
        <div className="video-view-preview">
          <div className="user-role-section">
          </div>
          <div className="video-list-section">
            <div className="video-wrapper local-user">
              <div className="user-desc">
                <span className="user-type">{a18n('本地用户')}</span>
                <span className="user-role" id="localUserRole"></span>
              </div>
              <div id="localVideoWrapper"></div>
            </div>
            <div className="video-wrapper remote-user">
              <div className="user-desc">
                <span className="user-type">{a18n('远程用户')}</span>
                <span className="user-role" id="remoteUserRole"></span>
              </div>
              <div id="remoteVideoWrapper"></div>
            </div>
          </div>
        </div>
      </ExampleLayout>
    </div>
  );
}

export default SwitchRole;
