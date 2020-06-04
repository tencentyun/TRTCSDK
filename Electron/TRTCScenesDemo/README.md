## 目录结构说明
本目录包含的是多个场景案例的 Demo 源代码：
```
├─ TRTCScenesDemo // TRTC场景化Demo，包括视频通话、语音通话、视频互动直播、语音聊天室
|  ├─ TRTCEducation                // 实时互动课堂示例代码
|  |  |--app                       // 源代码文件
|  |  |  |--index.tsx              // 页面入口文件
|  |  |  |--Routes.tsx             // 路由配置文件
|  |  |  |--containers             // 进入教室、教室UI代码
|  |  |  |--components             // 教师端UI、学生端UI、聊天室、用户列表组件代码
|  |  |  |--debug                  // sdkAppId和密钥配置文件
|  |  |--package.json              // 工程配置
|  |  |--configs                   // webpack配置文件
```

## 实时互动课堂
### 功能简介

集成了语音、视频、屏幕分享等上课方式，还封装了老师开始问答、学生举手、老师邀请学生上台回答、结束回答等相关能力。

#### 教师端
![](https://main.qcloudimg.com/raw/35d33cb6003bd3575ee6bbfb0cbe6450.png)
#### 学生端
![](https://main.qcloudimg.com/raw/30e62d5c96c1ba31fc24c113ecfdb395.png)
如需快速实现实时互动课堂功能，可以直接基于我们提供的 Demo 进行修改适配，也可以使用我们提供的 `trtc-electron-education` 组件并实现自定义 UI 界面。

### 场景化 UI

您可以使用封装好的 [trtc-electron-education](https://www.npmjs.com/package/trtc-electron-education) 组件实现自定义UI界面。

![](https://main.qcloudimg.com/raw/e00d38bf3869a41be809d8bf80cee248.png)

### 相关技术栈

* typescript
* react & react hooks
* electron & electron-react-boilerplate
* element-ui