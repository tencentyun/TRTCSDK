import a18n from 'a18n'
import React from 'react';
import Layout from '../../layout';
import { getLocale } from '../../../initA18n';
import './index.scss';
import TRTCSoundAPIImageCN from './trtc-sound-api-cn.png';
import TRTCSoundAPIImageEN from './trtc-sound-api-en.png';

const desc = () => {
  const lang = getLocale();

  return (
    <React.Fragment>
      <p>
        {a18n('通常声音采集只会采集麦克风声音，如果调用 startPlayMusic 接口播放背景音乐，则背景音乐的声音也会被采集；')}
      </p>
      <p>
        {a18n(
          '如果调用 startSystemAudioLoopback 接口开启了系统音量采集，此时如果用户打开其他应用程序播放音乐或者视频，\n      则音乐或视频的声音也会被采集。'
        )}
      </p>
      <img src={/^zh\b/.test(lang) ? TRTCSoundAPIImageCN : TRTCSoundAPIImageEN} alt={a18n('TRTC SDK 声音相关接口')} style={{width: "80%"}}/>
    </React.Fragment>
  )
}

function VolumeControl() {
  return (
    <div className="advanced-scene volume-control">
      <Layout
        title={a18n('音量控制')}
        type="volume-control"
        renderDesc={() => desc()}
        codePath="code/advanced/volume-control/index.js">
        <form name="volumeControlForm" className="config-form volume-control-form">
          <div className="form-left">
            <div className="form-line form-section-title">{a18n('采集音量')}</div>
            <div className="form-line">
              <label className="form-item-label">{a18n('SDK采集音量：')}</label>
              <input type="range" name="audioCaptureVolume" min="0" max="100" />
            </div>
            <div className="form-line">
              <label className="form-item-label">{a18n('麦克风采集音量：')}</label>
              <input type="range" name="currentMicDeviceVolume" min="0" max="100" />
            </div>
            <div className="form-line">
              <label className="form-item-label">{a18n('背景音乐的远端播放音量：')}</label>
              <input type="range" name="musicPublishVolume" min="0" max="100" />
            </div>
            <div className="form-line">
              <label className="form-item-label">{a18n('系统声音采集音量：')}</label>
              <input type="range" name="systemAudioLoopbackVolume" min="0" max="100" />
            </div>
          </div>
          <div className="form-right">
            <div className="form-line form-section-title">{a18n('播放音量')}</div>
            <div className="form-line">
              <label className="form-item-label">{a18n('SDK播放音量：')}</label>
              <input type="range" name="audioPlayoutVolume" min="0" max="100" />
            </div>
            <div className="form-line">
              <label className="form-item-label">{a18n('远端用户的本地播放音量：')}</label>
              <input type="range" name="remoteAudioVolume" min="0" max="100" />
            </div>
            <div className="form-line">
              <label className="form-item-label">{a18n('背景音乐的本地播放音量：')}</label>
              <input type="range" name="musicPlayoutVolume" min="0" max="100" />
            </div>
            <div className="form-line">
              <label className="form-item-label">{a18n('扬声器音量：')}</label>
              <input type="range" name="currentSpeakerVolume" min="0" max="100" />
            </div>
          </div>
        </form>

        <div className="video-view-preview">
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
      </Layout>
    </div>
  );
}

export default VolumeControl;
