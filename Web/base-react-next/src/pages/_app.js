import React from 'react';
import Head from 'next/head';
import Notification from '@components/Toast/notification';
import { createMuiTheme, ThemeProvider } from '@material-ui/core/styles';
import '@styles/globals.scss';


const theme = createMuiTheme({
  palette: {
    primary: {
      main: '#006eff',
    },
  },
});

function MyApp({ Component, pageProps }) {
  return (
    <div suppressHydrationWarning style={{ height: '100%' }}>
      <Head>
        <link rel="icon" href="/favicon.ico" />
        <script src="./graph.js" type="text/javascript"></script>
      </Head>
      <ThemeProvider theme={theme}>
        <Component {...pageProps} />
      </ThemeProvider>
      <Notification></Notification>
    </div>
  );
}

export default MyApp;
