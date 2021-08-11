import a18n from 'a18n'
import React from 'react';
import MicNoneIcon from '@material-ui/icons/MicNone';
import MicIcon from '@material-ui/icons/Mic';
import { TRTCRoleType } from 'trtc-electron-sdk';
import Layout from '../../layout';
import './index.scss';

const desc = () => (
  <React.Fragment>
    <p>{a18n('语音互动直播，支持平滑上下麦，切换过程无需等待，主播延时小于300ms；支持十万级别观众同时播放，播放延时低至1000ms。')}</p>
    <p>{a18n('适合：[语音低延时直播]、[语音直播连麦]、[语聊房]、[K 歌房]、[FM 电台]等。')}</p>
    <p>
      {a18n('直播场景下的角色，默认值：主播')}
    </p>
    <ul>
      <li>{a18n('TRTCRoleAnchor: 主播，可以上行视频和音频，一个房间里最多支持50个主播同时上行音视频。')}</li>
      <li>{a18n('TRTCRoleAudience: 观众，只能观看，不能上行视频和音频，一个房间里的观众人数没有上限。')}</li>
    </ul>
    <form name="roleSelectForm" className="role-select-form">
        <span>{a18n('选择角色：')}</span>
        <input type="radio" id="roleTypeAnchor" name="roleType" value={TRTCRoleType.TRTCRoleAnchor} defaultChecked/><label htmlFor="roleTypeAnchor">{a18n('主播')}</label>
        <input type="radio" id="roleTypeAudience" name="roleType" value={TRTCRoleType.TRTCRoleAudience} /><label htmlFor="roleTypeAudience">{a18n('观众')}</label>
      </form>
  </React.Fragment>
);

function AudioCall(props) {
  return (
    <div className="basic-scene basic-audio-call">
      <Layout
        title={a18n('语音互动直播')}
        type="audio-live"
        renderDesc={() => desc()}
        codePath="code/basic/audio-live/index.js"
      >
        <div className="audio-microphone-preview">
          <div className="icon-microphone audio-local-microphone">
            <div className="user-desc">
              <span className="user-type">{a18n('本地用户')}</span>
              <span className="user-role" id="localUserRole"></span>
            </div>
            <MicNoneIcon className="background"/>
            <MicIcon id="localUserAudioIcon" className="foreground"/>
          </div>
          <div className="icon-microphone audio-remote-microphone">
            <div className="user-desc">
              <span className="user-type">{a18n('远程用户')}</span>
              <span className="user-role" id="remoteUserRole"></span>
            </div>
            <MicNoneIcon className="background"/>
            <MicIcon id="remoteUserAudioIcon" className="foreground"/>
          </div>
        </div>
      </Layout>
    </div>
  );
}

export default AudioCall;