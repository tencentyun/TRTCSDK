//
//  TRTCCreateChatSalonViewModel.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

enum ChatSalonRole {
    case anchor // 主播
    case audience // 观众
}

enum ChatSalonToneQuality: Int {
    case speech = 1
    case defaultQuality
    case music
}

protocol TRTCCreateChatSalonViewResponder: class {
    func push(viewController: UIViewController)
}

class TRTCCreateChatSalonViewModel {
    private let dependencyContainer: TRTCChatSalonEnteryControl
    
    public weak var viewResponder: TRTCCreateChatSalonViewResponder?
    
    var chatSalon: TRTCChatSalon {
        return dependencyContainer.getChatSalon()
    }
    
    var roomName: String = ""
    var userName: String = ""
    var needRequest: Bool = true
    var toneQuality: ChatSalonToneQuality = .music
    
    /// 初始化方法
    /// - Parameter container: 依赖管理容器，负责ChatSalon模块的依赖管理
    init(container: TRTCChatSalonEnteryControl) {
        self.dependencyContainer = container
        let name = ProfileManager.shared.curUserModel?.name ?? dependencyContainer.userID
        roomName = "\(name)"+String.salonRoomNameSuffix
        userName = name
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    func createRoom() {
        let userID = ProfileManager.shared.curUserID() ?? dependencyContainer.userID
        let coverAvatar = ProfileManager.shared.curUserModel?.avatar ?? ""
        let roomId = getRoomId()
        let roomInfo = ChatSalonInfo.init(roomID: roomId, ownerId: userID, memberCount: 7)
        roomInfo.ownerName = userName
        roomInfo.coverUrl = coverAvatar
        roomInfo.roomName = roomName
        roomInfo.needRequest = needRequest
        let vc = self.dependencyContainer.makeChatSalonViewController(roomInfo:roomInfo, role: .anchor, toneQuality: self.toneQuality)
        viewResponder?.push(viewController: vc)
    }
    
    func getRoomId() -> Int {
        let userID = ProfileManager.shared.curUserID() ?? dependencyContainer.userID
        let result = "\(userID)_voice_room".hash & 0x7FFFFFFF
        TRTCLog.out("hashValue:room id:\(result), userID: \(userID)")
        return result
    }
}

fileprivate extension String {
    static let salonRoomNameSuffix = TRTCLocalize("Demo.TRTC.Salon.xxsroom")
}
