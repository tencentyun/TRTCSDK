import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import { TRTCScreenCaptureSourceInfo } from 'trtc-electron-sdk/liteav/trtc_define';
import { USER_EVENT_NAME } from '../../../constants';
import ShareScreenSelectionDialog from '../../components/share-screen-selection-dialog';

import './index.scss';

function ShareScreenSelect() {
  const [isVisible, setIsVisible] = useState(true);
  const selected = useSelector(
    (state: any) => state.user.sharingScreenInfo.sourceId
  );

  const onCancel = () => {
    setIsVisible(false);
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.CANCEL_CHANGE_SHARE
    );
  };

  const onConfirm = (
    id: string,
    screenSource: TRTCScreenCaptureSourceInfo | null
  ) => {
    setIsVisible(false);
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.CONFIRM_CHANGE_SHARE,
      screenSource
    );
  };

  return (
    <div className="share-screen-select-page">
      <ShareScreenSelectionDialog
        show={isVisible}
        onCancel={onCancel}
        onConfirm={onConfirm}
        preselected={selected}
      />
    </div>
  );
}

export default ShareScreenSelect;
