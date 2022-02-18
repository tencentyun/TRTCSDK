/* eslint-disable no-param-reassign */
import a18n from 'a18n';
import Head from 'next/head';
import dynamic from 'next/dynamic';
import React, { useState, useEffect, useRef } from 'react';
import clsx from 'clsx';
import Stream from '@components/Stream';
import UserList from '@components/UserList';
import UserIDInput from '@components/UserIDInput';
import RoomIDInput from '@components/RoomIDInput';
import { getNavConfig } from '@api/nav';
import { getUrlParam } from '@utils/utils';
import { handlePageUrl, handlePageChange, getLanguage } from '@utils/common';
import { Button, Accordion, AccordionSummary, AccordionDetails, Typography, FormControl, FormLabel, RadioGroup, FormControlLabel, Radio } from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import SideBar from '@components/SideBar';
import styles from '@styles/common.module.scss';
import DeviceSelect from '@components/DeviceSelect';
import RelatedResources from '@components/RelatedResources';
import Toast from '@components/Toast';
import { getFederationToken } from '@api/http';
const mobile = require('is-mobile');
const DynamicRtc = dynamic(import('@components/BaseRTC'), { ssr: false });
const DynamicShareRtc = dynamic(import('@components/ShareRTC'), { ssr: false });

export default function BasicRtc(props) {
  const { activeId, navConfig, language } = props;
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
  const [isMobile, setIsMobile] = useState(false);
  const [mountFlag, setMountFlag] = useState(false);
  const [captionList, setCaptionList] = useState([]);
  const [textMinutesResultList, setTextMinutesResultList] = useState([]);
  const [asrList] = useState(new Map());
  const [enableASR, setEnableASR] = useState(false);
  const [scene, setScene] = useState('caption');
  const [appId, setAppId] = useState(0);
  const [secretId, setSecretId] = useState('');
  const [secretKey, setSecretKey] = useState('');
  const [token, setToken] = useState('');

  useEffect(() => {
    const language = getLanguage();
    a18n.setLocale(language);
    setMountFlag(true);

    handlePageUrl();
    setUseStringRoomID(getUrlParam('useStringRoomID') === 'true');
    setIsMobile(mobile());
  }, []);

  const handleStartASR = () => {
    setEnableASR(true);
    if (localStreamConfig.stream) {
      startASR(localStreamConfig.stream);
    }
    remoteStreamConfigList.forEach(({ stream }) => {
      startASR(stream);
    });
    Toast.success('实时语音识别已开启，尝试对着麦克风说几句话吧！');
  };
  const handleStopASR = () => {
    setEnableASR(false);
    stopASR();
  };

  const startASR = (stream) => {
    if (asrList.has(stream.getUserId())) {
      return;
    }
    const asr = new ASR({
      secretKey,
      secretId,
      appId,
      token: token || undefined,
      // 实时识别接口参数
      engine_model_type: '16k_zh', // 引擎
      voice_format: 1,
      // 以下为非必填参数，可跟据业务自行修改
      hotword_id: '08003a00000000000000000000000000',
      needvad: 1,
      filter_dirty: 1,
      filter_modal: 1,
      filter_punc: 1,
      convert_num_mode: 1,
      word_info: 2,
      audioTrack: stream.getAudioTrack(),
    });
    const userId = stream.getUserId();
    installASREvents(asr, userId, localStreamConfig.stream === stream);
    asr.start();
    asrList.set(userId, asr);
  };

  const stopASR = () => {
    asrList.forEach((asr) => {
      uninstallASREvents(asr);
      asr.stop();
    });
    setTextMinutesResultList([]);
    setCaptionList([]);
    asrList.clear();
  };

  /**
   * 监听 ASR 事件
   * 实时字幕组成：已识别成功的文字 + 正在识别的文字
   * @memberof RtcClient
   */
  const installASREvents = (asr, userId, isMe) => {
    // 一句话识别成功
    asr.OnSentenceEnd = (res) => {
      if (res.voice_text_str.length !== 0) {
        if (scene === 'text-minutes') {
          textMinutesResultList.push({
            userId,
            date: new Date(),
            text: res.voice_text_str,
            isMe,
          });
          setTextMinutesResultList(textMinutesResultList);
          return;
        }

        const prevASRResult = captionList.find(item => item.userId === userId);
        if (prevASRResult) {
          const split = prevASRResult.currentResultIndex === -1 ? '' : '，';
          prevASRResult.resultText = prevASRResult.resultText + split + res.voice_text_str;
          prevASRResult.currentResultIndex = res.index;
        } else {
          captionList.push({
            userId,
            resultText: res.voice_text_str, // 已识别成功的文字，由多句已识别的话组成。
            currentResultIndex: res.index, // 每句话都有 index 标识，currentResultIndex 为最近已识别成功的 index 值。
            changingText: '', // 正在识别的文字
            changingIndex: -1, // 正在识别文字的 index 标识。
          });
        }
        setCaptionList(captionList);
        // this.renderASRResultList();
      }
    };

    // 实时字幕场景
    if (scene === 'caption') {
      // 一句话正在识别
      asr.OnRecognitionResultChange = (res) => {
        if (res.voice_text_str.length !== 0) {
          const prevASRResult = captionList.find(item => item.userId === userId);
          if (prevASRResult) {
            prevASRResult.changingText = res.voice_text_str;
            prevASRResult.changingIndex = res.index;
          } else {
            captionList.push({
              userId,
              resultText: '',
              currentResultIndex: -1,
              changingIndex: res.index,
              changingText: res.voice_text_str,
            });
          }
        }
        setCaptionList(captionList);
      };
    }

    // 识别错误
    asr.OnError = (res) => {
      Toast.error(`语音识别失败：${res}`);
      // alert(`语音识别失败: ${res}`);
      console.log('语音识别失败', res, typeof res);
    };
  };

  const uninstallASREvents = (asr) => {
    asr.OnError = () => {};
    asr.OnSentenceEnd = () => {};
    asr.OnRecognitionResultChange = () => {};
  };

  const getToken = async () => {
    const result = await getFederationToken();
    setToken(result.Token);
    setSecretKey(result.TmpSecretKey);
    setSecretId(result.TmpSecretId);
    setAppId(result.appId);
  };


  const handleJoin = async () => {
    await getToken();
    await RTC.handleJoin();
    await RTC.handlePublish();
  };

  const handleLeave = async () => {
    shareRTC && shareRTC.handleLeave();
    await RTC.handleLeave();
  };

  const setState = (type, value) => {
    switch (type) {
      case 'join':
        setIsJoined(value);
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
        if (enableASR) {
          startASR(stream);
        }
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

    if (asrList.has(userID)) {
      const asr = asrList.get(userID);
      uninstallASREvents(asr);
      asr.stop();
      asrList.delete(userID);
      setTextMinutesResultList(textMinutesResultList.filter(item => item.userId !== userID));
      setCaptionList(captionList.filter(item => item.userId !== userID));
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

              <br/>
              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button disabled={isJoined} id="join" variant="contained" color="primary" className={ isJoined ? styles.forbidden : ''} onClick={handleJoin}>JOIN</Button>
                <Button id="leave" variant="contained" color="primary" onClick={handleLeave}>LEAVE</Button>
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
              {mountFlag && <Typography>{a18n('实时语音识别')}</Typography>}
            </AccordionSummary>
            <AccordionDetails className={styles['accordion-details-container']}>
              <FormControl component="fieldset">
                <FormLabel component="legend">场景</FormLabel>
                <RadioGroup row aria-label="scene" name="row-radio-buttons-group" value={scene} onChange={e => setScene(e.target.value)}>
                  <FormControlLabel value="caption" control={<Radio disabled={enableASR} color="primary"/>} label="实时字幕" />
                  <FormControlLabel value="text-minutes" control={<Radio disabled={enableASR} color="primary"/>} label="会议纪要" />
                </RadioGroup>
              </FormControl>

              <div className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <Button disabled={enableASR || !isJoined} id="start-asr" variant="contained" color="primary" className={ enableASR || !isJoined ? styles.forbidden : ''} onClick={handleStartASR}>START</Button>
                <Button disabled={!enableASR || !isJoined} id="stop-asr" variant="contained" color="primary" className={ !enableASR || !isJoined ? styles.forbidden : ''} onClick={handleStopASR}>STOP</Button>
              </div>
            </AccordionDetails>
          </Accordion>

          {/* 用户列表 */}
          <div className={clsx(styles['user-list-container'])}>
            <UserList localStreamConfig={localStreamConfig} remoteStreamConfigList={remoteStreamConfigList}>
            </UserList>
          </div>
          {/* 相关资源 */}
          <RelatedResources
            language={language}
            resources={[
              { name: a18n('TRTC Web SDK 接入实时语音识别'),
                link: 'https://cloud.tencent.com/document/product/1093/68499',
                enLink: 'https://cloud.tencent.com/document/product/1093/68499',
              },
            ]}></RelatedResources>
        </div>
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
        { scene === 'caption' ? <CaptionList captionList={captionList}/> : <TextMinutesList textMinutesResultList={textMinutesResultList} /> }
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
  const result = getNavConfig('improve-asr');
  return {
    props: {
      ...result,
    },
  };
};

function CaptionItem(props) {
  const { item } = props;
  const ref = useRef(null);
  useEffect(() => {
    ref.current.scrollTop = ref.current.scrollHeight;
  });
  return (
    <div >
      <div>{item.userId}:</div>
      <div ref={ref} className={clsx(styles['caption-item'])}>{item.resultText}{item.changingIndex > item.currentResultIndex ? item.changingText : ''}</div>
    </div>
  );
}


function CaptionList(props) {
  const { captionList } = props;

  return (<div className={clsx(styles['caption-list'])}>
    <h3>实时字幕：</h3>
    {
     captionList.map(item => <CaptionItem key={item.userId} item={item} />)
    }
  </div>);
}

function TextMinutesList(props) {
  const { textMinutesResultList } = props;

  const exportTxt = () => {
    const blob = new Blob(textMinutesResultList.map(item => `${item.userId}${item.isMe ? '(我)' : ''} ${item.date.toLocaleString()} \n${item.text} \n`));
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = '会议纪要.txt';
    a.click();
  };

  return (<div className={clsx(styles['text-minutes-wrapper'])}>
    <div className={clsx(styles['text-minutes-list'])}>
    <h3>文字会议纪要：</h3>
    {
     textMinutesResultList.map(item => (
        <div key={item.userId + item.date} className={clsx(styles.item)}>
          <div><span className={clsx(styles.userId)}>{item.userId}{item.isMe ? '(我)' : ''}</span> {item.date.toLocaleString()}</div>
          <div>{item.text}</div>
        </div>))
    }
    </div>
    {
      textMinutesResultList.length > 0 && <Button onClick={exportTxt} color="primary" variant="contained" className={clsx(styles['export-button'])}>导出 txt 文件</Button>
    }
    </div>);
}
