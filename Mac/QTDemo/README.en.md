[中文](README.md) | English

This document describes how to quickly run the TRTC demo for Qt.

## Background
This open-source demo shows how to use some APIs of the [TRTC SDK](https://cloud.tencent.com/document/product/647/32689) to help you better understand the APIs and use them to implement some basic TRTC features. 

## Contents
This demo covers the following features (click to view the details of a feature):

  - [Basic Features (Video Call, Audio Call, Interactive Live Video Streaming, Audio Chat Room)](./src/TestBaseScene)
  - [Cross-room Competition](./src/ConnectOtherRoom)
  - [Sub-room](./src/TestSubCloudSetting)
  - [Screen Sharing](./src/TestScreenShare)
  - [CDN Publishing](./src/TestCDNPublish)
  - [CDN Stream Mixing](./src/TestMixStreamPublish)
  - [CDN Player](./src/TestCDNPlayer)
  - [Audio Testing](./src/TestAudioDetect)
  - [Video Testing](./src/TestVideoDetect)
  - [Audio Settings](./src/TestAudioSetting)
  - [Video Settings](./src/TestVideoSetting)
  - [Audio Recording](./src/TestAudioRecord)
  - [Beauty Filters & Watermarks](./src/TestBeautyAndWatermark)
  - [Background Music & Audio Effects](./src/TestBgmSetting)
  - [Custom Audio/Video Capturing](./src/TestCustomCapture)
  - [Custom Rendering](./src/TestCustomRender)
  - [Custom Message Sending](./src/TestCustomMessage)
  - [Log Settings](./src/TestLogSetting)
  - [Network Testing](./src/TestNetworkCheck)


## Environment Requirements
- Qt 5.14.1 or above is recommended.
- For macOS, Qt Creator 4.11.1 or above is recommended.
- For Windows, Visual Studio 2015 or above is recommended.

## Prerequisites
You have [signed up for a Tencent Cloud account](https://intl.cloud.tencent.com/document/product/378/17985) and completed [identity verification](https://intl.cloud.tencent.com/document/product/378/3629).

## Directions
[](id:step1)

### Step 1. Create an application

1. In the TRTC console, select **Development Assistance** > **[Demo Quick Run](https://console.intl.cloud.tencent.com/trtc/quickstart)**.
2. Enter an application name such as `TestTRTC` and click **Create**.
![](https://main.qcloudimg.com/raw/8dc52b5fa66ec4a5a4317719f9d442b9.png)

[](id:step2)
### Step 2. Download the SDK and demo source code

1. Download the SDK and demo source code for your platform.
2. Click **Next**.
![](https://main.qcloudimg.com/raw/9f4c878c0a150d496786574cae2e89f9.png)

[](id:step3)
### Step 3. Configure demo project files
1. In the **Modify Configuration** step, select the development platform in line with the source package downloaded.

2. Find and open the `QTDemo/src/Util/defs.h` file.

3. Set parameters in `defs.h` as follows:
	<ul>
	<li/>SDKAPPID: a placeholder by default. Set it to the actual SDKAppID.
	<li/>SECRETKEY: a placeholder by default. Set it to the actual key.</ul>
   
   ![](https://main.qcloudimg.com/raw/87dc814a675692e76145d76aab91b414.png) 
   
4. Click **Next** to complete the creation.

5. After compilation, click **Return to Overview Page**.

>**Note: **This method is for testing only. Before commercial launch, please migrate the UserSig calculation code and key to your backend server to prevent key disclosure and traffic theft. For details, see [document](https://intl.cloud.tencent.com/document/product/647/35166).

[](id:step4)
### Step 4. Run the demo
> 
>**macOS:** Download and install [Qt Creator](https://www.qt.io/download-qt-installer?hsCtaTracking=99d9dd4f-5681-48d2-b096-470725510d34%7C074ddad0-fdef-4e53-8aa8-5e8a876d6ab4), open `QTDemo.pro` with Qt Creator, paste the `SECRETKEY` and `SDKAppID` in `QTDemo/base/Defs.h`, and compile and run the demo.
>
> Note: Make sure you have [downloaded](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Mac_latest.tar.bz2) and saved `TXLiteAVSDK_TRTC_Mac.framework` to the `Mac/SDK` folder. The downloaded package includes:
>```
>├─ QTDemo // QT demo project
>├─ SDK    // TRTC SDK for macOS
>```
>  You can then use **Qt Creator** to compile and debug the demo.

>---------
>  **Windows:** To run the demo, you need to install Visual Studio (2015 or above) and follow the steps below to set up a compilation environment for Qt in Visual Studio.
>> Find the right version of Qt add-in for your Visual Studio on the [official website](https://download.qt.io/official_releases/vsaddin/), and **download and install** the VSIX file.
>>
>>Open Visual Studio, select **Qt VS Tools** > **Qt Options** > **Qt Versions**, and click **add** to add the MSVC compiler.
>>
>> Copy all the DLL files in **SDK/CPlusPlus/Win32/lib** to the `debug` or `release` folder of your project, depending on whether you want to debug or release your project.
>
> Note: Make sure you have [downloaded](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_TRTC_Win_latest.zip) and saved `CPlusPlus` in the `SDK` folder to `Windows/SDK`. The downloaded package includes:
>```
>├─ QTDemo // QT demo project
>├─ SDK    // TRTC SDK for Windows
>|  ├─ CPlusPlus // `CPlusPlus` is located in the `SDK` folder
>```
>
>
> You can then use Visual Studio to compile and debug the demo.
> 
> The `QTDemo.pro` file in the demo project folder is the project configuration file, which includes resource file referencing, compilation configuration, etc.


## Directory Structure
```
├─ QTDemo // Qt demo API examples, which cover basic features including video call and audio call, as well as some advanced features
|  ├─ src                 // Source code for the Qt demo
|  |  ├─ TestBaseScene             // Sample code for TRTC basic features, including video call, audio call, interactive live video streaming, and audio chat room
|  |  ├─ TestScreenShare           // Sample code for screen sharing
|  |  ├─ TestCDNPublish            // Sample code for CDN publishing
|  |  ├─ TestMixStreamPublish      // Sample code for CDN stream mixing
|  |  ├─ TestAudioDetect           // Sample code for audio testing
|  |  ├─ TestVideoDetect           // Sample code for video testing
|  |  ├─ TestAudioSetting          // Sample code for audio settings
|  |  ├─ TestVideoSetting          // Sample code for video settings
|  |  ├─ TestAudioRecord           // Sample code for audio recording
|  |  ├─ TestBeautyAndWatermark    // Sample code for beauty filters and watermarks
|  |  ├─ TestBgmSetting            // Sample code for background music and audio effects
|  |  ├─ TestCDNPlayer             // Sample code for CDN playback
|  |  ├─ TestConnectOtherOther     // Sample code for cross-room competition
|  |  ├─ TestCustomCapture         // Sample code for custom audio/video capturing
|  |  ├─ TestCustomRender          // Sample code for custom rendering
|  |  ├─ TestCustomMessage         // Sample code for custom message sending
|  |  ├─ TestLogSetting            // Sample code for log settings
|  |  ├─ TestNetworkCheck          // Sample code for network testing
|  |  ├─ TestSubCloudSetting       // Sample code for sub-rooms
|  ├─ assets              // Local resource files used by the demo, including demonstration files for background music and custom rendering, which must be copied to the folder of the executable file
|  ├─ resources           // Images and other resources required to run the demo
```
## Documentation

- [TRTC SDK release notes](https://github.com/tencentyun/TRTCSDK/releases)
- [TRTC SDK API documentation](http://doc.qcloudtrtc.com/md_introduction_trtc_Windows_cpp_%E6%A6%82%E8%A7%88.html)
- [TRTC SDK demo app](https://intl.cloud.tencent.com/document/product/647/35076)
- [Scenario-specific practice: interactive live streaming](https://intl.cloud.tencent.com/document/product/647/36060)
- [Scenario-specific practice: video call](https://intl.cloud.tencent.com/document/product/647/36065)
- [Scenario-specific practice: audio call](https://intl.cloud.tencent.com/document/product/647/36067)
- [FAQs about UserSig](https://intl.cloud.tencent.com/document/product/647/35166)
- [FAQs about firewall restrictions](https://intl.cloud.tencent.com/document/product/647/35164)

