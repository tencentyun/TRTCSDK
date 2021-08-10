import a18n from 'a18n'
import React from 'react';
import ExampleLayout from '../../layout';
import './index.scss';

function BigSmallStream() {
  return (
    <div className="advanced-scene big-small-stream">
      <ExampleLayout
        title={a18n('大小画面')}
        renderDesc={() => {
          return (
            <React.Fragment>
              <p>{a18n('大小画面(双路编码), 可开启大小画面双路编码模式')}</p>
              <p>
                {a18n('如果当前用户是房间中的主要角色（例如主播、老师、主持人等），并且使用 PC 或者 Mac 环境，可以开启该模式。')}<br/>
                {a18n('开启该模式后，当前用户会同时输出【高清】和【低清】两路视频流（但只有一路音频流）。')}<br/>
                {a18n('对于开启该模式的当前用户，会占用更多的网络带宽，并且会更加消耗 CPU 计算资源。')}
              </p>
              <p>
                {a18n('对于同一房间的远程观众而言：')}<br/>
                {a18n('- 如果用户的下行网络很好，可以选择观看【高清】画面')}<br/>
                {a18n('- 如果用户的下行网络较差，可以选择观看【低清】画面')}
              </p>
            </React.Fragment>
          );
        }}
        showPreview={false}
        type="big-small-stream"
        codePath="code/advanced/big-small-stream/index.js"
      >
        <div className="video-view-preview">
          <div className="remote-preference">
          </div>
          <div className="video-list-section">
            <div className="video-wrapper local-user">
              <div className="user-desc">
                <span className="user-type">{a18n('本地用户')}</span>
                <span className="user-role" id="localUserRole"></span>
              </div>
              <div id="localVideoWrapper"></div>
              <div className="local-statistic">
                userid: <span className='statistic-userid'></span><br/>
                width: <span className='statistic-width'></span><br/>
                height: <span className='statistic-height'></span><br/>
                frameRate: <span className='statistic-frameRate'></span><br/>
                videoBitrate: <span className='statistic-videoBitrate'></span><br/>
                streamType: <span className='statistic-streamType'></span><br/>
              </div>
            </div>
            <div className="video-wrapper remote-user">
              <div className="user-desc">
                <span className="user-type">{a18n('远程用户')}</span>
                <span className="user-role" id="remoteUserRole"></span>
              </div>
              <div id="remoteVideoWrapper"></div>
              <div className="remote-statistic">
                userid: <span className='statistic-userid'></span><br/>
                width: <span className='statistic-width'></span><br/>
                height: <span className='statistic-height'></span><br/>
                frameRate: <span className='statistic-frameRate'></span><br/>
                videoBitrate: <span className='statistic-videoBitrate'></span><br/>
                streamType: <span className='statistic-streamType'></span><br/>
              </div>
            </div>
          </div>
        </div>
      </ExampleLayout>
    </div>
  );
};

export default BigSmallStream;
