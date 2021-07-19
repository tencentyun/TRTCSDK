import a18n from 'a18n';
import React, { useEffect, useState } from 'react';
import clsx from 'clsx';
import VideocamIcon from '@material-ui/icons/Videocam';
import VideocamOffIcon from '@material-ui/icons/VideocamOff';
import VolumeOffIcon from '@material-ui/icons/VolumeOff';
import VolumeUpIcon from '@material-ui/icons/VolumeUp';
import MicIcon from '@material-ui/icons/Mic';
import MicOffIcon from '@material-ui/icons/MicOff';
import VisibilityIcon from '@material-ui/icons/Visibility';
import VisibilityOffIcon from '@material-ui/icons/VisibilityOff';
import styles from './item.module.scss';
const mobile = require('is-mobile');

function UserItem(props) {
  const [config, setConfig] = useState(props.config);
  const [type] = useState(props.type);
  const [isMobile, setIsMobile] = useState(false);
  const [isLocalStream, setIsLocalStream] = useState(false);

  useEffect(() => {
    setIsMobile(mobile());
  }, []);

  useEffect(() => {
    setConfig(props.config);
    setIsLocalStream(props.config.streamType === 'local');
  }, [props.config]);

  return (
    <li className={styles.item}>
      {/* 显示用户名 */}
      <div className={styles['item-label-container']}>
        <span
          className={clsx(styles['item-label'], styles[`item-label${isMobile ? '-mobile' : ''}${type === 'local' ? '-self' : ''}`])} title={config.userID}>
          {config.userID}</span>
        {
          type === 'local' && <span>{a18n('（我）')}</span>
        }
      </div>
      <div className={`${styles['item-icon']} ${styles[type]}`}>
        {/* 本地流远端流开启视频/关闭视频状态 */}
        {
          config.hasVideo && !config.mutedVideo ? <VideocamIcon /> : <VideocamOffIcon />
        }
        {/* 本地流远端流开启音频/关闭音频状态 */}
        {
          config.hasAudio && !config.mutedAudio
            ? <div className={styles['audio-volume-container']}>
                <MicIcon className={styles['audio-icon']}/>
                <div className={styles['volume-container']} style={{ height: `${config.audioVolume * 4}%` }}>
                  <MicIcon className={styles['green-audio-icon']} style={{ color: '#1afa29' }}/>
                </div>
              </div>
            : <MicOffIcon />
        }
        {
          !isLocalStream
          && (config.subscribedVideo ? <VisibilityIcon /> : <VisibilityOffIcon />)
        }
        {
          !isLocalStream
          && (config.subscribedAudio ? <VolumeUpIcon /> : <VolumeOffIcon />)
        }
      </div>
  </li>
  );
}
export default UserItem;

