import a18n from 'a18n';
import VideoCall from '../examples/basic/video-call';
import AudioCall from '../examples/basic/audio-call';
import VideoLive from '../examples/basic/video-live';
import AudioLive from '../examples/basic/audio-live';
import ScreenShare from '../examples/basic/screen-share';
import DeviceTest from '../examples/basic/device-test';
import VideoQuality from '../examples/advanced/video-quality';
import MediaStreamMix from '../examples/advanced/media-stream-mix';
import BigSmallStream from '../examples/advanced/big-small-stream';
import Beauty from '../examples/advanced/beauty-sdk-inner';
import ConnectOtherRoom from '../examples/advanced/connect-other-room';
import SwitchRole from '../examples/advanced/switch-role';
import CallStatistics from '../examples/advanced/call-statistics';
import VolumeControl from '../examples/advanced/volume-control';
import RenderControl from '../examples/advanced/render-control';

const navConfig = {
  basic: {
    name: a18n('基础示例'),
    content: [
      {
        name: a18n('视频通话'),
        path: "basic/video-call",
        pageContent: VideoCall
      },
      {
        name: a18n('语音通话'),
        path: "basic/audio-call",
        pageContent: AudioCall
      },
      {
        name: a18n('屏幕分享'),
        path: "basic/screen-share",
        pageContent: ScreenShare
      },
      {
        name: a18n('视频互动直播'),
        path: "basic/video-live",
        pageContent: VideoLive
      },
      {
        name: a18n('语音互动直播'),
        path: "basic/audio-live",
        pageContent: AudioLive
      },
      {
        name: a18n('设备检测'),
        path: "basic/device-test",
        pageContent: DeviceTest
      }
    ]
  },
  advanced: {
    name: a18n('高级特性'),
    content: [
      {
        name: a18n('画质设定'),
        path: "advanced/video-quality",
        pageContent: VideoQuality
      },
      {
        name: a18n('混流编码与CDN直播'),
        path: "advanced/media-stream-mix",
        pageContent: MediaStreamMix
      },
      {
        name: a18n('大小画面'),
        path: "advanced/big-small-stream",
        pageContent: BigSmallStream
      },
      {
        name: a18n('渲染控制'),
        path: "advanced/render-control",
        pageContent: RenderControl
      },
      {
        name: a18n('内置美颜'),
        path: "advanced/beauty",
        pageContent: Beauty
      },
      {
        name: a18n('跨房连麦'),
        path: "advanced/connect-other-room",
        pageContent: ConnectOtherRoom
      },
      {
        name: a18n('切换角色'),
        path: "advanced/switch-role",
        pageContent: SwitchRole
      },
      {
        name: a18n('通话统计'),
        path: "advanced/call-statistics",
        pageContent: CallStatistics
      },
      {
        name: a18n('音量控制'),
        path: "advanced/volume-control",
        pageContent: VolumeControl
      }
    ]
  }
}

export default navConfig;
