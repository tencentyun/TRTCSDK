import React, { useEffect, useState, useCallback } from 'react';
import VideocamIcon from '@material-ui/icons/Videocam';
import VideocamOffIcon from '@material-ui/icons/VideocamOff';
import VolumeOffIcon from '@material-ui/icons/VolumeOff';
import VolumeUpIcon from '@material-ui/icons/VolumeUp';
import MicIcon from '@material-ui/icons/Mic';
import MicOffIcon from '@material-ui/icons/MicOff';
import VisibilityIcon from '@material-ui/icons/Visibility';
import VisibilityOffIcon from '@material-ui/icons/VisibilityOff';
import DesktopAccessDisabledIcon from '@material-ui/icons/DesktopAccessDisabled';
import DesktopMacIcon from '@material-ui/icons/DesktopMac';
import FullscreenIcon from '@material-ui/icons/Fullscreen';
import PictureInPictureIcon from '@material-ui/icons/PictureInPicture';
import Tooltip from '@material-ui/core/Tooltip';

import styles from './streamBar.module.scss';

const mobile = require('is-mobile');

const style = {
  color: '#fff',
};

const defaultBar = {
  hasVideo: true, // 视频
  hasAudio: true, // 音频
  subscribedAudio: true, // 话筒
  subscribedVideo: true, // 视图
  shareDesk: true, // 共享桌面
  full: true, // 全屏
};

