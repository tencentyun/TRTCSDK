import a18n from 'a18n'
import React from 'react';
import Layout from '../../layout';
import './index.scss';

function DeviceTest() {
  return (
    <div className="basic-scene device-test">
      <Layout
        title={a18n('设备检测')}
        type="device-test"
        desc={a18n('SDK 提供接口，用于网络、摄像头、麦克风、扬声器检测。')}
        codePath="code/basic/device-test/index.js"
      >
        <div className="device-test-item">
          <div>{a18n('网络检测：网络状态 --')} <span id="networkSpeed">{a18n('检测中...')}</span></div>
        </div>
        <div className="device-test-item camera-test">
          <div>{a18n('摄像头检测：')}</div>
          <div id="localVideoWrapper">{a18n('检测中...')}</div>
          <div>{a18n('（')}<span className="notice-label">{a18n('如果不能看到图像，说明摄像头不可用')}</span>{a18n('）')}</div>
        </div>
        <div className="device-test-item">
          <div>{a18n('麦克分检测：当前音量 --')} <span id="microphoneVolume">0</span>{a18n('（')}<span className="notice-label">{a18n('请对着麦克风说话，此处数值大于零，说明麦克风正常')}</span>{a18n('）')}</div>
        </div>
        <div className="device-test-item">
          <div>{a18n('扬声器检测：当前音量 --')} <span id="speakerVolume">0</span>{a18n('（')}<span className="notice-label">{a18n('能听到声音，扬声器音量数值不断变化，说明扬声器正常')}</span>{a18n('）')}</div>
        </div>
      </Layout>
    </div>
  );
}

export default DeviceTest;
