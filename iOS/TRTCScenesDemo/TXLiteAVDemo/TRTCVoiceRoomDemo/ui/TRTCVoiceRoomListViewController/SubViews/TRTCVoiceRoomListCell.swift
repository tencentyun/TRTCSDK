//
//  TRTCVoiceRoomListCell.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCVoiceRoomListCell: UICollectionViewCell {
    private var isViewReady: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let coverImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let anchorNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let roomNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.textColor = .white
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var memberContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    lazy var memberBgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.alpha = 0.2
        return view
    }()
    
    lazy var memberCountIcon: UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "audience"))
        return imageV
    }()
    
    let memberCountLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont(name: "PingFangSC-Medium", size: 12)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    func setCell(model: VoiceRoomInfo) {
        let imageURL = URL.init(string: model.coverUrl)
        let imageName = "voiceroom_cover1"
        self.coverImageView.sd_setImage(with:imageURL, placeholderImage:UIImage.init(named: imageName) ,completed: nil)
        self.anchorNameLabel.text = model.ownerName
        self.roomNameLabel.text = model.roomName.count > 0 ? model.roomName : " "
        self.memberCountLabel.text = String(model.memberCount)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        memberContainerView.layer.cornerRadius = memberContainerView.frame.height * 0.5
    }
    
    // MARK: - 视图生命周期函数
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
        contentView.addSubview(coverImageView)
        contentView.addSubview(anchorNameLabel)
        contentView.addSubview(roomNameLabel)
        contentView.addSubview(memberContainerView)
        memberContainerView.addSubview(memberBgView)
        memberContainerView.addSubview(memberCountIcon)
        memberContainerView.addSubview(memberCountLabel)
    }
    
    func activateConstraints() {
        coverImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        roomNameLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.greaterThanOrEqualToSuperview().offset(-10)
        }
        anchorNameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(roomNameLabel)
            make.bottom.equalTo(roomNameLabel.snp_top)
            make.trailing.greaterThanOrEqualToSuperview().offset(-10)
        }
        memberContainerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
        }
        memberBgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        memberCountIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(memberContainerView.snp_leading).offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        memberCountLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.trailing.equalToSuperview().offset(-8)
            make.leading.equalTo(memberCountIcon.snp_centerX).offset(8)
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let onlinexxText = TRTCLocalize("Demo.TRTC.VoiceRoom.xxonline")
}
