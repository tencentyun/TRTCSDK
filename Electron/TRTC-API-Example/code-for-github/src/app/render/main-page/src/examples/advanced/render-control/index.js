import a18n from 'a18n'
import React from 'react';
import { TRTCVideoFillMode, TRTCVideoMirrorType, TRTCVideoRotation } from 'trtc-electron-sdk';
import Layout from '../../layout';
import './index.scss';
import { openUrlInBrowser } from '../../../utils/utils';

function anchorClickHandler(evt) {
  evt.preventDefault();
  openUrlInBrowser(evt.target.href);
}

const desc = (clickHandler) => (
  <React.Fragment>
    <p>{a18n('视频渲染支持自定义镜像效果、旋转角度和填充模式。')}</p>
    <p>{a18n('设置远端图像的渲染参数：接口')}<a href="https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/TRTCCloud.html#setRemoteRenderParams" onClick={anchorClickHandler}> setRemoteRenderParams </a>{a18n('。')}</p>
    <p>{a18n('设置本地图像（主流）的渲染参数：接口')}<a href="https://web.sdk.qcloud.com/trtc/electron/doc/zh-cn/trtc_electron_sdk/TRTCCloud.html#setLocalRenderParams" onClick={anchorClickHandler}> setLocalRenderParams </a>{a18n('。')}</p>
  </React.Fragment>
);

function VideoRenderParams(props) {
  return (
    <div className="advanced-scene render-control">
      <Layout
        title={a18n('渲染控制')}
        type="render-control"
        renderDesc={() => desc(openUrlInBrowser)}
        codePath="code/advanced/render-control/index.js">
        <form name="renderParamsForm" className="config-form render-params-form">
          <div className="form-line">
            <span className="form-item-label">{a18n('镜像：')}</span>
            <input type="radio" name="mirrorType" id="mirrorEnable" value={TRTCVideoMirrorType.TRTCVideoMirrorType_Enable} defaultChecked/><label htmlFor="mirrorEnable">{a18n('开启')}</label>
            <input type="radio" name="mirrorType" id="mirrorDisable" value={TRTCVideoMirrorType.TRTCVideoMirrorType_Disable}/><label htmlFor="mirrorDisable">{a18n('关闭')}</label>
          </div>
          <div className="form-line">
            <span className="form-item-label">{a18n('旋转角度：')}</span>
            <input type="radio" name="rotation" id="rotate0" value={TRTCVideoRotation.TRTCVideoRotation0}/><label htmlFor="rotate0">{a18n('0度')}</label>
            <input type="radio" name="rotation" id="rotate90" value={TRTCVideoRotation.TRTCVideoRotation90} defaultChecked/><label htmlFor="rotate90">{a18n('90度')}</label>
            <input type="radio" name="rotation" id="rotate180" value={TRTCVideoRotation.TRTCVideoRotation180}/><label htmlFor="rotate180">{a18n('180度')}</label>
            <input type="radio" name="rotation" id="rotate270" value={TRTCVideoRotation.TRTCVideoRotation270}/><label htmlFor="rotate270">{a18n('270度')}</label>
          </div>
          <div className="form-line">
            <span className="form-item-label">{a18n('填充模式：')}</span>
            <input type="radio" name="fillMode" id="fillMode" value={TRTCVideoFillMode.TRTCVideoFillMode_Fill} defaultChecked/><label htmlFor="fillMode">{a18n('Fill - 填充')}</label>
            <input type="radio" name="fillMode" id="fitMode" value={TRTCVideoFillMode.TRTCVideoFillMode_Fit}/><label htmlFor="fitMode">{a18n('Fit - 适应')}</label>
          </div>
        </form>

        <div className="video-view-preview">
          <div className="video-wrapper local-user">
            <div className="user-desc">
              <span className="user-type">{a18n('本地用户')}</span>
              <span className="user-role" id="localUserRole"></span>
            </div>
            <div id="localVideoWrapper"></div>
          </div>
          <div className="video-wrapper remote-user">
            <div className="user-desc">
              <span className="user-type">{a18n('远程用户')}</span>
              <span className="user-role" id="remoteUserRole"></span>
            </div>
            <div id="remoteVideoWrapper"></div>
          </div>
        </div>
      </Layout>
    </div>
  );
}

export default VideoRenderParams;
