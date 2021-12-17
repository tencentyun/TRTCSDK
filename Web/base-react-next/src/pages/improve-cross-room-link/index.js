import a18n from 'a18n';
import Head from 'next/head';
import dynamic from 'next/dynamic';
import React, { useState, useEffect } from 'react';
import clsx from 'clsx';
import QRCoder from '@components/QrCoder';
import Stream from '@components/Stream';
import UserIDInput from '@components/UserIDInput';
import RoomIDInput from '@components/RoomIDInput';
import { getNavConfig } from '@api/nav';
import { getUrlParam, getUrlParamObj } from '@utils/utils';
import { handlePageUrl, handlePageChange, getLanguage } from '@utils/common';
import { Button, Accordion, AccordionSummary, AccordionDetails, Typography, makeStyles } from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import SideBar from '@components/SideBar';
import styles from '@styles/common.module.scss';
import DeviceSelect from '@components/DeviceSelect';
import { ENV_IS_PRODUCTION } from '@utils/constants';
import { SDKAPPID } from '@app/config';
import Toast from '@components/Toast';
import RelatedResources from '@components/RelatedResources';
const mobile = require('is-mobile');
const DynamicRtc = dynamic(import('@components/RtcClient/improve-cross-room-link-rtc-client'), { ssr: false });
const DynamicShareRtc = dynamic(import('@components/ShareRTC'), { ssr: false });

const useStyles = makeStyles(() => ({
  'cdn-stream': {
    position: 'relative',
    width: '400px',
    height: '300px',
    backgroundColor: '#000000',
    marginLeft: '10px',
  },
  'span-title': {
    width: '100%',
    padding: '10px 20px',
  },
  loading: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    backgroundColor: '#000000',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    color: '#ffffff',
    fontSize: '18px',
  },
}));

