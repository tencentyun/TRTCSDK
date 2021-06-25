import React, { useState, useEffect } from 'react';
import QRCode from 'qrcode.react';

/**
 * props 组件参数
 * @param {string} props.url 生成二维码的url
 * @param {string/number} props.roomID roomID，动态生成url
 */
export default function QRCoder({ url, roomID }) {
  const [qrCoderUrl, setQrCoderUrl] = useState('url');

  if (!url) {
    useEffect(() => {
      const param = location.search === '' ? `?roomID=${roomID}` : `&roomID=${roomID}`;
      setQrCoderUrl(`${location.href}${param}`);
    }, [roomID]);
  }

  return (
    <QRCode
      value={qrCoderUrl}
      size={260}
      fgColor="#000000"/>
  );
}
