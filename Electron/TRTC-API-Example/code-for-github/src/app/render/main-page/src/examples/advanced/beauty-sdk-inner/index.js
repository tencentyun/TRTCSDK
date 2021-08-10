import a18n from 'a18n'
import React from 'react';
import { TRTCBeautyStyle } from 'trtc-electron-sdk';
import Layout from '../../layout';
import './index.scss';

const renderDesc = () => (
  <React.Fragment>
    <p>{a18n('内置美颜功能支持设置美颜、美白、红润效果级别。')}</p>
    <ul>
      <li>{a18n('美颜级别，取值范围0 - 9，0表示关闭，1 - 9值越大，效果越明显')}</li>
      <li>{a18n('美白级别，取值范围0 - 9，0表示关闭，1 - 9值越大，效果越明显')}</li>
      <li>{a18n('红润级别，取值范围0 - 9，0表示关闭，1 - 9值越大，效果越明显，该参数 windows 平台暂未生效')}</li>
    </ul>
    <p>{a18n(
        'SDK 内部集成了两套风格不同的磨皮算法，一套我们取名叫“光滑”，适用于美女秀场，效果比较明显。 \n    另一套我们取名“自然”，磨皮算法更多地保留了面部细节，主观感受上会更加自然。'
      )}</p>
  </React.Fragment>
)

function Beauty(props) {
  const isWindows = process.platform === 'win32';
  return (
    <div className="advanced-scene beauty-sdk-inner">
      <Layout
        title={a18n('内置美颜')}
        type="beauty-sdk-inner"
        renderDesc={() => renderDesc()}
        codePath="code/advanced/beauty-sdk-inner/index.js"
        >
          <form name="beautyParamsForm" className="config-form beauty-style-form">
            <div className="form-line">
              <span className="form-item-label">{a18n('美颜风格：')}</span>
              <input type="radio" name="style" id="beautyStyleSmooth" value={TRTCBeautyStyle.TRTCBeautyStyleSmooth} defaultChecked/><label htmlFor="beautyStyleSmooth">{a18n('光滑 - 适合娱乐场景，效果比较明显')}</label>
              <input type="radio" name="style" id="beautyStyleNature" value={TRTCBeautyStyle.TRTCBeautyStyleNature}/><label htmlFor="beautyStyleNature">{a18n('自然 - 更多地保留了面部细节，主观感受上会更加自然')}</label>
            </div>
            <div className="form-line inline-flex">
              <div className="inline-flex-item">
                <label className="form-item-label">{a18n('美颜级别：')}</label>
                <input type="range" name="beauty" max="9" min="0" />
              </div>
              <div className="inline-flex-item">
                <label className="form-item-label">{a18n('美白级别：')}</label>
                <input type="range" name="white" max="9" min="0" />
              </div>
              <div className="inline-flex-item" hidden={isWindows}>
                <label className="form-item-label">{a18n('红润级别(暂不支持windows)：')}</label>
                <input type="range" name="ruddiness" max="9" min="0" />
              </div>
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
          </div>
        </Layout>
    </div>
  );
}

export default Beauty;
