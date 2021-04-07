//
//  TRTCChatSalonListViewModel.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

protocol TRTCChatSalonListViewResponder: class {
    func showToast(message: String)
    func refreshList()
    func stopListRefreshing()
    func showLoading(message: String)
    func hideLoading()
    func pushRoomView(viewController: UIViewController)
}

class TRTCChatSalonListViewModel {
    private let dependencyContainer: TRTCChatSalonEnteryControl
    weak var viewResponder: TRTCChatSalonListViewResponder?
    private var chatSalonManager: TRTCChatSalonManager {
        return TRTCChatSalonManager.shared
    }
    
    private var chatSalon: TRTCChatSalon {
        return dependencyContainer.getChatSalon()
    }
    // 视图相关属性
    private(set) var roomList: [ChatSalonInfo] = []
    
    /// 初始化方法
    /// - Parameter container: 依赖管理容器，负责ChatSalon模块的依赖管理
    init(container: TRTCChatSalonEnteryControl) {
        self.dependencyContainer = container
    }
    
    func makeCreateViewController() -> UIViewController {
        return dependencyContainer.makeCreateChatSalonViewController()
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    @objc
    func getRoomList() {
        guard dependencyContainer.mSDKAppID != 0 else {
            viewResponder?.showToast(message: String.toastAppIdError)
            return
        }
        chatSalonManager.getRoomList(sdkAppID: dependencyContainer.mSDKAppID, success: { [weak self] (roomIds: [String]) in
            guard let `self` = self else { return }
            let roomIdsInt = roomIds.compactMap {
                Int($0)
            }
            if roomIdsInt.count == 0 {
                DispatchQueue.main.async {
                    self.roomList = []
                    self.viewResponder?.refreshList()
                    self.viewResponder?.showToast(message: String.toastEmptyContent)
                    self.viewResponder?.stopListRefreshing()
                }
                return;
            }
            self.chatSalon.getRoomInfoList(roomIdList: roomIdsInt.map{ NSNumber.init(value: $0) }) { [weak self] (code, message, roomInfos: [ChatSalonInfo])  in
                guard let self = self else { return }
                self.viewResponder?.stopListRefreshing()
                if code == 0 {
                    if roomInfos.count == 0 {
                        self.viewResponder?.showToast(message: String.toastEmptyContent)
                    }
                    DispatchQueue.main.async {
                        self.roomList = roomInfos
                        self.viewResponder?.refreshList()
                    }
                } else {
                    TRTCLog.out("get room list failed. code\(code), message:\(message)")
                    self.viewResponder?.showToast(message: String.toastGetInfoListFailed)
                }
                DispatchQueue.main.async {
                    self.viewResponder?.stopListRefreshing()
                }
            }
        }) { [weak self] (code, message) in
            guard let `self` = self else { return }
            TRTCLog.out("error: get room list fail. code: \(code), message:\(message)")
            self.viewResponder?.showToast(message: String.toastGetListFailed)
            self.viewResponder?.stopListRefreshing()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.viewResponder?.stopListRefreshing()
        }
    }
    
    func clickRoomItem(index: Int) {
        let roomInfo = self.roomList[index]
        if dependencyContainer.userID == roomInfo.ownerId {
            // 开始进入已经存在的房间
            startEnterExistRoom(info: roomInfo)
        } else {
            // 正常进房逻辑
            enterRoom(info: roomInfo)
        }
    }
    
    func startEnterExistRoom(info: ChatSalonInfo) {
        // 以主播方式进房
        let vc = self.dependencyContainer.makeChatSalonViewController(roomInfo: info, role: .anchor)
        self.viewResponder?.pushRoomView(viewController: vc)
    }
    
    func enterRoom(info: ChatSalonInfo) {
        let vc = self.dependencyContainer.makeChatSalonViewController(roomInfo: info, role: .audience)
        self.viewResponder?.pushRoomView(viewController: vc)
    }
}

fileprivate extension String {
    static let toastAppIdError = TRTCLocalize("Demo.TRTC.Salon.invalidappid")
    static let toastEmptyContent = TRTCLocalize("Demo.TRTC.LiveRoom.nocontentnow~")
    static let toastGetInfoListFailed = TRTCLocalize("Demo.TRTC.LiveRoom.getroomlistfailed")
    static let toastGetListFailed = TRTCLocalize("Demo.TRTC.Salon.getlistfailed")
}
