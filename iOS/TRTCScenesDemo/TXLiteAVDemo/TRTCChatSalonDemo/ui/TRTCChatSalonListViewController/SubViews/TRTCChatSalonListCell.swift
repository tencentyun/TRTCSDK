//
//  TRTCChatSalonListCell.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCChatSalonListCell: UICollectionViewCell {
    private var isViewReady: Bool = false
    
    let coverImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let anchorNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    let roomNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let memberCountLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = .white
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    func setCell(model: ChatSalonInfo) {
        let imageURL = URL.init(string: model.coverUrl)
        let imageName = "voiceroom_cover1"
        self.coverImageView.sd_setImage(with:imageURL, placeholderImage:UIImage.init(named: imageName) ,completed: nil)
        self.anchorNameLabel.text = model.ownerName
        self.roomNameLabel.text = model.roomName
        self.memberCountLabel.text = "\(model.memberCount)\(String.online)"
    }
    
    // MARK: - 视图生命周期函数
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        layer.cornerRadius = 10
        clipsToBounds = true
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        backgroundColor = UIColor.init(0x000000, alpha: 0.5)
    }
    
    func constructViewHierarchy() {
        addSubview(coverImageView)
        addSubview(anchorNameLabel)
        addSubview(roomNameLabel)
        addSubview(memberCountLabel)
    }
    
    func activateConstraints() {
        coverImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        roomNameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(6.0)
            make.bottom.equalToSuperview().offset(-6.0)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.55)
        }
        anchorNameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(6.0)
            make.bottom.equalTo(roomNameLabel.snp.top).offset(-6.0)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.6)
        }
        memberCountLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-6.0)
            make.bottom.equalToSuperview().offset(-6.0)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.38)
        }
    }
    
    
}

fileprivate extension String {
    static let online = TRTCLocalize("Demo.TRTC.Salon.online")
}
