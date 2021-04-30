//
//  TRTCVoiceRoomEnteryControl.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/3.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

/// ViewModel可视为MVC架构中的Controller层
/// 负责语音聊天室控制器和ViewModel依赖注入，以及公用参数的传递
/// ViewModel、ViewController
/// 注意：该类负责生成所有UI层的ViewController、ViewModel。慎重持有ui层的成员变量，否则很容易发生循环引用。持有成员变量时要慎重！！！！
class TRTCVoiceRoomEnteryControl: NSObject {
    // 只读参数，初始化时在外部调用。
    // SDKAPPID和USERID也可以为全局参数，根据自己的需求灵活调整
    // 注入改参数的目的为，解耦VoiceRoomUI层与Login模块的耦合
    private(set) var mSDKAppID: Int32 = 0
    private(set) var userId: String = ""
    
    /// 初始化方法
    /// - Parameters:
    ///   - sdkAppId: 注入当前SDKAPPID
    ///   - userId: 注入userID
    @objc convenience init(sdkAppId:Int32, userId: String) {
        self.init()
        self.mSDKAppID = sdkAppId
        self.userId = userId
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    /*
     TRTCVoice为可销毁单例。
     在Demo中，可以通过shardInstance（OC）shared（swift）获取或生成单例对象
     销毁单例对象后，需要再次调用sharedInstance接口重新生成实例。
     该方法在VoiceRoomListRoomViewModel、CreateVoiceRoomViewModel、VoiceRoomViewModel中调用。
     由于是可销毁单例，将对象生成防止在这里的目的为统一管理单例生成路径，方便维护
     */
    private var voiceRoom: TRTCVoiceRoom?
    /// 获取VoiceRoom
    /// - Returns: 返回VoiceRoom单例
    func getVoiceRoom() -> TRTCVoiceRoom {
        if let room = voiceRoom {
            return room
        }
        voiceRoom = TRTCVoiceRoom.shared()
        return voiceRoom!
    }
    /*
     在无需使用VoicRoom的场景，可以将单例对象销毁。
     例如：退出登录时。
     在本Demo中没有调用到改销毁方法。
    */
    /// 销毁voiceRoom单例
    func clearVoiceRoom() {
        TRTCVoiceRoom.destroyShared()
        voiceRoom = nil
    }
    
    
    /// 语聊房入口控制器
    /// - Returns: 返回语聊房的主入口
    @objc func makeEntranceViewController() -> UIViewController {
       return makeVoiceRoomListViewController()
    }
    
    
    /// 创建语聊房页面
    /// - Returns: 创建语聊房VC
    func makeCreateVoiceRoomViewController() -> UIViewController {
         let vc =  TRTCCreateVoiceRoomViewController.init(dependencyContainer: self)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    
    /// 房间列表页面
    /// - Returns: 语聊房列表VC
    func makeVoiceRoomListViewController() -> UIViewController {
        return TRTCVoiceRoomListViewController.init(dependencyContainer: self)
    }
    
    /// 语聊房
    /// - Parameters:
    ///   - roomInfo: 要进入或者创建的房间参数
    ///   - role: 角色：观众 主播
    /// - Returns: 返回语聊房控制器
    func makeVoiceRoomViewController(roomInfo: VoiceRoomInfo, role: VoiceRoomViewType, toneQuality:VoiceRoomToneQuality = .music) -> UIViewController {
        return TRTCVoiceRoomViewController.init(viewModelFactory: self, roomInfo: roomInfo, role: role, toneQuality: toneQuality)
    }
}

extension TRTCVoiceRoomEnteryControl: TRTCVoiceRoomViewModelFactory {
    
    /// 创建语聊房视图逻辑层（MVC中的C，MVVM中的ViewModel）
    /// - Returns: 创建语聊房页面的ViewModel
    func makeCreateVoiceRoomViewModel() -> TRTCCreateVoiceRoomViewModel {
        return TRTCCreateVoiceRoomViewModel.init(container: self)
    }
    
    /// 语聊房视图逻辑层（MVC中的C，MVVM中的ViewModel）
    /// - Parameters:
    ///   - roomInfo: 语聊房信息
    ///   - roomType: 角色
    /// - Returns: 语聊房页面的ViewModel
    func makeVoiceRoomViewModel(roomInfo: VoiceRoomInfo, roomType: VoiceRoomViewType) -> TRTCVoiceRoomViewModel {
        return TRTCVoiceRoomViewModel.init(container: self, roomInfo: roomInfo, roomType: roomType)
    }
    
    /// 语聊房列表视图逻辑层（MVC中的C，MVVM中的ViewModel）
    /// - Returns: 语聊房列表的Viewmodel
    func makeVoiceRoomListViewModel() -> TRTCVoiceRoomListViewModel {
        return TRTCVoiceRoomListViewModel.init(container: self)
    }
}
