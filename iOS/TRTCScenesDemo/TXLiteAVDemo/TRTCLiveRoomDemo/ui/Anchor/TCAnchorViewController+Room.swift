//
//  TCAnchorViewController+Room.swift
//  TRTCScenesDemo
//
//  Created by 刘智民 on 2020/3/30.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Toast_Swift

extension TCAnchorViewController {
    typealias Callback = (_ code: Int, _ message: String?) -> Void
    
    @objc func generateRoomID() -> UInt32 {
        let userID = (ProfileManager.shared.curUserModel?.userId ?? "")
        return  UInt32(truncatingIfNeeded: (userID.hash)) & 0x7FFFFFFF
    }
    
    @objc func _startPublish(sdkAppID: Int32,roomName: String, roomID: UInt32, callback: Callback?) {
        func liveRoomCreate(roomName: String, roomID: UInt32, callback: Callback?) {
            let roomParam = TRTCCreateRoomParam(roomName: roomName, coverUrl: ProfileManager.shared.curUserModel?.avatar ?? "")
            liveRoom?.createRoom(roomID: roomID, roomParam: roomParam, callback: { (code, error) in
                let roomInfo = TRTCLiveRoomInfo(roomId: String(roomID), roomName: roomName,
                                                coverUrl: ProfileManager.shared.curUserModel?.avatar ?? "",
                                                ownerId: ProfileManager.shared.curUserID() ?? "",
                                                ownerName: ProfileManager.shared.curUserModel?.name ?? "",
                                                streamUrl: ProfileManager.shared.curUserModel?.avatar ?? "",
                                                memberCount: 0, roomStatus: .single)
                self.liveInfo = roomInfo
                callback?(Int(code), error)
            })
        }
        
        RoomManager.shared.createRoom(sdkAppID: sdkAppID, roomID: String(roomID), success: {
            [roomID, roomName, callback] in
            liveRoomCreate(roomName: roomName, roomID: roomID, callback: callback)
            }, failed: { [roomID, roomName, callback] code, err in
                if (code == -1301) {
                    liveRoomCreate(roomName: roomName, roomID: roomID, callback: callback)
                } else {
                    callback?(-1,err)
                }
        })
    }
    
    @objc func setupToast() {
        ToastManager.shared.position = .center
    }
    
    @objc func makeToast(message: String) {
        view.makeToast(message)
    }
    
    @objc func makeToast(message: String, duration: TimeInterval) {
        view.makeToast(message, duration: duration)
    }
}
