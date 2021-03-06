import React, { useEffect } from 'react';
import Head from 'next/head';
import { handlePageUrl } from '@utils/common';

const Home = () => {
  useEffect(() => {
    // 默认跳转到 basic-rtc 页面
    handlePageUrl('basic-rtc');
  }, []);

  return (
    <div>
      <Head>
        <title>login</title>
        <meta name="description" content="Generated by create next app" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
    </div>
  );
};

export async function getStaticProps() {
  return {
    props: {
    },
  };
}

export default Home;
