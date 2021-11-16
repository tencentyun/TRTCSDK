import React, { useState, useEffect } from 'react';
import { TRTCScreenCaptureSourceInfo } from 'trtc-electron-sdk/liteav/trtc_define';
import { USER_EVENT_NAME } from '../../../constants';
import ComPreviewCamera from '../../components/com-preview-camera';
import ComPreviewScreen from '../../components/com-preview-screen';
import './index.scss';

function SharePreview() {
  const logPrefix = '[share-preview]';
  const [isSharing, setIsSharing] = useState(false);
  const [isMinimized, setIsMinimized] = useState(false);
  const [screenInfo, setScreenInfo] =
    useState<TRTCScreenCaptureSourceInfo | null>(null);
  const [toggle, changeToggle] = useState(true);

  const onChangeHandler = () => {
    changeToggle(!toggle);
  };

  const onToggleWindowSize = () => {
    const newMode = !isMinimized;
    setIsMinimized(newMode);
    window.electron .ipcRenderer.send(
      USER_EVENT_NAME.ON_CHANGE_SHARE_PREVIEW_MODE,
      {
        mode: newMode ? 'MIN' : 'MAX',
      }
    );
  };

  // 初始化时，设置初始数据
  useEffect(() => {
    console.warn(`enter ${logPrefix}.useEffect():`);
    (window as any).electron.ipcRenderer.on(
      USER_EVENT_NAME.INIT_DATA,
      (event: any, args: any) => {
        console.warn(`${logPrefix}.init-share-screen: `, event, args);
        setIsSharing(true);
        setScreenInfo(
          args.currentUser.sharingScreenInfo as TRTCScreenCaptureSourceInfo
        );
      }
    );

    // To-do: 如何销毁这个事件监听？下一行代码取消注释，会导致事件监听失效。
    // return window.electron.ipcRenderer.removeAllListeners('init-share-screen');
  }, []);

  return (
    <div className="page-share-preview">
      <div className="top-tool-bar float-clearfix">
        <div className="float-left">
          <span className="icon-in-class"> </span>
          <span>In Class - Preview Sharing</span>
        </div>
        <div className="float-right">
          {!isMinimized ? (
            <button
              type="button"
              aria-label="Minimize"
              className="icon-min"
              onClick={onToggleWindowSize}
            />
          ) : (
            <button
              type="button"
              aria-label="Maximize"
              className="icon-max"
              onClick={onToggleWindowSize}
            />
          )}
        </div>
      </div>
      {!isMinimized && (
        <>
          <div className="sharing-content">
            {toggle ? (
              <ComPreviewScreen screenInfo={screenInfo} isSharing={isSharing} />
            ) : (
              <ComPreviewCamera isCameraStarted />
            )}
          </div>
          <div className="op-bar" onClick={onChangeHandler}>
            <span>Switch</span>
          </div>
        </>
      )}
    </div>
  );
}

export default SharePreview;
