import React from 'react';
import { TRTCBeautyStyle } from 'trtc-electron-sdk';
import Layout from '../../layout';
import './index.scss';

const renderDesc = (
  <React.Fragment>
    <p>内置美颜功能支持设置美颜、美白、红润效果级别。</p>
    <p>SDK 内部集成了两套风格不同的磨皮算法，一套我们取名叫“光滑”，适用于美女秀场，效果比较明显。 
    另一套我们取名“自然”，磨皮算法更多地保留了面部细节，主观感受上会更加自然。</p>
  </React.Fragment>
)

function Beauty(props) {
  return (
    <div className="advanced-scene beauty-sdk-inner">
      <Layout
        title="内置美颜"
        type="beauty-sdk-inner"
        renderDesc={() => renderDesc}
        codePath="code/advanced/beauty-sdk-inner/index.js"
        >
          <form name="beautyParamsForm" className="config-form beauty-style-form">
            <div className="form-line">
              <span className="form-item-label">美颜风格：</span>
              <input type="radio" name="style" id="beautyStyleSmooth" value={TRTCBeautyStyle.TRTCBeautyStyleSmooth} defaultChecked/><label htmlFor="beautyStyleSmooth">光滑 - 适合娱乐场景，效果比较明显</label>
              <input type="radio" name="style" id="beautyStyleNature" value={TRTCBeautyStyle.TRTCBeautyStyleNature}/><label htmlFor="beautyStyleNature">自然 - 更多地保留了面部细节，主观感受上会更加自然</label>
            </div>
            <div className="form-line inline-flex">
              <div className="inline-flex-item">
                <label className="form-item-label">美颜级别：</label>
                <input type="range" name="beauty" max="9" min="0" />
              </div>
              <div className="inline-flex-item">
                <label className="form-item-label">美白级别：</label>
                <input type="range" name="white" max="9" min="0" />
              </div>
              <div className="inline-flex-item">
                <label className="form-item-label">红润级别(暂不支持windows)：</label>
                <input type="range" name="ruddiness" max="9" min="0" />
              </div>
            </div>
          </form>

          <div className="video-view-preview">
            <div className="video-wrapper local-user">
              <div className="user-desc">
                <span className="user-type">本地用户</span>
                <span className="user-role" id="localUserRole"></span>
              </div>
              <div id="localVideoWrapper"></div>
            </div>
          </div>
        </Layout>
    </div>
  )
}

export default Beauty;
