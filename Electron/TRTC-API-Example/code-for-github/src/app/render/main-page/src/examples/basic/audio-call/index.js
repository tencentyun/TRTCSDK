import a18n from 'a18n'
import React from 'react';
import Layout from '../../layout';
import MicNoneIcon from '@material-ui/icons/MicNone';
import MicIcon from '@material-ui/icons/Mic';
import './index.scss';

const desc = () => (
  <React.Fragment>
    <p>{a18n('语音通话场景，支持 48kHz，支持双声道。单个房间最多支持300人同时在线，最高支持50人同时发言。')}</p>
    <p>{a18n('适合：[1对1语音通话]、[300人语音会议]、[语音聊天]、[语音会议]、[在线狼人杀]等。')}</p>
  </React.Fragment>
);

function AudioCall(props) {
  return (
    <div className="basic-scene basic-audio-call">
      <Layout
        title={a18n('语音通话')}
        renderDesc={() => desc()}
        type="audio-call"
        codePath="code/basic/audio-call/index.js"
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