import React from 'react';
import Layout from '../../layout';
import './index.scss';

function DeviceTest() {
  return (
    <div className="basic-scene device-test">
      <Layout
        title="设备检查"
        type="device-test"
        desc="SDK 提供接口，用于网络、摄像头、麦克风、扬声器检测。"
        codePath="code/basic/device-test/index.js"
      >
        <div className="device-test-item">
          <div>网络检测：网络状态 -- <span id="networkSpeed">检测中...</span></div>
        </div>
        <div className="device-test-item camera-test">
          <div>摄像头检测：</div>
          <div id="localVideoWrapper">检测中...</div>
          <div>（<span className="notice-label">如果不能看到图像，说明摄像头不可用</span>）</div>
        </div>
        <div className="device-test-item">
          <div>麦克分检测：当前音量 -- <span id="microphoneVolume">0</span>（<span className="notice-label">请对着麦克风说话，此处数值大于零，说明麦克风正常</span>）</div>
        </div>
        <div className="device-test-item">
          <div>扬声器检测：当前音量 -- <span id="speakerVolume">0</span>（<span className="notice-label">能听到声音，扬声器音量数值不断变化，说明扬声器正常</span>）</div>
        </div>
      </Layout>
    </div>
  )
}

export default DeviceTest;
