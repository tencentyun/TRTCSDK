//
//  TRTCVoiceRoomListViewModel.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

protocol TRTCVoiceRoomListViewResponder: class {
    func showToast(message: String)
    func refreshList()
    func stopListRefreshing()
    func showLoading(message: String)
    func hideLoading()
    func pushRoomView(viewController: UIViewController)
}

class TRTCVoiceRoomListViewModel {
    private let dependencyContainer: TRTCVoiceRoomEnteryControl
    weak var viewResponder: TRTCVoiceRoomListViewResponder?
    private var voiceRoomManager: TRTCVoiceRoomManager {
        return TRTCVoiceRoomManager.shared
    }
    
    private var voiceRoom: TRTCVoiceRoom {
        return dependencyContainer.getVoiceRoom()
    }
    // 视图相关属性
    private(set) var roomList: [VoiceRoomInfo] = []
    
    /// 初始化方法
    /// - Parameter container: 依赖管理容器，负责VoiceRoom模块的依赖管理
    init(container: TRTCVoiceRoomEnteryControl) {
        self.dependencyContainer = container
    }
    
    func makeCreateViewController() -> UIViewController {
        return dependencyContainer.makeCreateVoiceRoomViewController()
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    @objc
    func getRoomList() {
        guard dependencyContainer.mSDKAppID != 0 else {
            viewResponder?.showToast(message: .appidErrorText)
            return
        }
        voiceRoomManager.getRoomList(sdkAppID: dependencyContainer.mSDKAppID, success: { [weak self] (roomIds: [String]) in
            guard let `self` = self else { return }
            let roomIdsInt = roomIds.compactMap {
                Int($0)
            }
            if roomIdsInt.count == 0 {
                DispatchQueue.main.async {
                    self.roomList = []
                    self.viewResponder?.refreshList()
                    self.viewResponder?.showToast(message: .nocontentText)
                    self.viewResponder?.stopListRefreshing()
                }
                return;
            }
            self.voiceRoom.getRoomInfoList(roomIdList: roomIdsInt.map{ NSNumber.init(value: $0) }) { [weak self] (code, message, roomInfos: [VoiceRoomInfo])  in
                guard let self = self else { return }
                self.viewResponder?.stopListRefreshing()
                if code == 0 {
                    if roomInfos.count == 0 {
                        self.viewResponder?.showToast(message: .nocontenttText)
                    }
                    DispatchQueue.main.async {
                        self.roomList = roomInfos
                        self.viewResponder?.refreshList()
                    }
                } else {
                    TRTCLog.out("get room list failed. code\(code), message:\(message)")
                    self.viewResponder?.showToast(message: .roomlistFailedText)
                }
                self.viewResponder?.stopListRefreshing()
            }
        }) { [weak self] (code, message) in
            guard let `self` = self else { return }
            TRTCLog.out("error: get room list fail. code: \(code), message:\(message)")
            self.viewResponder?.showToast(message: .listFailedText)
            self.viewResponder?.stopListRefreshing()
        }
    }
    
    func clickRoomItem(index: Int) {
        let roomInfo = self.roomList[index]
        if dependencyContainer.userId == roomInfo.ownerId {
            // 开始进入已经存在的房间
            startEnterExistRoom(info: roomInfo)
        } else {
            // 正常进房逻辑
            enterRoom(info: roomInfo)
        }
    }
    
    func startEnterExistRoom(info: VoiceRoomInfo) {
        // 以主播方式进房
        let vc = self.dependencyContainer.makeVoiceRoomViewController(roomInfo: info, role: .anchor)
        self.viewResponder?.pushRoomView(viewController: vc)
    }
    
    func enterRoom(info: VoiceRoomInfo) {
        let vc = self.dependencyContainer.makeVoiceRoomViewController(roomInfo: info, role: .audience)
        self.viewResponder?.pushRoomView(viewController: vc)
    }
}

private extension String {
    static let appidErrorText = TRTCLocalize("Demo.TRTC.Salon.invalidappid")
    static let nocontentText = TRTCLocalize("Demo.TRTC.LiveRoom.nocontentnow~")
    static let nocontenttText = TRTCLocalize("Demo.TRTC.VoiceRoom.nocontentnow")
    static let roomlistFailedText = TRTCLocalize("Demo.TRTC.LiveRoom.getroomlistfailed")
    static let listFailedText = TRTCLocalize("Demo.TRTC.Salon.getlistfailed")
}
