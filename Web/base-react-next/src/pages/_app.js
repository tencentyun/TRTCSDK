import a18n from 'a18n';
import React, { useState, useEffect } from 'react';
import Head from 'next/head';
import dynamic from 'next/dynamic';
import Notification from '@components/Toast/notification';
import { createMuiTheme, ThemeProvider } from '@material-ui/core/styles';
import '@styles/globals.scss';
import Cookies from 'js-cookie';
import { getLanguage } from '@utils/common';
import { MyContext } from '@utils/context-manager';
import ConfirmDialog from '@components/Modal/confirmDialog';
import 'rtc-device-detector-react/dist/index.css';
const DeviceDetector = dynamic(import('@components/DeviceDetector/detector'), { ssr: false });

const theme = createMuiTheme({
  palette: {
    primary: {
      main: '#006eff',
    },
  },
});

a18n.addLocaleResource('en', require('@locales/en.json'));
a18n.addLocaleResource('zh-CN', require('@locales/zh-CN.json'));

function MyApp({ Component, pageProps }) {
  const [language, setLanguage] = useState('');
  const changeLanguage = (language) => {
    a18n.setLocale(language);
    Cookies.set('trtc-lang', language);
    setLanguage(language);
  };

  useEffect(() => {
    const language = getLanguage();
    a18n.setLocale(language);
    setLanguage(language);
  }, []);

  return (
    <div suppressHydrationWarning style={{ height: '100%' }}>
      <Head>
        <link rel="icon" href="/favicon.ico" />
        <meta name="description" content="腾讯云实时音视频在线演示"></meta>
        <meta name="keywords" content="WebRTC, Tencent, RTC, TRTC, 音视频解决方案, 语音通话, 视频通话, 互动直播"></meta>
        <script src="./graph.js" type="text/javascript"></script>
        <script src="https://cdn-go.cn/aegis/aegis-sdk/latest/aegis.min.js"></script>
        <script src="./statistic.js"></script>
      </Head>
      <ThemeProvider theme={theme}>
        <MyContext.Provider value={{ changeLanguage }}>
          <Component {...pageProps} language={language} />
        </MyContext.Provider>
      </ThemeProvider>
      <Notification></Notification>
      <ConfirmDialog></ConfirmDialog>
      <DeviceDetector language={language}></DeviceDetector>
    </div>
  );
}

export default MyApp;
