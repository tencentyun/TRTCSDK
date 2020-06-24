//
//  TRTCVoiceRoomDependencyContainer.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/3.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

/// ViewModel可视为MVC架构中的Controller层
/// 负责语音聊天室控制器和ViewModel依赖注入
class TRTCVoiceRoomDependencyContainer: NSObject {
    
    /// 主要用于创建页面和语聊房页面的Room传值
    private var voiceRoom: TRTCVoiceRoomImp?
    
    func getVoiceRoom() -> TRTCVoiceRoomImp {
        if let room = voiceRoom {
            return room
        }
        voiceRoom = TRTCVoiceRoomImp.shared()
        return voiceRoom!
    }
    
    func clearVoiceRoom() {
        voiceRoom?.destroyRoom(callback: { (code, message) in
            
        })
        voiceRoom = nil
    }
    
    
    /// 语聊房入口控制器
    /// - Returns: 返回语聊房的主入口
    @objc func makeEntranceViewController() -> UIViewController {
       return makeVoiceRoomListViewController()
    }
    
    
    /// 创建语聊房页面
    /// - Returns: 创建语聊房VC
    func meakCreateVoiceRoomViewController() -> UIViewController {
         return TRTCCreateVoiceRoomViewController.init(dependencyContainer: self)
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
    func makeVoiceRoomViewController(roomInfo: VoiceRoomInfo, role: VoiceRoomViewType) -> UIViewController {
        return TRTCVoiceRoomViewController.init(viewModelFactory: self, roomInfo: roomInfo, role: role)
    }
}

extension TRTCVoiceRoomDependencyContainer: TRTCVoiceRoomViewModelFactory {
    
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
