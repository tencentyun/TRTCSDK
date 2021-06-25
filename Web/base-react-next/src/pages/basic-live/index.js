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
import { Button, Accordion, AccordionSummary, AccordionDetails, Typography, Radio, RadioGroup, FormControlLabel, FormControl, Tooltip, makeStyles, Switch, Grid } from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import HelpIcon from '@material-ui/icons/Help';
import SideBar from '@components/SideBar';
import styles from '@styles/common.module.scss';
import { withStyles } from '@material-ui/core/styles';

const mobile = require('is-mobile');
const DynamicDeviceSelect = dynamic(import('@components/DeviceSelect'), { ssr: false });
const DynamicRtc = dynamic(import('@components/RtcClient/basic-live-rtc-client'), { ssr: false });
const DynamicShareRtc = dynamic(import('@components/ShareRTC'), { ssr: false });

const useStyles = makeStyles(theme => ({
  'role-switch-container': {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    fontSize: '1rem',
    height: 42,
  },
  'switch-button-container': {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-evenly',
    flex: 1,
  },
  'role-select': {
    display: 'flex',
    flex: 1,
    justifyContent: 'space-between',
  },
  'role-anchor': {
    marginLeft: 8,
    marginRight: 8,
  },
  'role-audience': {
    marginRight: 0,
  },
  'icon-tips': {
    marginLeft: theme.spacing(1),
    marginRight: theme.spacing(1),
  },
}));

const AntSwitch = withStyles(theme => ({
  root: {
    width: 36,
    height: 20,
    padding: 0,
    display: 'flex',
  },
  switchBase: {
    padding: 2,
    color: theme.palette.grey[500],
    '&$checked': {
      transform: 'translateX(12px)',
      color: theme.palette.common.white,
      '& + $track': {
        opacity: 1,
        backgroundColor: '#006EFF',
        borderColor: theme.palette.primary.main,
      },
    },
  },
  thumb: {
    width: 16,
    height: 16,
    boxShadow: 'none',
  },
  track: {
    border: `1px solid ${theme.palette.grey[500]}`,
    borderRadius: 20 / 2,
    opacity: 1,
    backgroundColor: theme.palette.common.white,
  },
  checked: {},
}))(Switch);
const BlueRadio = withStyles({
  root: {
    '&$checked': {
      color: '#006EFF',
    },
  },
  checked: {},
})(props => <Radio color="default" {...props} />);

const audience = 'audience';
const anchor = 'anchor';
export default function BasicRtc(props) {
  const classes = useStyles();
  const { activeId, navConfig } = props;
  const video = true;
  const audio = true;
  const mode = 'live';
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
  const [userRole, setUserRole] = useState(audience);
  const [changeRoleDisable, setChangeRoleDisable] = useState(true);
  const [isManualChangeRole, setIsManualChangeRole] = React.useState(false);

  const handleChange = () => {
    !changeRoleDisable && setIsManualChangeRole(!isManualChangeRole);
  };

  useEffect(() => {
    handlePageUrl();
    setUseStringRoomID(getUrlParam('useStringRoomID') === 'true');
    setIsMobile(mobile());
  }, []);

  const handleJoin = async () => {
    await RTC.handleJoin();
    setChangeRoleDisable(false);
  };

  const handlePublish = async () => {
    await RTC.handlePublish(isManualChangeRole).then((res) => {
      if (res) {
        setUserRole(anchor);
        setChangeRoleDisable(true);
      }
    });
  };

  const handleUnPublish = async () => {
    await RTC.handleUnPublish();
    await RTC.destroyLocalStream();

    setChangeRoleDisable(false);
  };

  const handleLeave = async () => {
    shareRTC && shareRTC.handleLeave();
    await RTC.handleLeave();
    setChangeRoleDisable(true);
    setIsManualChangeRole(false);
  };

  const changeRole = async () => {
    const targetRole = userRole === audience ? anchor : audience;
    setIsPublished(true);
    await RTC.changeRole(targetRole)
      .then((res) => {
        res && setUserRole(targetRole);
      })
      .finally(() => {
        setIsPublished(false);
      });
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
    const streamType = stream && stream.getType();
    const userID = stream && stream.getUserId();
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
                <Button id="publish" variant="contained" color="primary" className={ isPublished ? styles.forbidden : '' } onClick={handlePublish}>PUBLISH</Button>
                <Button id="unpublish" variant="contained" color="primary" onClick={handleUnPublish}>UNPUBLISH</Button>
              </div>

              <FormControl component="fieldset" className={clsx(styles['button-container'], isMobile && styles['mobile-device'])}>
                <div className={classes['role-switch-container']}>
                  <span>角色切换方式：</span>
                  <div className={classes['switch-button-container']} onClick={handleChange}>
                    <Grid item>自动</Grid>
                    <Grid item className={classes['switch-button']}>
                      <AntSwitch size="medium" checked={isManualChangeRole} disabled={changeRoleDisable} name="isManualChangeRole" />
                    </Grid>
                    <Grid item>手动</Grid>
                  </div>
                  <Tooltip title='Audience 身份进房不推流; Anchor 身份进房主动推流。推流时自动切换到 Anchor; 关闭推流自动切换到 Audience'><HelpIcon className={classes['icon-tips']}></HelpIcon></Tooltip>
                </div>

                <RadioGroup aria-label="gender" name="gender" value={userRole} className={classes['role-switch-container']} onChange={changeRole}>
                  <Typography>角色：</Typography>
                  <div className={classes['role-select']}>
                    <FormControlLabel value="anchor" control={<BlueRadio />} disabled={!isManualChangeRole || isPublished} label="Anchor" className={classes['role-anchor']} />
                    <FormControlLabel value="audience" control={<BlueRadio />} disabled={!isManualChangeRole || isPublished} label="Audience" className={classes['role-audience']} />
                  </div>
                </RadioGroup>
              </FormControl>
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
      </div>
    </div>);

  return (
    <div className={clsx(styles['page-container'], isMobile && styles['mobile-device'])}>
      <Head>
        <title>基础音视频通话</title>
        <meta name="description" content="basic rtc communication by Tencent webRTC" />
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
          role={userRole}
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
        onActiveExampleChange={handlePageChange}
        isMobile={isMobile}
      >
      </SideBar>
      {pageContent()}
    </div>
  );
}

export const getStaticProps = () => {
  const result = getNavConfig('basic-live');
  return {
    props: {
      ...result,
    },
  };
};
