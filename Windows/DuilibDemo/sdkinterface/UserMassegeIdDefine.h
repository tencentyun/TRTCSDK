#pragma once

//duilib使用的自定义消息
//WM_USER + 121         //菜单控件

//SDK信令消息
#define WM_USER_CMD                     WM_USER + 0         //信令交互
#define WM_USER_CMD_EnterRoom          WM_USER_CMD + 1     //进房回调通知
#define WM_USER_CMD_ExitRoom           WM_USER_CMD + 2     //退房通知
#define WM_USER_CMD_MemberEnter        WM_USER_CMD + 3     //用户进入房间消息
#define WM_USER_CMD_MemberExit         WM_USER_CMD + 4     //用户退出房间消息
#define WM_USER_CMD_Error               WM_USER_CMD + 5     //出现错误
#define WM_USER_CMD_Dashboard           WM_USER_CMD + 6     //仪表盘信息
#define WM_USER_CMD_DeviceChange       WM_USER_CMD + 7      //设备变更
#define WM_USER_CMD_TestComplete        WM_USER_CMD + 8     //网速测验结果
#define WM_USER_CMD_MemberVolumeCallback    WM_USER_CMD + 9     //设备变更
#define WM_USER_CMD_MicVolumeCallback       WM_USER_CMD + 10    //网速测验结果
#define WM_USER_CMD_SpeakerVolumeCallback   WM_USER_CMD + 11    //网速测验结果
#define WM_USER_CMD_SDKEventMsg                WM_USER_CMD + 12     //SDK状态信息
#define WM_USER_CMD_ConnectionLost             WM_USER_CMD + 13     //网络异常
#define WM_USER_CMD_TryToReconnect             WM_USER_CMD + 14     //尝试重进房
#define WM_USER_CMD_ConnectionRecovery             WM_USER_CMD + 15     //网络恢复，重进房成功
#define WM_USER_CMD_AuidoAvailable             WM_USER_CMD + 49     //摄像头数据事件
#define WM_USER_CMD_SubVideoAvailable             WM_USER_CMD + 50     //辅流事件
#define WM_USER_CMD_VideoAvailable             WM_USER_CMD + 51     //摄像头数据事件
#define WM_USER_CMD_ScreenStart             WM_USER_CMD + 52     //屏幕分享开始
#define WM_USER_CMD_ScreenEnd             WM_USER_CMD + 53     //屏幕分享关闭
#define WM_USER_CMD_VodStart             WM_USER_CMD + 54     //播片分享开始
#define WM_USER_CMD_VodEnd             WM_USER_CMD + 55     //播片分享关闭
#define WM_USER_CMD_UserVoiceVolume    WM_USER_CMD + 56     //用户声音音量值
//#define WM_USER_CMD_UserListStaticChange    WM_USER_CMD + 57     //用户声音音量值
#define WM_USER_CMD_PKConnectStatus    WM_USER_CMD + 58     //用户声音音量值
#define WM_USER_CMD_PKDisConnectStatus    WM_USER_CMD + 59     //用户声音音量值
#define WM_USER_CMD_NetworkQuality    WM_USER_CMD + 60     //用户声音音量值
#define WM_USER_CMD_FirstVideoFrame    WM_USER_CMD + 61     //第一帧视频数据。
#define WM_USER_CMD_RemoteScreenStop     WM_USER_CMD + 62     //远端屏幕分享结束
#define WM_USER_CMD_SendFirstLocalVideoFrame    WM_USER_CMD + 63     //本地第一帧数据
#define WM_USER_CMD_SendFirstLocalAudioFrame    WM_USER_CMD + 64     //本地第一帧数据
#define WM_USER_CMD_OnRecordError   WM_USER_CMD + 65    //录制结果回调
#define WM_USER_CMD_OnRecordComplete   WM_USER_CMD + 66    //录制结果回调
#define WM_USER_CMD_OnRecordProgress   WM_USER_CMD + 67    //录制进度回调
#define WM_USER_CMD_OnStartPublishinge   WM_USER_CMD + 68    //更新StreamId回调
#define WM_USER_CMD_OnStopPublishing   WM_USER_CMD + 69    //更新StreamId回调
#define WM_USER_CMD_OnMusicPlayBegin   WM_USER_CMD + 70   //播放音乐开始状态回调
#define WM_USER_CMD_OnMusicPlayProgress  WM_USER_CMD + 71 //播放音乐进度回调
#define WM_USER_CMD_OnMusicPlayComplete  WM_USER_CMD + 72  //播放音乐完成回调
#define WM_USER_CMD_OnCameraDidReady     WM_USER_CMD + 73  //摄像头设备就绪
#define WM_USER_CMD_OnMicDidReady        WM_USER_CMD + 74  //麦克风设备就绪
#define WM_USER_CMD_OnTestMicVolume      WM_USER_CMD + 75  //测试麦克风音量
#define WM_USER_CMD_OnTestSpeakerVolume   WM_USER_CMD + 76  //测试扬声器音量
#define WM_USER_CMD_OnFirstAudioFrame     WM_USER_CMD + 78 //开始播放远程用户的首帧音频（本地声音暂不通知）
#define WM_USER_CMD_Warning               WM_USER_CMD + 79 //出现警告
#define WM_USER_CMD_SwitchRoom            WM_USER_CMD + 80 //切换房间
//音视频数据消息

//VOD 事件
#define WM_USER_CMD_OnVodPlayerStarted WM_USER_CMD + 100  //点播开始回调
#define WM_USER_CMD_OnVodPlayerProgress WM_USER_CMD + 101  //点播进度回调
#define WM_USER_CMD_OnVodPlayerPaused WM_USER_CMD + 102   //点播暂停回调
#define WM_USER_CMD_OnVodPlayerResumed WM_USER_CMD + 103  //点播恢复回调
#define WM_USER_CMD_OnVodPlayerStoped WM_USER_CMD + 104   //点播停止回调
#define WM_USER_CMD_OnVodPlayerError WM_USER_CMD + 105      //点播错误回调
#define WM_USER_CMD_OnVodPlayerRenderMode WM_USER_CMD + 106   
#define WM_USER_CMD_OnVodPlayerPublishVideo WM_USER_CMD + 107 
#define WM_USER_CMD_OnVodPlayerPublishAudio WM_USER_CMD + 108

// UI Define
#define WM_USER_UI_MSG_ID WM_USER + 400
#define ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP     WM_USER_UI_MSG_ID + 0       //有些窗口关闭不要退出消息循环
#define ID_DELAY_SHOW_MSGBOX                WM_USER_UI_MSG_ID + 1                  //滞后弹提示窗口
#define WM_USER_SET_SHOW_VOICEVOLUME        WM_USER_UI_MSG_ID + 2    //是否显示音量值
#define WM_USER_VIEW_BTN_CLICK              WM_USER_UI_MSG_ID + 3    //View的按钮被点击了。
#define WM_USER_CMD_RoleChange              WM_USER_UI_MSG_ID + 6     //用户角色变化了
#define WM_USER_CMD_LiveTypeChange          WM_USER_UI_MSG_ID + 7     //观众进房直播数据源变化了