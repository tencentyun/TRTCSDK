/* eslint-disable jsx-a11y/no-noninteractive-element-interactions */
/* eslint-disable jsx-a11y/click-events-have-key-events */
import React, { useState } from 'react';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import {
  TRTCScreenCaptureSourceInfo,
  TRTCScreenCaptureSourceType,
} from 'trtc-electron-sdk/liteav/trtc_define';
import { trtcUtil } from '../../utils/trtc-edu-sdk';
import './index.scss';

interface PreviewProps {
  screenInfo: TRTCScreenCaptureSourceInfo;
}

function PreviewScreenOrWindow(props: PreviewProps) {
  const { screenInfo } = props;
  return (
    <canvas
      className="preview-canvas"
      width={screenInfo.thumbBGRA?.width}
      height={screenInfo.thumbBGRA?.height}
      ref={(ref: HTMLCanvasElement | null) => {
        if (ref === null) return;
        const ctx: CanvasRenderingContext2D | null = ref.getContext('2d');
        const img: ImageData = new ImageData(
          new Uint8ClampedArray(screenInfo.thumbBGRA?.buffer as any),
          screenInfo.thumbBGRA?.width,
          screenInfo.thumbBGRA?.height
        );
        if (ctx != null) {
          ctx.putImageData(img, 0, 0);
        }
      }}
      data-id={screenInfo.sourceId}
    />
  );
}

interface ShareScreenSelectionProps {
  onSelect: (id: string, screenInfo: TRTCScreenCaptureSourceInfo) => void;
  selected: string;
}

function ShareScreenSelection(props: ShareScreenSelectionProps) {
  const { onSelect: onParentSelection, selected } = props;
  const screenCaptureList: Array<TRTCScreenCaptureSourceInfo> =
    trtcUtil.trtcEducation?.rtcCloud.getScreenCaptureSources(160, 90, 32, 32);
  const screenTypeList = screenCaptureList.filter(
    (screen) =>
      screen.type ===
      TRTCScreenCaptureSourceType.TRTCScreenCaptureSourceTypeScreen
  );
  const windowTypeList = screenCaptureList.filter(
    (screen) =>
      screen.type ===
        TRTCScreenCaptureSourceType.TRTCScreenCaptureSourceTypeWindow &&
      !screen.isMinimizeWindow
  );

  function onSelect(
    event: React.SyntheticEvent,
    screenInfo: TRTCScreenCaptureSourceInfo
  ) {
    const currentTarget = event.currentTarget as HTMLElement;
    const id = currentTarget.dataset.id as string;
    onParentSelection(id, screenInfo);
  }
  return (
    <div className="share-screen-selection">
      <div>
        <h3>屏幕</h3>
        <ul className="preview-list screen-preview-list">
          {screenTypeList.map((screen) => {
            return (
              <li
                className={`preview-list-item ${
                  screen.sourceId === selected ? 'selected' : ''
                }`}
                key={screen.sourceId}
                data-id={screen.sourceId}
                onClick={(e) => onSelect(e, screen)}
              >
                <div className="preview-wrapper">
                  <PreviewScreenOrWindow screenInfo={screen} />
                </div>
                <div className="preview-name">{screen.sourceName}</div>
              </li>
            );
          })}
        </ul>
      </div>
      <div>
        <h3>窗口</h3>
        <ul className="preview-list window-preview-list">
          {windowTypeList.map((win) => {
            return (
              <li
                className={`preview-list-item ${
                  win.sourceId === selected ? 'selected' : ''
                }`}
                key={win.sourceId}
                data-id={win.sourceId}
                onClick={(e) => onSelect(e, win)}
              >
                <div className="preview-wrapper">
                  <PreviewScreenOrWindow screenInfo={win} />
                </div>
                <div className="preview-name">{win.sourceName}</div>
              </li>
            );
          })}
        </ul>
      </div>
    </div>
  );
}

interface ShareScreenSelectionDialogProps {
  show: boolean | false;
  onCancel: () => void;
  onConfirm: (
    id: string,
    screenSource: TRTCScreenCaptureSourceInfo | null
  ) => void;
  preselected?: string | '';
}
function ShareScreenSelectionDialog(props: ShareScreenSelectionDialogProps) {
  const prelog = '[Share-Screen-Selection-Dialog';
  console.warn(`${prelog}.props:`, props);
  const [selected, setSelected] = useState<string>('');
  const [screenInfo, setScreenInfo] =
    useState<TRTCScreenCaptureSourceInfo | null>(null);
  const { show, onCancel, onConfirm, preselected } = props;

  const onSelect = (id: string, screenSource: TRTCScreenCaptureSourceInfo) => {
    setSelected(id);
    setScreenInfo(screenSource);
  };

  const handleConfirm = () => {
    if (screenInfo) {
      onConfirm(selected, screenInfo);
      setSelected('');
    } else {
      // eslint-disable-next-line no-alert
      alert('请选择需要分享的屏幕或窗口'); // To-do
    }
  };

  const currentSelected = selected || preselected || '';

  return (
    <Dialog
      className="screen-sharing-selection-dialog"
      fullWidth
      maxWidth="md"
      open={show}
      onClose={onCancel}
      aria-labelledby="screen-sharing-selection-dialog-title"
    >
      <DialogTitle id="screen-sharing-selection-dialog-title">
        选择要分享的屏幕或应用窗口
      </DialogTitle>
      <DialogContent dividers>
        <ShareScreenSelection onSelect={onSelect} selected={currentSelected} />
      </DialogContent>
      <DialogActions>
        <Button color="primary" onClick={handleConfirm}>
          Confirm
        </Button>
        <Button onClick={onCancel}>Cancel</Button>
      </DialogActions>
    </Dialog>
  );
}

ShareScreenSelectionDialog.defaultProps = {
  preselected: '',
};

export default ShareScreenSelectionDialog;
