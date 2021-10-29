import a18n from 'a18n';
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
import { handlePageUrl, handlePageChange, getLanguage } from '@utils/common';
import { Button, Accordion, AccordionSummary, AccordionDetails, Typography } from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import SideBar from '@components/SideBar';
import styles from '@styles/common.module.scss';
import DeviceSelect from '@components/DeviceSelect';
import { ENV_IS_PRODUCTION } from '@utils/constants';
const mobile = require('is-mobile');
const DynamicRtc = dynamic(import('@components/RtcClient/improve-audio-mixer-rtc-client'), { ssr: false });
const DynamicShareRtc = dynamic(import('@components/ShareRtcClient/improve-audio-mixer-rtc-client'), { ssr: false });

export default function BasicRtc(props) {
  const { activeId, navConfig } = props;
  const video = true;
  const audio = true;
  const mode = 'rtc';
  const [useStringRoomID, setUseStringRoomID] = useState(false);
  const [RTC, setRTC] = useState(null);
  const [shareRTC, setShareRTC] = useState(null);
  const [userID, setUserID] = useState('');
  const [roomID, setRoomID] = useState('');
  const [cameraID, setCameraID] = useState('');
  const [microphoneID, setMicrophoneID] = useState('');
  const [localStreamConfig, setLocalStreamConfig] = useState(null);
  const [remoteStreamConfigList, setRemoteStreamConfigList] = useState([]);
  const [isJoined, setIsJoined] = useState(false);
  const [isPublished, setIsPublished] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [isScreenShared, setIsScreenShared] = useState(false);
  const [mountFlag, setMountFlag] = useState(false);

  useEffect(() => {
    const language = getLanguage();
    a18n.setLocale(language);
    setMountFlag(true);

    handlePageUrl();
    setUseStringRoomID(getUrlParam('useStringRoomID') === 'true');
    setIsMobile(mobile());
  }, []);

  const handleJoin = async () => {
    await RTC.handleJoin();
    RTC.createMusic();
    await RTC.handlePublish();
  };

  const handlePublish = async () => {
    if (isPublished) {
      return;
    }
    await RTC.handlePublish();
  };

  const handleUnPublish = async () => {
    if (!isPublished) {
      return;
    }
    await RTC.handleUnPublish();
  };

  const handleLeave = async () => {
    RTC.leaveRoom();
    shareRTC && shareRTC.handleLeave();
    await RTC.handleLeave();
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

  const addLowMix = () => {
    console.log('add low mix');
    RTC.addLowMix();
  };
  const lowMixStart = () => {
    console.log('low mix start');
    RTC.lowMixStart();
  };
  const lowMixPause = () => {
    console.log('low mix pause');
    RTC.lowMixPause();
  };
  const lowMixStop = () => {
    console.log('low mix stop');
    RTC.lowMixStop();
  };
  const lowMixResume = () => {
    console.log('low mix resume');
    RTC.lowMixResume();
  };

  const handleStartScreenShare = () => {
    shareRTC.handleJoin();
  };
  const handleStopScreenShare = () => {
    shareRTC.handleLeave();
  };

  // 屏幕分享混音
  const addShareLowMix = () => {
    console.log('add share low mix');
    shareRTC.addShareLowMix();
  };
  const shareLowMixStart = () => {
    console.log('share low mix start');
    shareRTC.shareLowMixStart();
  };
  const shareLowMixPause = () => {
    console.log('share low mix pause');
    shareRTC.shareLowMixPause();
  };
  const shareLowMixStop = () => {
    console.log('share low mix stop');
    shareRTC.shareLowMixStop();
  };
  const shareLowMixResume = () => {
    console.log('share low mix resume');
    shareRTC.shareLowMixResume();
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
            </AccordionDetails>
          </Accordion>

          {/* 增加背景音乐和音效 */}
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
              {mountFlag && <Typography>{a18n('增加背景音乐和音效')}</Typography>}
            </AccordionSummary>
            <AccordionDetails className={styles['accordion-details-container']}>
              <Typography variant="h6">count.mp3</Typography>
              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button id="low-mix" variant="contained" color="primary" onClick={addLowMix}>{a18n('增加COUNT')}</Button>
                <Button id="low-start" variant="contained" color="primary" onClick={lowMixStart}>START</Button>
                <Button id="low-pause" variant="contained" color="primary" onClick={lowMixPause}>PAUSE</Button>
                <Button id="low-stop" variant="contained" color="primary" onClick={lowMixStop}>STOP</Button>
                <Button id="low-resume" variant="contained" color="primary" onClick={lowMixResume}>RESUME</Button>
              </div>
            </AccordionDetails>
          </Accordion>

          {/* 屏幕分享混音 */}
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
              {mountFlag && <Typography>{a18n('屏幕分享混音')}</Typography>}
            </AccordionSummary>
            <AccordionDetails className={styles['accordion-details-container']}>
              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button id="publish" variant="contained" color="primary" className={ isScreenShared ? styles.forbidden : ''} onClick={handleStartScreenShare}>START SHARE</Button>
                <Button id="unpublish" variant="contained" color="primary" onClick={handleStopScreenShare}>STOP SHARE</Button>
              </div>
              <Typography variant="h6">count.mp3</Typography>
              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button id="low-mix" variant="contained" color="primary" onClick={addShareLowMix}>{a18n('增加COUNT')}</Button>
                <Button id="low-start" variant="contained" color="primary" onClick={shareLowMixStart}>START</Button>
                <Button id="low-pause" variant="contained" color="primary" onClick={shareLowMixPause}>PAUSE</Button>
                <Button id="low-stop" variant="contained" color="primary" onClick={shareLowMixStop}>STOP</Button>
                <Button id="low-resume" variant="contained" color="primary" onClick={shareLowMixResume}>RESUME</Button>
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
      </div>
    </div>);

  return (
    <div className={clsx(styles['page-container'], isMobile && styles['mobile-device'])}>
      <Head>
        <title>{a18n`${a18n(props.activeTitle)}-TRTC 腾讯实时音视频`}</title>
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
  const result = getNavConfig('improve-audio-mixer');
  return {
    props: {
      ...result,
    },
  };
};
