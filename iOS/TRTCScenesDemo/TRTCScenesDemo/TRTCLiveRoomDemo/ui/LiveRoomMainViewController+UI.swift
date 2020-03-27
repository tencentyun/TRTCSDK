//
//  LiveRoomMainViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 2020/2/21.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Toast_Swift

extension LiveRoomMainViewController {
    func setupUI() {
        ToastManager.shared.position = .bottom
        view.backgroundColor = .appBackGround

        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        topPadding = max(44, topPadding)
        
        roomsCollection.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(topPadding + 10)
            make.bottom.equalTo(-100)
        }
        
        createRoomBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-30)
            make.leading.equalTo(32)
            make.trailing.equalTo(-32)
            make.height.equalTo(50)
        }
        createRoomBtn.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    @objc func loadRoomsInfo() {
        RoomManager.shared.getRoomList(sdkAppID: SDKAPPID, success: { [weak self] (ids) in
            self?.liveRoom?.getRoomInfos(roomIDs: ids, callback: { (code, error, infos) in
                self?.roomsCollection.mj_header?.endRefreshing()
                self?.roomInfos = infos
                self?.roomsCollection.reloadData()
                if infos.count == 0 {
                    self?.view.makeToast("当前暂无内容哦~")
                }
            })
        }) { [weak self] (code, error) in
            debugPrint(error)
            self?.roomsCollection.mj_header?.endRefreshing()
        }
    }
    
    @objc func generateRoomID() -> UInt32 {
        let userID = (ProfileManager.shared.curUserModel?.userId ?? "")
        return  UInt32(truncatingIfNeeded: (userID.hash)) & 0x7FFFFFFF
    }
    
    @objc func _createRoom(sdkAppID: Int32,roomName: String, roomID: UInt32) {
        RoomManager.shared.createRoom(sdkAppID: sdkAppID, roomID: String(roomID), success: {
            [weak self, roomID, roomName] in
            let roomParam = TRTCCreateRoomParam(roomName: roomName, coverUrl: ProfileManager.shared.curUserModel?.avatar ?? "")
            self?.liveRoom?.createRoom(roomID: roomID, roomParam: roomParam, callback: { (code, error) in
                let roomInfo = TRTCLiveRoomInfo(roomId: String(roomID), roomName: roomName,
                                                coverUrl: ProfileManager.shared.curUserModel?.avatar ?? "",
                                                ownerId: ProfileManager.shared.curUserID() ?? "",
                                                ownerName: ProfileManager.shared.curUserModel?.name ?? "",
                                                streamUrl: ProfileManager.shared.curUserModel?.avatar ?? "",
                                                memberCount: 0, type: .single)
                guard let vc = TCAnchorViewController(publishInfo: roomInfo) else {
                    return
                }
                vc.liveRoom = self?.liveRoom
                self?.navigationController?.pushViewController(vc, animated: true)
            })
        }, failed: { [weak self, roomID, roomName] code, err in
            if (code == -1301) {
                self?.view.makeToast("房间已存在，重新进入房间")
                 let roomParam = TRTCCreateRoomParam(roomName: roomName, coverUrl: ProfileManager.shared.curUserModel?.avatar ?? "")
                self?.liveRoom?.createRoom(roomID: roomID, roomParam: roomParam, callback: { (code, error) in
                    let roomInfo = TRTCLiveRoomInfo(roomId: String(roomID), roomName: roomName,
                                                    coverUrl: ProfileManager.shared.curUserModel?.avatar ?? "",
                                                    ownerId: ProfileManager.shared.curUserID() ?? "",
                                                    ownerName: ProfileManager.shared.curUserModel?.name ?? "",
                                                    streamUrl: ProfileManager.shared.curUserModel?.avatar ?? "",
                                                    memberCount: 0, type: .single)
                    guard let vc = TCAnchorViewController(publishInfo: roomInfo) else {
                        return
                    }
                    vc.liveRoom = self?.liveRoom
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
            }
        })
    }
    
    @objc func createRoom() {
        let alert = UIAlertController.init(title: "请输入直播间名称", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "确定", style: .default) { [weak self](action) in
            if let nameTextfield = alert.textFields?.first {
                if let name = nameTextfield.text, name.count > 0 {
                    guard let roomID = self?.generateRoomID() else {
                        return
                    }
                    self?._createRoom(sdkAppID: SDKAPPID, roomName: name, roomID: roomID)
                } else {
                    self?.view.makeToast("房间名称不能为空")
                }
            }
        }
        
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (text) in
            text.placeholder = "房间名称"
        }
        present(alert, animated: true, completion: nil)
    }
}
