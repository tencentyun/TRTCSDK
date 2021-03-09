//
//  TRTCChatSalonSeatCell.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCChatSalonSeatCell: UICollectionViewCell {
    private var isViewReady: Bool = false
    
    let seatView: TRTCChatSalonSeatView = {
        let view = TRTCChatSalonSeatView.init(state: .cellSeatEmpty)
        return view
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    func constructViewHierarchy() {
        addSubview(seatView)
    }
    
    func activateConstraints() {
        seatView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    func setCell(model: ChatSalonSeatInfoModel) {
        seatView.setSeatInfo(model: model)
    }
    
    func setCell(audience: CSAudienceInfoModel) {
        let seatInfo = ChatSalonSeatInfoModel.init(seatIndex: 0, isClosed: false, isUsed: true, isOwner: false, seatInfo: nil, seatUser: audience.userInfo) { (model) in
            
        }
        seatView.setSeatInfo(model: seatInfo, showMute: false)
    }
}
