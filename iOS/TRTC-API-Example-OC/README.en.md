# TRTC API-Example 
[中文](README.md) | English

## Background
This open-source demo shows how to use some APIs of the [TRTC SDK](https://cloud.tencent.com/document/product/647/32689) to help you better understand the APIs and use them to implement some basic TRTC features. 

## Contents
This demo covers the following features (click to view the details of a feature):

- Basic Features
  - [Audio Call](./Basic/AudioCall)
  - [Video Call](./Basic/VideoCall)
  - [Interactive Live Video Streaming](./Basic/Live)
  - [Interactive Live Audio Streaming](./Basic/VoiceChatRoom)
  - [Screen Sharing Live Streaming](./Basic/ScreenShare)
- Advanced Features
  - [String-type Room IDs](./Advanced/StringRoomId)
  - [Video Quality Setting](./Advanced/SetVideoQuality)
  - [Audio Quality Setting](./Advanced/SetAudioQuality)
  - [Rendering Control](./Advanced/SetRenderParams)
  - [Network Speed Testing](./Advanced/SpeedTest)
  - [CDN Publishing](./Advanced/PushCDN)
  - [Custom Video Capturing & Rendering](./Advanced/CustomCamera)
  - [Audio Effect Setting](./Advanced/SetAudioEffect)
  - [Background Music Setting](./Advanced/SetBackgroundMusic)
  - [Local Video Sharing](./Advanced/LocalVideoShare)
  - [Local Video Recording](./Advanced/LocalRecord)
  - [Multiple Room Entry](./Advanced/JoinMultipleRoom)
  - [SEI Message Receiving/Sending](./Advanced/SEIMessage)
  - [Room Switching](./Advanced/SwitchRoom)
  - [Cross-Room Competition](./Advanced/RoomPk)
  - [Third-Party Beauty Filters](./Advanced/ThirdBeauty)

## Environment Requirements
- Xcode 11.0 and above
- Please make sure that your project has set a valid developer signature


## Demo Run Example

#### Prerequisites
You have [signed up for a Tencent Cloud account](https://intl.cloud.tencent.com/document/product/378/17985) and completed [identity verification](https://intl.cloud.tencent.com/document/product/378/3629).


### Obtaining `SDKAPPID` and `SECRETKEY`
1. Log in to the TRTC console and select **Development Assistance** > **[Demo Quick Run](https://console.cloud.tencent.com/trtc/quickstart)**.
2. Enter an application name such as `TestTRTC`, and click **Create**.

![ #900px](https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png)
3. Click **Next** to view your `SDKAppID` and key.


### Configuring demo project files
1. Open the [GenerateTestUserSig.h](debug/GenerateTestUserSig.h) file in the Debug directory.
2. Configure two parameters in the `GenerateTestUserSig.h` file:
  - `SDKAPPID`: `PLACEHOLDER` by default. Set it to the actual `SDKAppID`.
  - `SECRETKEY`: left empty by default. Set it to the actual key.
 ![ #900px](https://main.qcloudimg.com/raw/8fb309ce8c378dd3ad2c0099c57795a5.png)

3. Return to the TRTC console and click **Next**.
4. Click **Return to Overview Page**.

>!The method for generating `UserSig` described in this document involves configuring `SECRETKEY` in client code. In this method, `SECRETKEY` may be easily decompiled and reversed, and if your key is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is suitable only for the local execution and debugging of the demo**.
>The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can make a request to the business server for dynamic `UserSig`. For more information, please see [How to Calculate UserSig](https://cloud.tencent.com/document/product/647/17275#Server).

## Configuring CDN parameters (optional)
To use CDN services, which are needed for co-anchoring, CDN playback, etc., you need to configure three **live streaming** parameters.
- `BIZID`
- `APPID`
- `CDN_DOMAIN_NAME`

![ #900px](https://liteav.sdk.qcloud.com/doc/res/trtc/picture/bizid_appid_scree.png)

For detailed instructions, see [CDN Relayed Live Streaming](https://cloud.tencent.com/document/product/647/16826#.E9.80.82.E7.94.A8.E5.9C.BA.E6.99.AF).


### Compiling and running the project
Use XCode (11.0 and above) to open TRTC-API-Example-OC.xcodeproj in the source directory

# Contact Us
- [FAQs](https://cloud.tencent.com/document/product/647/34399)
- [Documentation](https://cloud.tencent.com/document/product/647/16788)(Cloud+ Community)
- [API document](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__ios.html)
- [Template for issue reporting](https://github.com/tencentyun/TRTCSDK/issues/53)

> If the above does not solve your problem, [report](https://wj.qq.com/s2/8393513/f442/) it to our **engineer**.
