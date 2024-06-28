English | [简体中文](./README-zh_CN.md)

[WebRTC API Examples](https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/login.html) shows how to use the [WebRTC APIs](https://web.sdk.qcloud.com/trtc/webrtc/doc/en/Client.html) and helps you quickly integrate them into your project.

[WebRTC API Examples](https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/index.html) is based on [Next.js](https://nextjs.org/). You can read the documentation on the website to learn more.

This document describes how to quickly run WebRTC API Examples.

## Directory Structure
```
├── README.md
├── jsconfig.json
├── next.config.js
├── package.json
├── public
│   ├── favicon.ico
└── src
    ├── api   -- Obtain data
    ├── app   -- Configure TRTC application information
    ├── components -- WebRTC API Examples common components
    ├── config -- Configure data
    ├── i18n   -- Internationalization
    ├── pages  -- WebRTC API Examples
    ├── styles
    └── utils  -- Common functions
```

## Prerequisites
You have [signed up for a Tencent Cloud account](https://intl.cloud.tencent.com/document/product/378/17985) and completed [identity verification](https://intl.cloud.tencent.com/document/product/378/3629).

## Directions
### Step 1. Create an application
1. Log in to the TRTC console and select **Development Assistance** > **[Demo Quick Run](https://console.cloud.tencent.com/trtc/quickstart)**.
2. Enter an application name such as `TestTRTC` and click **Create**.

### Step 2. Configure the project file
1. Find and open `src/app/config.js`.
2. Configure the following parameters:
  <ul><li>SDKAPPID: `0` by default. Set it to the actual `SDKAppID`.</li>
  <li>SECRETKEY: Left empty by default. Set it to the actual key.</li></ul> 
	<img src="https://main.qcloudimg.com/raw/87dc814a675692e76145d76aab91b414.png">
3. Return to the TRTC console and click **Next**.  
4. Click **Return to Overview Page**.

> Note:  
> In this document, the method to obtain `UserSig` is to configure the secret key in the client code. In this method, the secret key is vulnerable to decompilation and reverse engineering. If your secret key is leaked, attackers can steal your Tencent Cloud traffic. Therefore, **this method is only suitable for locally running a demo project and debugging**.  
>   
> The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to your server for a dynamic `UserSig`. For more information, see [How do I calculate `UserSig` during production?](https://intl.cloud.tencent.com/document/product/647/35166).

### Step 3. Run WebRTC API Examples

> Note:  
> 1. Node.js 14.16.0 or later is recommended.  
> 2. Use Yarn to install the dependencies and run the project.  

#### 1. Install dependencies
```bash
yarn 
```

#### 2. Run in the development environment
```bash
yarn run dev
```
Open `http://localhost:3000/basic-rtc` with Chrome to view the development page.

#### 3. Package for production
```bash
yarn run build
```
You can view the packaging result in the `/.next` folder and deploy it to your server.

#### 4. Run in the production environment
```bash
yarn run build
yarn run start
```
Open `http://localhost:3000/basic-rtc` with Chrome to view the webpage deployed to your local server.

#### 5. Package for production and output static files
```bash
yarn run export
```
You can view the static files in the `/out` directory and upload the files to CDNs.

When you run WebRTC API Examples, you will see the page below:
![](https://qcloudimg.tencent-cloud.cn/raw/b0c3835d53caeabf4155a228e7e4ffa6.png)

WebRTC uses the camera and mic of your device to capture audio and video, so when prompted by Chrome, click **Allow**.
![](https://qcloudimg.tencent-cloud.cn/raw/1598990106c987d1b123fad5c400e23e.png)

## Supported Platforms

Proposed by Google, the WebRTC technology is well supported by Chrome (desktop) and Safari (desktop and mobile) but poorly or not supported by other platforms such as browsers on Android.
- If your use cases are mainly in the education sector, consider using the [TRTC Electron SDK](https://intl.cloud.tencent.com/document/product/647/35097), which supports the dual-stream mode with more flexible screen sharing schemes and better recovery capabilities for poor network connections.

<table>
<tr>
<th>OS</th>
<th width="22%">Browser</th><th>Minimum Browser<br>Version Requirement</th><th width="16%">Receive (Playback)</th><th width="16%">Send (Publish)</th><th>Screen Sharing</th><th>SDK Version Requirement</th>
</tr><tr>
<td>macOS</td>
<td>Safari (desktop)</td>
<td>11+</td>
<td>Supported</td>
<td>Supported</td>
<td>Supported (on Safari 13+)</td>
<td>-</td>
</tr>
<tr>
<td>macOS</td>
<td>Chrome (desktop)</td>
<td>56+</td>
<td>Supported</td>
<td>Supported</td>
<td>Supported (on Chrome 72+)</td>
<td>-</td>
</tr>
<tr>
<td>macOS</td>
<td>Firefox (desktop)</td>
<td>56+</td>
<td>Supported</td>
<td>Supported</td>
<td>Supported (on Firefox 66+）</td>
<td>4.7.0+</td>
</tr>
<tr>
<td>macOS</td>
<td>Edge (desktop)</td>
<td>80+</td>
<td>Supported</td>
<td>Supported</td>
<td>Supported</td>
<td>4.7.0+</td>
</tr>
<tr>
<td>Windows</td>
<td>Chrome (desktop)</td>
<td>56+</td>
<td>Supported</td>
<td>Supported</td>
<td>Supported (on Chrome 72+)</td>
<td>-</td>
</tr>
<tr>
<td>Windows</td>
<td>QQ Browser (desktop, WebKit core)</td>
<td>10.4+</td>
<td>Supported</td>
<td>Supported</td>
<td>Not supported</td>
<td>-</td>
</tr>
<tr>
<td>Windows</td>
<td>Firefox (desktop)</td>
<td>56+</td>
<td>Supported</td>
<td>Supported</td>
<td>Supported (on Firefox 66+）</td>
<td>4.7.0+</td>
</tr>
<tr>
<td>Windows</td>
<td>Edge (desktop)</td>
<td>80+</td>
<td>Supported</td>
<td>Supported</td>
<td>Supported</td>
<td>4.7.0+</td>
</tr>
<tr>
<td>iOS 11.1.2+</td>
<td>Safari (mobile)</td>
<td>11+</td>
<td>Supported</td>
<td>Supported</td>
<td>Not supported</td>
<td>-</td>
</tr>
<tr>
<td>iOS 12.1.4+</td>
<td>WeChat built-in browser</td>
<td>-</td>
<td>Supported</td>
<td>Not supported</td>
<td>Not supported</td>
<td>-</td>
</tr>
<tr>
<td>Android</td>
<td>QQ Browser (mobile)</td>
<td>-</td>
<td>Not supported</td>
<td>Not supported</td>
<td>Not supported</td>
<td>-</td>
</tr>
<tr>
<td>Android</td>
<td>UC Browser (mobile)</td>
<td>-</td>
<td>Not supported</td>
<td>Not supported</td>
<td>Not supported</td>
<td>-</td>
</tr>
<tr>
<td>Android</td>
<td>WeChat built-in browser (TBS core)</td>
<td>-</td>
<td>Supported</td>
<td>Supported</td>
<td>Not supported</td>
<td>-</td>
</tr>
<tr>
<td>Android</td>
<td>WeChat built-in browser (XWEB core)</td>
<td>-</td>
<td>Supported</td>
<td>Supported</td>
<td>Not supported</td>
<td>-</td>
</tr>
</table>

>! 
>- You can run a [WebRTC Support Level Test](https://www.qcloudtrtc.com/webrtc-samples/abilitytest/index.html) in a browser (for example, WeChat’s built-in browser), to test whether the environment fully supports WebRTC.
>- Due to H.264 patent issues, the TRTC web SDK cannot be run on Chrome or Chrome WebView-based browsers.

<span id="requirements"></span>
## Environment Requirements
- Use the latest version of Chrome.
- The TRTC web SDK uses the following ports and domain name for data transfer, which should be added to the allowlist of your firewall. After configuration, use our [official demo](https://trtc-1252463788.file.myqcloud.com/web/demo/official-demo/index.html) to check whether the configuration has taken effect.
 - TCP port: 8687
 - UDP ports: 8000, 8080, 8800, 843, 443, 16285
 - Domain name: qcloud.rtc.qq.com

## FAQs

### 1. There is only information of the public and private keys when I try to view the secret key. How do I get the secret key?
TRTC SDK 6.6 (August 2019) and later versions use the new signature algorithm HMAC-SHA256. If your application was created before August 2019, you need to upgrade the signature algorithm to get a new key. Without upgrading, you can continue to use the [old algorithm ECDSA-SHA256](https://intl.cloud.tencent.com/document/product/647/35166).

Upgrade:
1. Log in to the [TRTC console](https://console.cloud.tencent.com/trtc).
2. Click **Application Management** on the left sidebar, find your application, and click **Application Info**.
3. Select the **Quick Start** tab and click **Upgrade** in **Step 2: obtain the secret key to issue UserSig**.

### 2. What should I do if the client error "RtcError: no valid ice candidate found" occurs?
This error indicates that the TRTC web SDK failed with regard to hole punching via Session Traversal Utilities for NAT (STUN). Please check your firewall configuration against the [Environment Requirements](#requirements).

### 3. What should I do if the client error "RtcError: ICE/DTLS Transport connection failed" or "RtcError: DTLS Transport connection timeout" occurs?
It indicates that the TRTC web SDK failed to establish a media transmission channel. Please check your firewall configuration against the [Environment Requirements](#requirements).

### 4. What should I do if a 10006 error occurs?
If the "Join room failed result: 10006 error: service is suspended, if charge is overdue,renew it" occurs, check whether your TRTC application service is available.
Log in to the [TRTC console](https://console.cloud.tencent.com/rav), select the application you created, and click **Application Info** to view its service status.