function StreamBar(props) {
  const [config, setConfig] = useState(() => ({ ...props.config }));
  const [setting] = useState(() => ({ ...defaultBar, ...props.setting }));
  const [isMobile, setIsMobile] = useState(false);
  let isRemoteAuxStream = false;
  let isLocalStream = false;
  let isRemoteMainStream = false;

  const initStreamType = () => {
    if (props.config.type === 'auxiliary' || /share/g.test(config.userID)) {
      isRemoteAuxStream = true;
      return;
    }
    if (props.config.type === 'local') {
      isLocalStream = true;
    }
    if (props.config.type === 'main') {
      isRemoteMainStream = true;
    }
  };

  initStreamType();

  const handleChange = useCallback((name, e) => {
    e.preventDefault();
    props.onChange && props.onChange({ name, stream: config.stream });
  }, [config, props]);

  useEffect(() => {
    setConfig(prevConfig => ({ ...prevConfig, ...props.config }));
  }, [props.config]);

  useEffect(() => {
    setIsMobile(mobile());
  }, []);

  return (
    <div className={`${props.className}`}>
      {
        isLocalStream && <div className={`${styles['network-quality-container']}`}>
          <img src="up.png" className={styles.arrow}></img>
          <div className={`${styles['network-quality']}`}>
          {
            [...new Array(5).keys()].map(index => <div key={`uplink-${index}`} className={`${styles[`network-quality-${index + 1}`]} ${config.uplinkNetworkQuality > index ? styles.green : ''}`}></div>)
          }
          </div>
          <img src="down.png" className={styles.arrow}></img>
          <div className={`${styles['network-quality']}`}>
            {
              [...new Array(5).keys()].map(index => <div key={`downlink-${index}`} className={`${styles[`network-quality-${index + 1}`]} ${config.downlinkNetworkQuality > index ? styles.green : ''}`}></div>)
            }
          </div>
        </div>
      }
      {/* bottom-bar */}
      <div className={`${styles.bar}`}>
        {/* 显示用户名 */}
        <span className={`${styles['bar-name']}`}>
          {config.userID}
        </span>
        {
          (isLocalStream || isRemoteMainStream)
          && <div className={`${styles['bar-icon']} ${styles[config.type]}`}>
            <div className={styles['bar-item']}>
              {/* 屏幕分享按钮 */}
              {
                !isMobile
                && setting.shareDesk
                && isLocalStream
                && (<span className={`${styles['bar-item']} ${styles['bar-item-screen']}`}>
                  {
                    <Tooltip title={config.shareDesk ? 'Stop Share Screen' : 'Share Screen'} arrow>
                      {
                        config.shareDesk
                          ? <DesktopMacIcon className={styles.pointer} onClick={e => handleChange('shareDesk', e)} style={style}/>
                          : <DesktopAccessDisabledIcon className={styles.pointer} onClick={e => handleChange('shareDesk', e)} style={style}/>
                      }
                    </Tooltip>
                  }
                </span>)
              }
              {/* 本地流开启视频/关闭视频按钮 */}
              {
                setting.hasVideo && isLocalStream
                  && <Tooltip title={config.mutedVideo ? 'Unmute Video' : 'Mute Video'} arrow>
                    {
                      config.hasVideo && !config.mutedVideo
                        ? <VideocamIcon className={styles.pointer} onClick={e => handleChange('video', e)} style={style}/>
                        : <VideocamOffIcon className={styles.pointer} onClick={e => handleChange('video', e)} style={style}/>
                    }
                  </Tooltip>
              }
              {/* 远端流展示视频状态图标 */}
              {
                setting.hasVideo && isRemoteMainStream
                  && (config.hasVideo && !config.mutedVideo
                    ? <VideocamIcon style={style}/>
                    : <VideocamOffIcon style={style}/>
                  )
              }
              {/* 本地流开启音频/关闭音频按钮 */}
              {
                setting.hasAudio && isLocalStream
                  && <Tooltip title={config.mutedAudio ? 'Unmute Audio' : 'Mute Audio'} arrow>
                    {
                      config.hasAudio && !config.mutedAudio
                        ? <div className={`${styles['audio-volume-container']} ${styles.pointer}`} onClick={e => handleChange('audio', e)} style={style}>
                          <MicIcon className={styles['audio-icon']}/>
                          <div className={styles['volume-container']} style={{ height: `${config.audioVolume * 4}%` }}>
                            <MicIcon className={styles['green-audio-icon']} style={{ color: '#1afa29' }}/>
                          </div>
                        </div>
                        : <MicOffIcon className={styles.pointer} onClick={e => handleChange('audio', e)} style={style}/>
                    }
                  </Tooltip>
              }
              {/* 画中画 */}
              {
                false && setting.hasVideo && isLocalStream
                  && <Tooltip title={config.mutedVideo ? 'Unmute Video' : 'Mute Video'} arrow>
                    {
                      config.hasVideo && !config.mutedVideo && <PictureInPictureIcon className={styles.pointer} onClick={e => handleChange('picture', e)} style={style}/>
                    }
                  </Tooltip>
              }
              {/* 远端流展示音频状态 */}
              {
                setting.hasAudio && isRemoteMainStream
                  && (
                    config.hasAudio && !config.mutedAudio
                      ? <div className={`${styles['audio-volume-container']}`} style={style}>
                        <MicIcon className={styles['audio-icon']}/>
                        <div className={styles['volume-container']} style={{ height: `${config.audioVolume * 4}%` }}>
                          <MicIcon className={styles['green-audio-icon']} style={{ color: '#1afa29' }}/>
                        </div>
                      </div>
                      : <MicOffIcon style={style}/>
                  )
              }
            </div>
            <div className={styles['bar-item']}>
            {
              isRemoteMainStream
              && (<span className={styles['bar-item']}>
                {/* 订阅远端视频按钮 */}
                {
                  setting.subscribedVideo
                    && <Tooltip title={config.subscribedVideo ? 'Unsubscribe Video' : 'Subscribe Video'} arrow>
                      {
                        config.subscribedVideo
                          ? <VisibilityIcon className={styles.pointer} onClick={e => handleChange('subscribedVideo', e)} style={style}/>
                          : <VisibilityOffIcon className={styles.pointer} onClick={e => handleChange('subscribedVideo', e)} style={style}/>
                      }
                    </Tooltip>
                }
                {/* 订阅远端音频按钮 */}
                {
                  setting.subscribedAudio
                    && <Tooltip title={config.subscribedAudio ? 'Unsubscribe Audio' : 'Subscribe Audio'} arrow>
                      {
                        config.subscribedAudio
                          ? <VolumeUpIcon className={styles.pointer} onClick={e => handleChange('subscribedAudio', e)} style={style}/>
                          : <VolumeOffIcon className={styles.pointer} onClick={e => handleChange('subscribedAudio', e)} style={style}/>
                      }
                    </Tooltip>
                }
            </span>)}
            </div>
          </div>}
        {
          setting.subscribedVideo
          && (isRemoteAuxStream
          && <FullscreenIcon onClick={e => handleChange('full', e)} style={style}/>)
        }
      </div>
    </div>
  );
}

export default React.memo(StreamBar);
