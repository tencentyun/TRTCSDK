import Head from 'next/head';
import dynamic from 'next/dynamic';
import React, { useState, useEffect } from 'react';
import clsx from 'clsx';
import QRCoder from '@components/QrCoder';
import Stream from '@components/Stream';
import UserList from '@components/UserList';
import UserIDInput from '@components/UserIDInput';
import RoomIDInput from '@components/RoomIDInput';
import { getNavConfig } from '@api/nav';
import { getUrlParam } from '@utils/utils';
import { handlePageUrl, handlePageChange } from '@utils/common';
import { Button, Accordion, AccordionSummary, AccordionDetails, Typography, RadioGroup, FormControlLabel, Radio, makeStyles, TextField } from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import SideBar from '@components/SideBar';
import styles from '@styles/common.module.scss';
import toast from '@components/Toast';
import { SDKAPPID } from '@app/config';

const mobile = require('is-mobile');
const DynamicDeviceSelect = dynamic(import('@components/DeviceSelect'), { ssr: false });
const DynamicRtc = dynamic(import('@components/RtcClient/improve-mixTranscode-rtc-client'), { ssr: false });
const DynamicShareRtc = dynamic(import('@components/ShareRTC'), { ssr: false });

const initMixOutputParam = {
  streamId: '',
  videoWidth: 1280,
  videoHeight: 720,
  videoFramerate: 15,
  videoBitrate: 1500,
  videoGop: 2,
  audioSampleRate: 48000,
  audioBitrate: 64,
  audioChannels: 1,
  backgroundColor: 0x000000,
  backgroundImage: '',
};

const useStyles = makeStyles(() => ({
  'mix-mod-switch-container': {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
  },
  'mix-input': {
    width: '260px',
    marginBottom: '16px',
  },
  'mix-input-mobile': {
    width: '100%',
  },
  'mixed-stream-container': {
    padding: 10,
  },
  'mixed-stream-video': {
    width: '100%',
    height: 'auto',
    display: 'flex',
    justifyContent: 'center',
  },
}));

