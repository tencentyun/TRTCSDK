import a18n from 'a18n'
import React from 'react';
import ExampleLayout from '../../layout';

import './index.scss';

function ConnectOtherRoom() {
  return (
    <div className="advanced-scene connect-other-room">
      <ExampleLayout
        title={a18n('跨房连麦')}
        renderDesc={() => {
          return (
            <React.Fragment>
              <p>
                {a18n(
                  'TRTC 中两个不同音视频房间中的主播，可以通过“跨房连麦”功能拉通连麦通话功能。使用此功能时， 两个主播无需退出各自原来的直播间即可进行“连麦 PK”。'
                )}<br/><br/>
                {a18n(
                  '例如：当房间“001”中的主播 A 通过 connectOtherRoom() 跟房间“002”中的主播 B 拉通跨房连麦后， 房间“001”中的用户都会收到主播 B 的 onUserEnter(B) 回调和 onUserVideoAvailable(B,true) 回调。 房间“002”中的用户都会收到主播 A 的 onUserEnter(A) 回调和 onUserVideoAvailable(A,true) 回调。'
                )}<br/><br/>
                {a18n('简言之，跨房连麦的本质，就是把两个不同房间中的主播相互分享，让每个房间里的观众都能看到两个主播。')}
              </p>
            </React.Fragment>
          );
        }}
        showPreview={false}
        type="connect-other-room"
        codePath="code/advanced/connect-other-room/index.js"
      >
        <div className="video-view-preview">
          <div className="connect-action-section">
            <div className="room-id-wrapper">
              {a18n('当前房间号:')} <span className="room-id"></span>
            </div>
            <div className="user-id-wrapper">
              {a18n('当前用户:')} <span className="user-id"></span>
            </div>
            <div className="connect-room-id-wrapper">
              {a18n('连麦房间号:')} <input type="number" className="connect-room-id"></input>
            </div>
            <div className="connect-room-id-wrapper">
              {a18n('连麦主播:')} <input className="connect-user-id"></input>
            </div>
            <button className="connect-room-btn">{a18n('连麦')}</button>
          </div>
          <div className="video-list-section">
            <div className="video-wrapper local-user">
              <div className="user-desc">
                <span className="user-type">{a18n('本地用户')}</span>
              </div>
              <div id="localVideoWrapper"></div>
            </div>
            <div className="video-wrapper remote-user">
              <div className="user-desc">
                <span className="user-type">{a18n('远程用户')}</span>
              </div>
              <div id="remoteVideoWrapper"></div>
            </div>
          </div>
        </div>
      </ExampleLayout>
    </div>
  );
}

export default ConnectOtherRoom;
