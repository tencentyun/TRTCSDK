# TRTC SDK （iOS）

## 下载地址
- 精简版：[ZIP](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.4/TXLiteAVSDK_TRTC_iOS_6.4.7111.zip)
- 版本号：6.4.7111

## 手动集成

1. 下载 SDK 后进行解压。

2. 打开您的 Xcode 工程项目，选择要运行的 target , 选中 **Build Phases** 项。
![](https://main.qcloudimg.com/raw/2719ff925e92de21a2ba370a8ba5a32c.jpg)

3. 单击 **Link Binary with Libraries** 项展开，单击底下的 + 号图标去添加依赖库。
![](https://main.qcloudimg.com/raw/2e3b382fccadb0fe9e1038fffa1ef12f.jpg)

4. 依次添加所下载的 TRTC SDK Framework 及其所需依赖库 **libc++** 。
![](https://main.qcloudimg.com/raw/0327c1ab6562e0f6e7f17b2e0fbe96dd.jpg)



## CocoaPods 
#### 1. 安装 CocoaPods
在终端窗口中输入如下命令（需要提前在 Mac 中安装 Ruby 环境）：
```
sudo gem install cocoapods
```

#### 2. 创建 Podfile 文件
进入项目所在路径，输入以下命令行之后项目路径下会出现一个 Podfile 文件。
```
pod init
```

#### 3. 编辑 Podfile 文件
编辑 Podfile 文件，有如下有两种设置方式：
-  方式一：使用腾讯云 LiteAV SDK 的podspec 文件路径。
```
  platform :ios, '8.0'
  
  target 'App' do
  pod 'TXLiteAVSDK_TRTC', :podspec => 'http://pod-1252463788.cosgz.myqcloud.com/liteavsdkspec/TXLiteAVSDK_TRTC.podspec'
  end
```

-  方式二：使用 CocoaPod 官方源，支持选择版本号。
```
   platform :ios, '8.0'
   source 'https://github.com/CocoaPods/Specs.git'
   
   target 'App' do
   pod 'TXLiteAVSDK_TRTC'
   end
```
  
#### 4. 更新并安装 SDK
在终端窗口中输入如下命令以更新本地库文件，并安装 TRTC SDK：
```
pod install
```
或使用以下命令更新本地库版本：
```
pod update
```

pod 命令执行完后，会生成集成了 SDK 的 .xcworkspace 后缀的工程文件，双击打开即可。


