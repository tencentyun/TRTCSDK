import a18n from 'a18n';
export default {
  basic: {
    name: {
      en: 'Basic Application',
      'zh-CN': a18n('基础应用'),
    },
    content: [
      {
        path: 'basic-rtc',
        name: {
          en: 'Basic RTC Communication',
          'zh-CN': a18n('基础音视频通话'),
        },
      },
      {
        path: 'basic-live',
        name: {
          en: 'Basic RTC Communication',
          'zh-CN': a18n('观众进房'),
        },
      },
      {
        path: 'basic-switch-device',
        name: {
          en: 'Switch Device',
          'zh-CN': a18n('切换音视频设备'),
        },
      },
      {
        path: 'basic-screen-share',
        name: {
          en: 'Screen Share',
          'zh-CN': a18n('屏幕分享'),
        },
      },
      {
        path: 'basic-custom-capture-render',
        name: {
          en: 'Custom Capture Render',
          'zh-CN': a18n('自定义视频采集和渲染'),
        },
      },
    ],
  },

  advanced: {
    name: {
      en: 'Advanced Application',
      'zh-CN': a18n('进阶应用'),
    },
    content: [
      {
        path: 'improve-add-remove-audio',
        name: {
          en: 'Add/Remove Audio Track',
          'zh-CN': a18n('增加/删除音频轨道'),
        },
      },
      {
        path: 'improve-add-remove-video',
        name: {
          en: 'Add/Remove Video Track',
          'zh-CN': a18n('增加/删除视频轨道'),
        },
      },
      {
        path: 'improve-replace-track',
        name: {
          en: 'Replace Video Track',
          'zh-CN': a18n('替换音/视频轨道'),
        },
      },
      {
        path: 'improve-capture-stream-video',
        name: {
          en: 'Capture stream from video',
          'zh-CN': a18n('从媒体标签捕获stream'),
        },
      },
      {
        path: 'improve-capture-stream-canvas',
        name: {
          en: 'Capture stream from canvas',
          'zh-CN': a18n('从canvas捕获stream'),
        },
      },
      {
        path: 'improve-bwe',
        name: {
          en: 'Band/Video Rate',
          'zh-CN': a18n('带宽/视频码率设置'),
        },
      },
      {
        path: 'improve-audio-bitrate',
        name: {
          en: 'Audio BitRate',
          'zh-CN': a18n('音频码率设置'),
        },
      },
      {
        path: 'improve-publishCDNStream',
        name: {
          en: 'Publish CDN Stream',
          'zh-CN': a18n('向腾讯云/其他云CDN推送音视频流'),
        },
      },
      {
        path: 'improve-mixTranscode',
        name: {
          en: 'Mix Transcode',
          'zh-CN': a18n('混流'),
        },
      },
      {
        path: 'improve-cross-room-link',
        name: {
          en: 'Cross-Room Link',
          'zh-CN': a18n('跨房连麦'),
        },
      },
      {
        path: 'improve-proxy',
        name: {
          en: 'Proxy Server',
          'zh-CN': a18n('设置代理'),
        },
      },
      {
        path: 'improve-audio-mixer',
        name: {
          en: 'Improve Audio Mixer',
          'zh-CN': a18n('混音'),
        },
      },
      {
        path: 'improve-record-stream',
        name: {
          en: 'Improve Record Stream',
          'zh-CN': a18n('流录制'),
        },
      },
      {
        path: 'improve-beauty',
        name: {
          en: 'Improve Beauty',
          'zh-CN': a18n('美颜'),
        },
      },
      {
        path: 'improve-water-mark',
        name: {
          en: 'Improve Watermark',
          'zh-CN': a18n('水印'),
        },
      },
      {
        path: 'improve-asr',
        name: {
          en: 'Improve ASR',
          'zh-CN': a18n('实时语音识别'),
        },
      },
    ],
  },

  API: {
    name: {
      en: 'API Document',
      'zh-CN': a18n('API 文档'),
    },
    path: 'https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html',
    enPath: 'https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html'
  },
  Demo: {
    name: {
      en: 'Demo Download',
      'zh-CN': a18n('Demo 下载'),
    },
    path: 'https://github.com/tencentyun/TRTCSDK/tree/master/Web',
  },
  SDK: {
    name: {
      en: 'SDK Download',
      'zh-CN': a18n('SDK 下载'),
    },
    path: 'https://www.npmjs.com/package/trtc-js-sdk',
  },
  Integration: {
    name: {
      en: 'Fast Integration',
      'zh-CN': a18n('快速集成'),
    },
    path: 'https://cloud.tencent.com/document/product/647/16863',
    enPath: 'https://intl.cloud.tencent.com/document/product/647/35607?lang=en'
  },
  Support: {
    name: {
      en: 'Technical Support',
      'zh-CN': a18n('技术支持'),
    },
    path: 'https://cloud.tencent.com/document/product/647/19906',
  }
};