export default function BasicRtc(props) {
  const classes = useStyles();
  let cdnVideoPlayer = null;
  const { activeId, navConfig, language } = props;
  const video = true;
  const audio = true;
  const mode = 'live';
  const [useStringRoomID, setUseStringRoomID] = useState(false);
  const [RTC, setRTC] = useState(null);
  const [otherRTC, setOtherRTC] = useState(null);
  const [shareRTC, setShareRTC] = useState(null);
  const [userID, setUserID] = useState('');
  const [roomID, setRoomID] = useState('');
  const [cameraID, setCameraID] = useState('');
  const [microphoneID, setMicrophoneID] = useState('');
  const [otherRoomID, setOtherRoomID] = useState('');
  const [otherRoomUserID, setOtherRoomUserID] = useState('');
  const [localStreamConfig, setLocalStreamConfig] = useState(null);
  const [remoteStreamConfigList, setRemoteStreamConfigList] = useState([]);
  const [isJoined, setIsJoined] = useState(false);
  const [isOtherRoomJoined, setIsOtherRoomJoined] = useState(false);
  const [otherRoomRemoteStreamList, setOtherRoomRemoteStreamList] = useState([]);
  const [isPublished, setIsPublished] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [mountFlag, setMountFlag] = useState(false);
  const [isPlayingCDNStream, setIsPlayingCDNStream] = useState(false);

  useEffect(() => {
    const language = getLanguage();
    a18n.setLocale(language);
    setMountFlag(true);

    handlePageUrl();
    setUseStringRoomID(getUrlParam('useStringRoomID') === 'true');
    setIsMobile(mobile());
    return () => {
      cdnVideoPlayer && cdnVideoPlayer.destroy();
    };
  }, []);

  const playCDNStream = () => {
    const streamId = `${SDKAPPID}_${roomID}_${userID}_main`;
    let url = '';
    if (SDKAPPID === 1400188366) {
      url = `https://3891.liveplay.myqcloud.com/trtc_1400188366/${streamId}`;
    } else {
      Toast.error(a18n('请修改 src/pages/improve-cross-room-link/index.js 文件中的cdn播放url'));
    }
    // eslint-disable-next-line no-undef
    cdnVideoPlayer = new TcPlayer('cdn-stream', {
      m3u8: `${url}.m3u8`,
      flv: `${url}.flv`,
      autoplay: true,
      poster: '',
      width: '100%',
      height: '100%',
      controls: 'none',
      listener: playerListener.bind(this),
    });
  };

  const playerListener = (event) => {
    if (event.type === 'error') {
      cdnVideoPlayer.destroy();
      setIsPlayingCDNStream(false);
      setTimeout(() => {
        playCDNStream();
      }, 1000);
    }
    if (event.type === 'playing') {
      setIsPlayingCDNStream(true);
    }
  };

  const handleJoin = async () => {
    await RTC.handleJoin();
    await RTC.handlePublish();
    await RTC.handleStartPublishCDNStream();
    playCDNStream();
  };

  const handlePublish = async () => {
    await RTC.handlePublish();
  };

  const handleUnPublish = async () => {
    await RTC.handleUnPublish();
  };

  const handleLeave = async () => {
    shareRTC && shareRTC.handleLeave();
    await RTC.handleLeave();
    cdnVideoPlayer && cdnVideoPlayer.destroy();
  };

  const copyOtherRoomLink = () => {
    const urlParamObj = getUrlParamObj();
    urlParamObj.roomID = otherRoomID;
    urlParamObj.userID = otherRoomUserID;
    urlParamObj.otherRoomUserID = userID;
    urlParamObj.otherRoomID = roomID;
    const otherRoomSearch = Object.keys(urlParamObj).reduce((prev, key) => {
      if (!prev) {
        return `?${key}=${urlParamObj[key]}`;
      }
      return `${prev}&${key}=${urlParamObj[key]}`;
    }, '');
    const otherRoomLink = `${location.origin}${location.pathname}${otherRoomSearch}`;
    navigator.clipboard.writeText(otherRoomLink);
    Toast.success('Copy other room link success');
  };

  // 开始跨房连麦
  const connectOtherRoom = async () => {
    await otherRTC.handleJoin();
  };

  // 停止跨房连麦
  const disconnectOtherRoom = async () => {
    await otherRTC.handleLeave();
  };

  // 开始跨房间混流, 由推流的client发起跨房间混流
  const handleStartMix = async () => {
    const mixTranscodeConfig = {
      videoWidth: 640,
      videoHeight: 480,
      videoBitrate: 1500,
      videoFramerate: 15,
      mixUsers: [
        {
          userId: userID,
          roomId: roomID, // roomId 字段自 v4.11.5 版本开始支持，支持跨房间混流
          pureAudio: false,
          width: 320,
          height: 480,
          locationX: 0,
          locationY: 0,
          streamType: 'main', // 指明该配置为远端主流
          zOrder: 1,
        },
        {
          userId: otherRoomUserID,
          roomId: otherRoomID, // roomId 字段自 v4.11.5 版本开始支持，支持跨房间混流
          pureAudio: false,
          width: 320,
          height: 480,
          locationX: 320,
          locationY: 0,
          streamType: 'main', // 指明该配置为远端辅流
          zOrder: 1,
        },
      ],
    };
    await RTC.handleStartMixTranscode(mixTranscodeConfig);
  };

  // 停止跨房间混流，由推流的client停止跨房间混流
  const handleStopMix = async () => {
    await RTC.handleStopMixTranscode();
  };

  const setState = (type, value) => {
    switch (type) {
      case 'join':
        setIsJoined(value);
        break;
      case 'publish':
        setIsPublished(value);
        break;
      default:
        break;
    }
  };

  const setOtherRoomState = (type, value) => {
    switch (type) {
      case 'join':
        setIsOtherRoomJoined(value);
        break;
      default:
        break;
    }
  };

  // 新增用户
  const addUser = (userID, streamType) => {
    if (streamType === 'local') {
      setLocalStreamConfig({
        stream: null,
        streamType,
        userID,
        hasAudio: false,
        hasVideo: false,
        mutedAudio: false,
        mutedVideo: false,
        shareDesk: false,
        audioVolume: 0,
      });
    } else {
      setRemoteStreamConfigList((preList) => {
        const newRemoteStreamConfigList = preList.length > 0
          ? preList.filter(streamConfig => streamConfig.userID !== userID)
          : [];
        newRemoteStreamConfigList
          .push({
            stream: null,
            streamType: 'main',
            userID,
            hasAudio: false,
            hasVideo: false,
            mutedAudio: false,
            mutedVideo: false,
            subscribedAudio: false,
            subscribedVideo: false,
            resumeFlag: false,
            audioVolume: 0,
          });
        return newRemoteStreamConfigList;
      });
    }
  };

  const addOtherRoomUser = (userID) => {
    setRemoteStreamConfigList((preList) => {
      const newRemoteStreamConfigList = preList.length > 0
        ? preList.filter(streamConfig => streamConfig.userID !== userID)
        : [];
      newRemoteStreamConfigList
        .push({
          stream: null,
          streamType: 'main',
          userID,
          hasAudio: false,
          hasVideo: false,
          mutedAudio: false,
          mutedVideo: false,
          subscribedAudio: false,
          subscribedVideo: false,
          resumeFlag: false,
          audioVolume: 0,
        });
      return newRemoteStreamConfigList;
    });
  };

  // 增加流
  const addStream = (stream) => {
    const streamType = stream.getType();
    const userID = stream.getUserId();
    switch (streamType) {
      case 'local':
        setLocalStreamConfig({
          stream,
          streamType,
          userID,
          hasAudio: audio,
          hasVideo: video,
          mutedAudio: false,
          mutedVideo: false,
          shareDesk: false,
          audioVolume: 0,
        });
        break;
      default: {
        setRemoteStreamConfigList((preList) => {
          const newRemoteStreamConfigList = preList.length > 0
            ? preList.filter(streamConfig => !(streamConfig.userID === userID
              && streamConfig.streamType === streamType))
            : [];
          newRemoteStreamConfigList
            .push({
              stream,
              streamType,
              userID,
              hasAudio: stream.hasAudio(),
              hasVideo: stream.hasVideo(),
              mutedAudio: false,
              mutedVideo: false,
              subscribedAudio: true,
              subscribedVideo: true,
              resumeFlag: false,
              audioVolume: 0,
            });
          return newRemoteStreamConfigList;
        });
        break;
      }
    }
  };

  const addOtherRoomStream = (stream) => {
    const streamType = stream.getType();
    const userID = stream.getUserId();
    setOtherRoomRemoteStreamList((preList) => {
      const newRemoteStreamConfigList = preList.length > 0
        ? preList.filter(streamConfig => !(streamConfig.userID === userID
          && streamConfig.streamType === streamType))
        : [];
      newRemoteStreamConfigList
        .push({
          stream,
          streamType,
          userID,
          hasAudio: stream.hasAudio(),
          hasVideo: stream.hasVideo(),
          mutedAudio: false,
          mutedVideo: false,
          subscribedAudio: true,
          subscribedVideo: true,
          resumeFlag: false,
          audioVolume: 0,
        });
      return newRemoteStreamConfigList;
    });
  };

  // 更新流数据
  const updateStream = (stream) => {
    if (stream.getType() === 'local') {
      setLocalStreamConfig({
        ...localStreamConfig,
        stream,
        hasAudio: stream.hasAudio(),
        hasVideo: stream.hasVideo(),
      });
    } else {
      setRemoteStreamConfigList(preList => preList.map(config => (
        config.stream === stream ? {
          ...config,
          stream,
          hasAudio: stream.hasAudio(),
          hasVideo: stream.hasVideo(),
        } : config
      )));
    }
  };

  const updateOtherRoomStream = (stream) => {
    setOtherRoomRemoteStreamList(preList => preList.map(config => (
      config.stream === stream ? {
        ...config,
        stream,
        hasAudio: stream.hasAudio(),
        hasVideo: stream.hasVideo(),
      } : config
    )));
  };

  // 更新对本地流和远端流的操作状态
  const updateStreamConfig = (userID, type, value) => {
    // 更新本地流配置
    if (localStreamConfig && localStreamConfig.userID === userID) {
      const config = {};
      switch (type) {
        case 'audio-volume':
          if (localStreamConfig.audioVolume === value) {
            break;
          }
          config.audioVolume = value;
          break;
        case 'share-desk':
          config.shareDesk = value;
          break;
        case 'uplink-network-quality':
          config.uplinkNetworkQuality = value > 0 ? 6 - value : value;
          break;
        case 'downlink-network-quality':
          config.downlinkNetworkQuality = value > 0 ? 6 - value : value;
          break;
        default:
          break;
      }
      setLocalStreamConfig(prevConfig => ({
        ...prevConfig,
        ...config,
      }));
      return;
    }
    // 更新远端流配置
    const config = {};
    switch (type) {
      case 'mute-audio':
        config.mutedAudio = true;
        break;
      case 'unmute-audio':
        config.mutedAudio = false;
        break;
      case 'mute-video':
        config.mutedVideo = true;
        break;
      case 'unmute-video':
        config.mutedVideo = false;
        break;
      case 'resume-stream':
        config.resumeFlag = true;
        break;
      case 'audio-volume':
        if (config.audioVolume === value) {
          break;
        }
        config.audioVolume = value;
        break;
      default:
        break;
    }
    setRemoteStreamConfigList(preList => preList.map(item => (
      item.userID === userID ? { ...item, ...config } : item
    )));
  };

  const updateOtherRoomStreamConfig = (userID, type, value) => {
    // 更新远端流配置
    const config = {};
    switch (type) {
      case 'mute-audio':
        config.mutedAudio = true;
        break;
      case 'unmute-audio':
        config.mutedAudio = false;
        break;
      case 'mute-video':
        config.mutedVideo = true;
        break;
      case 'unmute-video':
        config.mutedVideo = false;
        break;
      case 'resume-stream':
        config.resumeFlag = true;
        break;
      case 'audio-volume':
        if (config.audioVolume === value) {
          break;
        }
        config.audioVolume = value;
        break;
      default:
        break;
    }
    setRemoteStreamConfigList(preList => preList.map(item => (
      item.userID === userID ? { ...item, ...config } : item
    )));
  };

  // 移除流
  const removeStream = (stream) => {
    const streamType = stream.getType();
    const userID = stream.getUserId();
    switch (streamType) {
      case 'local':
        setLocalStreamConfig(prevConfig => ({
          ...prevConfig,
          hasAudio: false,
          hasVideo: false,
        }));
        break;
      default: {
        setRemoteStreamConfigList(preList => preList
          .map(streamConfig => (streamConfig.userID === userID && streamConfig.streamType === streamType
            ? {
              ...streamConfig,
              hasAudio: false,
              hasVideo: false,
              subscribedAudio: false,
              subscribedVideo: false,
            } : streamConfig)));
        break;
      }
    }
  };

  const removeOtherRoomStream = (stream) => {
    const streamType = stream.getType();
    const userID = stream.getUserId();
    setOtherRoomRemoteStreamList(preList => preList
      .map(streamConfig => (streamConfig.userID === userID && streamConfig.streamType === streamType
        ? {
          ...streamConfig,
          hasAudio: false,
          hasVideo: false,
          subscribedAudio: false,
          subscribedVideo: false,
        } : streamConfig)));
  };

  // 移除用户
  const removeUser = (userID, streamType) => {
    if (streamType === 'local') {
      setLocalStreamConfig(null);
      setRemoteStreamConfigList([]);
    } else {
      setRemoteStreamConfigList(preList => preList.filter(streamConfig => streamConfig.userID !== userID));
    }
  };

  const removeOtherRoomUser = (userID) => {
    setRemoteStreamConfigList(preList => preList.filter(streamConfig => streamConfig.userID !== userID));
  };

  // 处理本地流 streamBar 的响应逻辑
  const handleLocalChange = async (data) => {
    switch (data.name) {
      case 'video':
        if (!localStreamConfig.mutedVideo) {
          RTC.muteVideo();
        } else {
          RTC.unmuteVideo();
        }
        setLocalStreamConfig({
          ...localStreamConfig,
          mutedVideo: !localStreamConfig.mutedVideo,
        });
        break;
      case 'audio':
        if (!localStreamConfig.mutedAudio) {
          RTC.muteAudio();
        } else {
          RTC.unmuteAudio();
        }
        setLocalStreamConfig({
          ...localStreamConfig,
          mutedAudio: !localStreamConfig.mutedAudio,
        });
        break;
      case 'shareDesk':
        if (!localStreamConfig.shareDesk) {
          await shareRTC.handleJoin();
        } else {
          await shareRTC.handleLeave();
        }
        setLocalStreamConfig({
          ...localStreamConfig,
          shareDesk: !localStreamConfig.shareDesk,
        });
      default:
        break;
    }
  };

  // 处理远端流 streamBar 的响应逻辑
  const handleRemoteChange = async (data) => {
    const remoteStream = data.stream;
    const config = remoteStreamConfigList.find(config => config.stream === remoteStream);
    switch (data.name) {
      case 'subscribedVideo':
        await RTC.handleSubscribe(remoteStream, {
          video: !config.subscribedVideo,
          audio: config.subscribedAudio,
        });

        setRemoteStreamConfigList(preList => preList.map(config => (
          config.stream === remoteStream ? ({
            ...config,
            subscribedVideo: !config.subscribedVideo,
          }) : config
        )));
        break;
      case 'subscribedAudio':
        await RTC.handleSubscribe(remoteStream, {
          video: config.subscribedVideo,
          audio: !config.subscribedAudio,
        });
        setRemoteStreamConfigList(preList => preList.map(config => (
          config.stream === remoteStream ? ({
            ...config,
            subscribedAudio: !config.subscribedAudio,
          }) : config
        )));
        break;
      case 'resumeFlag':
        await RTC.resumeStream(config.stream);
        setRemoteStreamConfigList(preList => preList.map(config => (
          config.stream === remoteStream ? ({
            ...config,
            resumeFlag: !config.resumeFlag,
          }) : config
        )));
      default:
        break;
    }
  };

  const pageContent = () => (
    <div className={clsx(styles['content-container'], isMobile && styles['mobile-device'])}>
      {/* 操作区域 */}
      <div className={clsx(styles['control-container'], isMobile && styles['mobile-device'])}>
        <div className={clsx(styles['body-container'], isMobile && styles['mobile-device'])}>
          <Accordion className={styles['accordion-container']} defaultExpanded={true}>
            <AccordionSummary
              expandIcon={<ExpandMoreIcon />}
              aria-controls="panel1a-content"
              id="panel1a-header"
              classes={{
                root: styles['accordion-summary-container'],
                content: styles['accordion-summary-content'],
              }}
            >
              {mountFlag && <Typography>{a18n('操作')}</Typography>}
            </AccordionSummary>
            <AccordionDetails className={styles['accordion-details-container']}>
              <UserIDInput disabled={isJoined} onChange={value => setUserID(value)}></UserIDInput>
              <RoomIDInput disabled={isJoined} onChange={value => setRoomID(value)}></RoomIDInput>

              <DeviceSelect deviceType="camera" onChange={value => setCameraID(value)}></DeviceSelect>
              <DeviceSelect deviceType="microphone" onChange={value => setMicrophoneID(value)}></DeviceSelect>

              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button id="join" variant="contained" color="primary" className={ isJoined ? styles.forbidden : ''} onClick={handleJoin}>JOIN</Button>
                <Button id="leave" variant="contained" color="primary" onClick={handleLeave}>LEAVE</Button>
                <Button id="publish" variant="contained" color="primary" className={ isPublished ? styles.forbidden : '' } onClick={handlePublish}>PUBLISH</Button>
                <Button id="unpublish" variant="contained" color="primary" onClick={handleUnPublish}>UNPUBLISH</Button>
              </div>

              <UserIDInput
                label="otherRoomUserID"
                disabled={isOtherRoomJoined}
                onChange={value => setOtherRoomUserID(value)}
                setUrlValue={false}></UserIDInput>
              <RoomIDInput
                label="otherRoomID"
                disabled={isOtherRoomJoined}
                onChange={value => setOtherRoomID(value)}
                setUrlValue={false}></RoomIDInput>

              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button id="copy" variant="contained" color="primary" onClick={copyOtherRoomLink}>{a18n('复制跨房间链接')}</Button><br/>
                <Button id="join" variant="contained" color="primary" className={ isOtherRoomJoined ? styles.forbidden : ''} onClick={connectOtherRoom}>{a18n('开始跨房连麦')}</Button>
                <Button id="leave" variant="contained" color="primary" onClick={disconnectOtherRoom}>{a18n('停止跨房连麦')}</Button>
                <Button id="publish" variant="contained" color="primary" onClick={handleStartMix}>{a18n('开始跨房间混流')}</Button>
                <Button id="unpublish" variant="contained" color="primary" onClick={handleStopMix}>{a18n('停止跨房间混流')}</Button>
              </div>
            </AccordionDetails>
          </Accordion>
          <div>
            <span>{a18n('测试步骤')}</span><br/>
            <span>{a18n('1. 点击【Join】')}</span><br/>
            <span>{a18n('2. 点击【复制跨房间链接】在新的 Tab 打开链接并进房')}</span><br/>
            <span>{a18n('3. 点击【开始跨房连麦】')} </span><br/>
            <span>{a18n('4. 点击【开始跨房间混流】')} </span><br/>
          </div>
           {/* 相关资源 */}
          <RelatedResources
            language={language}
            resources={[
              { name: a18n('跨房连麦教程'),
                link: 'https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/tutorial-30-advance-connect-other-room.html',
                enLink: 'https://web.sdk.qcloud.com/trtc/webrtc/doc/en/tutorial-30-advance-connect-other-room.html',
              },
            ]}></RelatedResources>
        </div>
        {/* 生成二维码 */}
        {
          !isMobile && ENV_IS_PRODUCTION
          && <div className={clsx(styles['footer-container'])}>
              {mountFlag && <Typography>{a18n('移动端体验')}</Typography>}
              <QRCoder roomID={roomID} ></QRCoder>
            </div>
        }
      </div>
      {/* 视频流显示区域 */}
      <div className={styles['stream-container']}>
        {/* 本地流 */}
        {
          localStreamConfig && (localStreamConfig.hasAudio || localStreamConfig.hasVideo)
          && <Stream
          stream={localStreamConfig.stream}
          config={localStreamConfig}
          init={dom => RTC.playStream(localStreamConfig.stream, dom)}
          onChange={e => handleLocalChange(e)}></Stream>
        }
        {/* 远端流 */}
        {
          remoteStreamConfigList.length > 0
            && remoteStreamConfigList.map((remoteStreamConfig) => {
              if (remoteStreamConfig.hasAudio || remoteStreamConfig.hasVideo) {
                return <Stream
                  key={`${remoteStreamConfig.stream.getUserId()}_${remoteStreamConfig.stream.getType()}`}
                  stream = {remoteStreamConfig.stream}
                  config = {remoteStreamConfig}
                  init={dom => RTC.playStream(remoteStreamConfig.stream, dom)}
                  onChange = {e => handleRemoteChange(e)}>
                </Stream>;
              }
              return null;
            })
        }
        {/* 跨房间的远端流 */}
        {
          otherRoomRemoteStreamList.length > 0 && <div className={classes['span-title']}>{a18n`${otherRoomID}房间的流`}</div>
        }
        {
          otherRoomRemoteStreamList.length > 0
            && otherRoomRemoteStreamList.map((remoteStreamConfig) => {
              if (remoteStreamConfig.hasAudio || remoteStreamConfig.hasVideo) {
                return <Stream
                  key={`${remoteStreamConfig.stream.getUserId()}_${remoteStreamConfig.stream.getType()}`}
                  stream = {remoteStreamConfig.stream}
                  config = {remoteStreamConfig}
                  init={dom => RTC.playStream(remoteStreamConfig.stream, dom)}
                  onChange = {e => handleRemoteChange(e)}>
                </Stream>;
              }
              return null;
            })
        }
        {
          isPublished && <div className={classes['span-title']}>{a18n('CDN拉流预览(CDN拉流具有较长延时，请耐心等待)')}</div>
        }
        {
          isPublished && <div className={classes['cdn-stream']}>
            <div id="cdn-stream"></div>
            {
              !isPlayingCDNStream && <div className={classes.loading}>loading...</div>
            }
          </div>
        }
      </div>
    </div>);

  return (
    <div className={clsx(styles['page-container'], isMobile && styles['mobile-device'])}>
      <Head>
        <title>{a18n`${a18n(props.activeTitle)}-TRTC 腾讯实时音视频`}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no, shrink-to-fit=no" />
        <script src="https://imgcache.qq.com/open/qcloud/video/vcplayer/TcPlayer-2.3.3.js" charSet="utf-8"></script>
      </Head>
      {
        userID
          && roomID
          && <DynamicRtc
          onRef={ref => setRTC(ref)}
          userID={userID}
          roomID={roomID}
          useStringRoomID={useStringRoomID}
          cameraID={cameraID}
          microphoneID={microphoneID}
          audio={audio}
          video={video}
          mode={mode}
          setState={setState}
          addUser={addUser}
          removeUser={removeUser}
          addStream={addStream}
          updateStream={updateStream}
          updateStreamConfig={updateStreamConfig}
          removeStream={removeStream}
        ></DynamicRtc>
      }
      {
        otherRoomUserID
          && otherRoomID
          && <DynamicRtc
          onRef={ref => setOtherRTC(ref)}
          userID={userID}
          roomID={otherRoomID}
          useStringRoomID={useStringRoomID}
          cameraID={cameraID}
          microphoneID={microphoneID}
          audio={audio}
          video={video}
          mode={mode}
          setState={setOtherRoomState}
          addUser={addOtherRoomUser}
          removeUser={removeOtherRoomUser}
          addStream={addOtherRoomStream}
          updateStream={updateOtherRoomStream}
          updateStreamConfig={updateOtherRoomStreamConfig}
          removeStream={removeOtherRoomStream}
        ></DynamicRtc>
      }
      {
        localStreamConfig
          && <DynamicShareRtc
          onRef={ref => setShareRTC(ref)}
          userID={`share_${userID}`}
          roomID={roomID}
          relatedUserID={userID}
          useStringRoomID={useStringRoomID}
          updateStreamConfig={updateStreamConfig}>
          </DynamicShareRtc>
      }
      <SideBar
        extendActiveId={activeId}
        activeTitle={props.activeTitle}
        data={navConfig}
        mountFlag={mountFlag}
        onActiveExampleChange={handlePageChange}
        isMobile={isMobile}
      >
      </SideBar>
      {pageContent()}
    </div>
  );
}

export const getStaticProps = () => {
  const result = getNavConfig('improve-cross-room-link');
  return {
    props: {
      ...result,
    },
  };
};
