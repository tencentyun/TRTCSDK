import a18n from 'a18n'
import React from 'react';
import Layout from '../../layout';
import './index.scss';
import { openUrlInBrowser } from '../../../utils/utils';

function anchorClickHandler(evt) {
  evt.preventDefault();
  openUrlInBrowser(evt.target.href);
}

const desc = (clickHandler) => (
  <React.Fragment>
    <p>
      {a18n('本示例用于演示混流编码与CDN旁路直播，详细功能说明请参阅腾讯云官网文档：')}
      <a href="https://cloud.tencent.com/document/product/647/16827" onClick={clickHandler}>{a18n('云端混流转码')}</a>{a18n('。')}
    </p>
    <p>
      {a18n('在')}<a href="https://cloud.tencent.com/document/product/647/16826" onClick={clickHandler}> {a18n('CDN 直播观看')} </a>
      {a18n('和')} <a href="https://cloud.tencent.com/document/product/647/16823" onClick={clickHandler}> {a18n('云端录制回放')} </a>
      {a18n(
        '等应用场景中，常需要将 TRTC 房间里的多路音视频流混合成一路，您可以使用腾讯云服务端的 MCU 的混流转码集群完成该项工作。MCU 集群\n      能将多路音视频流进行按需混合，并将最终生成的视频流分发给直播 CDN 和云端录制系统。'
      )}
    </p>
    <p>
      {a18n('接口说明请参阅腾讯云官网API：')}
      <a onClick={clickHandler}
        href="https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/TRTCCloud.html#setMixTranscodingConfig"
      >
        {a18n('混流编码参数设置')}
      </a>{a18n('。')}
    </p>
  </React.Fragment>
);

function MediaStreamMix(props) {
  return (
    <div className="advanced-scene media-stream-mix">
      <Layout
        title={a18n('混流编码与CDN直播')}
        type="video-stream-mix"
        renderDesc={() => desc(anchorClickHandler)}
        codePath="code/advanced/video-stream-mix/index.js">
        <div className="video-view-preview">
          <div className="video-wrapper local-user">
            <div className="user-desc">
              <span className="user-type">{a18n('本地用户')}</span>
            </div>
            <div id="localVideoWrapper"></div>
          </div>
          <div className="video-wrapper local-screen-share">
            <div className="user-desc">
              <span className="user-type">{a18n('本地屏幕分享')}</span>
            </div>
            <div id="localScreenShareWrapper"></div>
          </div>
        </div>
        <div className="video-mixed-wrapper">
          <div><span className="user-type">{a18n('混流视频预览')}</span></div>
          <div id="mixedVideoWrapper">
            <div id="mixedVideoPlayer"></div>
          </div>
        </div>
      </Layout>
    </div>
  );
};

export default MediaStreamMix;
