import React, { useState, useEffect, useRef } from 'react';
import StreamBar from './streamBar';
import FullscreenExitIcon from '@material-ui/icons/FullscreenExit';
import styles from './stream.module.scss';
import Toast from '@components/Toast';
import { setFullscreen, exitFullscreen } from '@utils/utils';

const fullscreenchangeList = ['fullscreenchange', 'webkitfullscreenchange', 'mozfullscreenchange', 'MSFullscreenChange'];
const fullscreenerrorList = ['fullscreenerror', 'webkitfullscreenerror', 'mozfullscreenerror', 'MSFullscreenError'];

/**
 * @description stream 组件
 * @param {Object} props 配置项
 * @param {Object} props.stream 流对象
 * @param {Object} props.config 设置流当前的属性状态 video: 视频 audio: 音频
 * @param {Object} props.setting 设置对应的 streamBarIcon 是否显示
 * @param {Function} props.init 将 dom 元素回调
 * @param {Function} props.onChange 用户操作 streamBar 的回调
 * @returns {Element}
 *
 */
const Stream = (props) => {
  const [statusInit, setStatusInit] = useState(false);
  const [full, setFull] = useState(false);
  const [config, setConfig] = useState(() => ({ ...props.config }));
  const refItem = useRef();

  useEffect(() => {
    fullscreenchangeList.forEach((item) => {
      document.addEventListener(item, () => {
        if (document.fullscreenElement) {
          setFull(true);
        } else {
          setFull(false);
        }
      });
    });
    fullscreenerrorList.forEach((item) => {
      document.addEventListener(item, () => {
        Toast.error('set fullscreen error', '2000');
      });
    });
    // 组件销毁时处理
    return () => {
      [...fullscreenchangeList, ...fullscreenerrorList].forEach((item) => {
        document.removeEventListener(item, () => {});
      });
    };
  }, []);

  /**
   *
   * @param {Function} handle 设置 state 的方法
   * @param {Moudle} value 赋给对于 state 的值
   */
  const handleState = (handle, value) => {
    handle(prevValue => ({ ...prevValue, ...value }));
  };

  const handleExitFull = (e) => {
    e.preventDefault();
    exitFullscreen();
  };

  const handleChange = (e) => {
    if (e.name === 'full') {
      setFullscreen(refItem.current);
      return;
    }
    if (e.name === 'picture') {
      try {
        if ('pictureInPictureEnabled' in document) {
          const isInPicture = document.pictureInPictureElement;
          if (!isInPicture) {
            refItem.current.childNodes[0].childNodes[1].requestPictureInPicture();
          } else {
            document.exitPictureInPicture();
          }
        } else {
          Toast.error('Browser not support picture in picture', '2000');
        }
      } catch (error) {
        console.log('error = ', error);
      }
      return;
    }
    props.onChange && props.onChange(e);
  };

  const handleResume = () => {
    props.onChange && props.onChange({
      name: 'resumeFlag',
      stream: config.stream,
    });
  };

  useEffect(() => {
    if (props.init && !statusInit) {
      props.init(refItem.current);
      const current = {
        userID: props.stream.getUserId(),
        type: props.stream.getType(),
      };
      handleState(setConfig, current);
      setStatusInit(true);
    }
    handleState(setConfig, { ...props.config });
  }, [props.type, props.init, props.stream, props, statusInit]);

  return (
    <div className={`${styles.item} ${props.className}`}>
      <div ref={refItem} className={styles['item-view']}>
        {full && (<footer className={styles['item-view-exits']}>
          <span className={styles['item-view-exits-icon']} onClick={handleExitFull}>
            <FullscreenExitIcon style={{ color: '#fff' }} />
          </span>
        </footer>)}
      </div>
      {
        config.resumeFlag
        && <div className={styles['item-play-btn-container']} onClick={handleResume}>
            <img src='./play.png' className={styles['item-play-btn']}></img>
          </div>
      }
      <StreamBar
        className={styles['item-control']}
        config={config}
        onChange={handleChange}
        setting={props.setting}/>
    </div>
  );
};

export default React.memo(Stream);
