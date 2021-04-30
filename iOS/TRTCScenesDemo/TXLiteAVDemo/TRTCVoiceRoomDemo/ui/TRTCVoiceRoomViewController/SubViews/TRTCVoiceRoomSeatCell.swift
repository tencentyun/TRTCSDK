//
//  TRTCVoiceRoomSeatCell.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

enum TRTCVoiceRoomSeatCellType {
    case add
    case seat
    case lock
}

class TRTCVoiceRoomSeatCell: UICollectionViewCell {
    private var isViewReady: Bool = false
    
    let seatView: TRTCVoiceRoomSeatView = {
        let view = TRTCVoiceRoomSeatView.init(state: .cellSeatEmpty)
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
        contentView.addSubview(seatView)
    }
    
    func activateConstraints() {
        seatView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    func setCell(model: SeatInfoModel, userMuteMap: [String:Bool]) {
        seatView.setSeatInfo(model: model, userMuteMap: userMuteMap)
    }
    
    func setCell(_ type: TRTCVoiceRoomSeatCellType, _ model: SeatInfoModel) {
        switch type {
        case .add:
            seatView.avatarImageView.image = UIImage(named: "add")
            seatView.nameLabel.text = ""
            break
        case .lock:
            seatView.avatarImageView.image = UIImage(named: "lock")
            seatView.nameLabel.text = ""
            break
        default:
            setCell(model: model, userMuteMap: [:])
            break
        }
    }
}
