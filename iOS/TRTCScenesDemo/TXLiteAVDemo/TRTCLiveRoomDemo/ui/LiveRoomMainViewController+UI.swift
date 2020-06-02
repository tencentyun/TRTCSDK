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
            let uintIDs = ids.compactMap {
                UInt32($0)
            }
            if uintIDs.count == 0 {
                self?.roomsCollection.mj_header?.endRefreshing()
                self?.view.makeToast("当前暂无内容哦~")
                return
            }
            self?.liveRoom?.getRoomInfos(roomIDs: uintIDs, callback: { (code, error, infos) in
                self?.roomsCollection.mj_header?.endRefreshing()
                if code == 0 {
                    self?.roomInfos = infos
                    self?.roomsCollection.reloadData()
                    if infos.count == 0 {
                        self?.view.makeToast("当前暂无内容哦~")
                    }
                } else {
                   self?.view.makeToast("获取房间列表失败")
                }
            })
        }) { [weak self] (code, error) in
            debugPrint(error)
            self?.roomsCollection.mj_header?.endRefreshing()
            self?.view.makeToast("获取房间列表失败")
        }
    }
    
    @objc func createRoom() {
        guard let vc = TCAnchorViewController() else {return}
        vc.liveRoom = liveRoom
        navigationController?.pushViewController(vc, animated: true)
    }
}