const mixModePreset = 'preset-layout'; // 混流模式--预排版模式
const mixModeManual = 'manual'; // 混流模式--全手动模式
let mixedVideoPlayer = null;
let mixInputParamList = [];
export default function BasicRtc(props) {
  const { activeId, navConfig } = props;
  const video = true;
  const audio = true;
  const mode = 'rtc';
  const classes = useStyles();
  const [useStringRoomID, setUseStringRoomID] = useState(false);
  const [RTC, setRTC] = useState(null);
  const [shareRTC, setShareRTC] = useState(null);
  const [userID, setUserID] = useState('');
  const [shareID] = useState(`share_${parseInt(Math.random() * 100000000, 10)}`);
  const [roomID, setRoomID] = useState('');
  const [cameraID, setCameraID] = useState('');
  const [microphoneID, setMicrophoneID] = useState('');
  const [localStreamConfig, setLocalStreamConfig] = useState(null);
  const [remoteStreamConfigList, setRemoteStreamConfigList] = useState([]);
  const [isJoined, setIsJoined] = useState(false);
  const [isPublished, setIsPublished] = useState(false);
  const [isScreenShared, setIsScreenShared] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [mixMode, setMixMode] = useState(mixModePreset); // 默认预排版模式
  const [outputStreamID, setOutputStreamID] = useState('');
  const [outputWidth, setOutputWidth] = useState('1280');
  const [outputHeight, setOutputHeight] = useState('720');
  const [isMixed, setIsMixed] = useState(false);

  useEffect(() => {
    handlePageUrl();
    setUseStringRoomID(getUrlParam('useStringRoomID') === 'true');
    setIsMobile(mobile());
  }, []);

  const handleJoin = async () => {
    await RTC.handleJoin();
    await RTC.handlePublish();
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
  };
  const handleStartScreenShare = () => {
    shareRTC.handleJoin();
  };

  const handleStopScreenShare = () => {
    shareRTC.handleLeave();
  };
  const setState = (type, value) => {
    switch (type) {
      case 'join':
        setIsJoined(value);
        break;
      case 'publish':
        setIsPublished(value);
        break;
      case 'screenShare':
        setIsScreenShared(value);
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

  // 移除用户
  const removeUser = (userID, streamType) => {
    if (streamType === 'local') {
      setLocalStreamConfig(null);
      setRemoteStreamConfigList([]);
    } else {
      setRemoteStreamConfigList(preList => preList.filter(streamConfig => streamConfig.userID !== userID));
    }
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

  // 开始混流
  const startMixTranscode = async () => {
    const mixOutputParam = {
      ...initMixOutputParam,
      streamId: outputStreamID || initMixOutputParam.streamId,
      videoWidth: +outputWidth || initMixOutputParam.videoWidth,
      videoHeight: +outputHeight || initMixOutputParam.videoHeight,
    };
    try {
      await RTC.startMixTranscode(mixMode, mixInputParamList, mixOutputParam, shareID);

      const streamId = mixOutputParam.streamId || `${SDKAPPID}_${roomID}_${userID}_main`;
      const url = `https://3891.liveplay.myqcloud.com/trtc_1400188366/${streamId}.flv`;

      setTimeout(() => {
        playMixedStream(url);
        // playMixedStreamFlv(url);
      }, 3000);

      toast.success('startMixTranscode success', 2000);
      console.log('startMixTranscode success');
      setIsMixed(true);
    } catch (error) {
      console.log('startMixTranscode fail', error);
      setIsMixed(false);
    }
  };

  const playMixedStream = (url) => {
    console.warn(`mixed stream url: ${url}`);
    if (mixedVideoPlayer) {
      mixedVideoPlayer.destroy();
      mixInputParamList = [];
    }
    // eslint-disable-next-line no-undef
    mixedVideoPlayer = new TcPlayer('mixed-stream-video', {
      flv: url, // 请替换成实际可用的播放地址
      // m3u8: url,
      h5_flv: true,
      autoplay: true, // iOS 下 safari 浏览器，以及大部分移动端浏览器是不开放视频自动播放这个能力的
      width: '335', // 视频的显示宽度，请尽量使用视频分辨率宽度
      height: '250', // 视频的显示高度，请尽量使用视频分辨率高度
    });
  };

  // const playMixedStreamFlv = (url) => {
  //   // toast.info(`has MediaSource object = ${flvjs.isSupported()}`);
  //   // toast.info(`mse support = ${flvjs.getFeatureList() && flvjs.getFeatureList().mseLiveFlvPlayback}`);

  //   if (flvjs.isSupported()) {
  //     const videoElement = document.getElementById('videoElementItem');
  //     const flvPlayer = flvjs.createPlayer({
  //         type: 'flv',
  //         url: url
  //     });
  //     flvPlayer.attachMediaElement(videoElement);
  //     flvPlayer.load();
  //     flvPlayer.play();
  //   }
  // };

  // 停止混流
  const stopMixTranscode = async () => {
    setIsMixed(false);
    if (!RTC || !RTC.mixedMCU) {
      return;
    }
    console.log('stop-mix-transcode');
    try {
      await RTC.client.stopMixTranscode();
      RTC.mixedMCU = false;
      mixedVideoPlayer.destroy();
      mixedVideoPlayer = null;
      console.log('stopMixTranscode success');
    } catch (error) {
      console.log('stopMixTranscode fail', error);
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
              <Typography>操作</Typography>
            </AccordionSummary>
            <AccordionDetails className={styles['accordion-details-container']}>
              <UserIDInput disabled={isJoined} onChange={value => setUserID(value)}></UserIDInput>
              <RoomIDInput disabled={isJoined} onChange={value => setRoomID(value)}></RoomIDInput>
              <DynamicDeviceSelect deviceType="camera" onChange={value => setCameraID(value)}></DynamicDeviceSelect>
              <DynamicDeviceSelect deviceType="microphone" onChange={value => setMicrophoneID(value)}></DynamicDeviceSelect>
              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button id="join" variant="contained" color="primary" className={ isJoined ? styles.forbidden : ''} onClick={handleJoin}>JOIN</Button>
                <Button id="leave" variant="contained" color="primary" onClick={handleLeave}>LEAVE</Button>
                <Button id="publish" variant="contained" color="primary" style={{ display: 'none' }} className={ isPublished ? styles.forbidden : '' } onClick={handlePublish}>PUBLISH</Button>
                <Button id="unpublish" variant="contained" color="primary" style={{ display: 'none' }} onClick={handleUnPublish}>UNPUBLISH</Button>
                <Button id="publish" variant="contained" color="primary" className={ isScreenShared ? styles.forbidden : ''} onClick={handleStartScreenShare}>START SCREEN SHARE</Button>
                <Button id="unpublish" variant="contained" color="primary" onClick={handleStopScreenShare}>STOP SCREEN SHARE</Button>
              </div>
            </AccordionDetails>
          </Accordion>

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
              <Typography>混流转码</Typography>
            </AccordionSummary>
            <AccordionDetails className={styles['accordion-details-container']}>
              <RadioGroup value={mixMode} className={classes['mix-mod-switch-container']}
                onChange={() => setMixMode(mixMode === mixModePreset ? mixModeManual : mixModePreset)}
              >
                <Typography>Mode：</Typography>
                <FormControlLabel value={mixModeManual} control={<Radio />} label="全手动" className={classes['role-select']} />
                <FormControlLabel value={mixModePreset} control={<Radio />} label="预排版" />
              </RadioGroup>

              <TextField className={clsx(classes['mix-input'], isMobile && classes['mix-input-mobile'])} id="outputStreamID" value={outputStreamID} label="outputStreamID" onChange={event => setOutputStreamID(event.target.value)}/>
              <TextField className={clsx(classes['mix-input'], isMobile && classes['mix-input-mobile'])} id="outputWidth" value={outputWidth} label="outputWidth" onChange={event => setOutputWidth(event.target.value)}/>
              <TextField className={clsx(classes['mix-input'], isMobile && classes['mix-input-mobile'])} id="outputHeight" value={outputHeight} label="outputHeight" onChange={event => setOutputHeight(event.target.value)}/>

              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button id="start-mix" variant="contained" color="primary" onClick={startMixTranscode}>START MIX</Button>
                <Button id="stop-mix" variant="contained" color="primary" onClick={stopMixTranscode}>STOP MIX</Button>
              </div>
            </AccordionDetails>
          </Accordion>

          {/* 用户列表 */}
          <div className={clsx(styles['user-list-container'])}>
            <UserList localStreamConfig={localStreamConfig} remoteStreamConfigList={remoteStreamConfigList}>
            </UserList>
          </div>
        </div>
        {/* 生成二维码 */}
        {
          !isMobile
          && <div className={clsx(styles['footer-container'])}>
              <Typography>移动端体验</Typography>
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

        {/* 混流效果预览 */}
        {isMixed && <div className={classes['mixed-stream-container']}>
          <span>混流效果预览：</span>
          <div id="mixed-stream-video"></div>

          {/* <video
            className={clsx(classes['mixed-stream-video'])}
            id="videoElementItem"
            autoPlay
            width={320}
            height={280}
          >Your browser is too old which doesn't support HTML5 video.</video> */}
        </div>}
      </div>
    </div>);

  return (
    <div className={clsx(styles['page-container'], isMobile && styles['mobile-device'])}>
      <Head>
        <title>基础音视频通话</title>
        <meta name="description" content="basic rtc communication by Tencent webRTC" />
        <script src="https://imgcache.qq.com/open/qcloud/video/vcplayer/TcPlayer-2.3.3.js" charSet="utf-8"></script>
        {/* <script src="./flv.min.js"></script> */}
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
        localStreamConfig
          && <DynamicShareRtc
          onRef={ref => setShareRTC(ref)}
          userID={shareID}
          roomID={roomID}
          relatedUserID={userID}
          useStringRoomID={useStringRoomID}
          updateStreamConfig={updateStreamConfig}
          setState={setState}>
          </DynamicShareRtc>
      }
      <SideBar
        extendActiveId={activeId}
        activeTitle={props.activeTitle}
        data={navConfig}
        onActiveExampleChange={handlePageChange}
        isMobile={isMobile}
      >
      </SideBar>
      {pageContent()}
    </div>
  );
}

export const getStaticProps = () => {
  const result = getNavConfig('improve-mixTranscode');
  return {
    props: {
      ...result,
    },
  };
};
