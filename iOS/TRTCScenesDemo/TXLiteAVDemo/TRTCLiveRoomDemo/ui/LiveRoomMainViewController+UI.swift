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
//        gradientLayer.colors = colors.compactMap{ $0 }
//        gradientLayer.frame = view.bounds
//        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.backgroundColor = .white
        
        self.view.addSubview(roomsCollection)
        roomsCollection.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(UIScreen.main.bounds.size.height * 27.0/667)
            make.bottom.equalTo(0)
        }
        
        self.view.addSubview(createRoomBtn)
        createRoomBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-40)
            make.trailing.equalTo(-32)
            make.width.height.equalTo(60)
        }
        createRoomBtn.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    @objc func loadRoomsInfo() {
        RoomManager.shared.getRoomList(sdkAppID: SDKAPPID, success: { [weak self] (ids) in
            let uintIDs = ids.compactMap {
                UInt32($0)
            }.map { (value) -> NSNumber in
                return NSNumber.init(value: value)
            }
            if uintIDs.count == 0 {
                self?.roomsCollection.mj_header?.endRefreshing()
                self?.view.makeToast(.noContentText)
                return
            }
            self?.liveRoom?.getRoomInfos(roomIDs: uintIDs, callback: { (code, error, infos) in
                self?.roomsCollection.mj_header?.endRefreshing()
                if code == 0 {
                    self?.roomInfos = infos
                    self?.roomsCollection.reloadData()
                    if infos.count == 0 {
                        self?.view.makeToast(.noContentText)
                    }
                } else {
                    self?.view.makeToast(.listFailedText)
                }
            })
        }) { [weak self] (code, error) in
            debugPrint(error)
            self?.roomsCollection.mj_header?.endRefreshing()
            self?.view.makeToast(.listFailedText)
        }
    }
    
    @objc func createRoom() {
        guard let vc = TCAnchorViewController() else {return}
        vc.liveRoom = liveRoom
        navigationController?.pushViewController(vc, animated: true)
    }
}
private extension String {
    static let noContentText = TRTCLocalize("Demo.TRTC.LiveRoom.nocontentnow~")
    static let listFailedText = TRTCLocalize("Demo.TRTC.LiveRoom.getroomlistfailed")
}
