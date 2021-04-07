//
//  TRTCVoiceRoomRootView.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/8.
//Copyright © 2020 tencent. All rights reserved.
//
import UIKit

// 设置字号和透明度的
enum TRTCSeatState {
    case cellSeatEmpty
    case cellSeatFull
    case masterSeatEmpty
    case masterSeatFull
}

// 需要设置合理的高度和宽度获得正常的显示效果(高度越高，name和avatar之间的间距越大)
class TRTCVoiceRoomSeatView: UIView {
    private var isViewReady: Bool = false
    private var isGetBounds: Bool = false
    private var state: TRTCSeatState {
        didSet {
            stateChange()
        }
    }
    
    init(frame: CGRect = .zero, state: TRTCSeatState) {
        self.state = state
        super.init(frame: frame)
        bindInteraction()
        stateChange()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard !isGetBounds else {
            return
        }
        
        let width = self.frame.width
        avatarImageView.layer.cornerRadius = width / 2.0
        avatarImageView.layer.masksToBounds = true
    }
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "voiceroom_placeholder_avatar")
        return imageView
    }()
    
    let muteImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "voiceroom_mic_dis")
        imageView.isHidden = true
        imageView.alpha = 0.8
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = .handsupText
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: - 视图生命周期函数
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
    }

    func setupStyle() {
        backgroundColor = .clear
    }
    
    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(avatarImageView)
        addSubview(muteImageView)
        addSubview(nameLabel)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        avatarImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(snp.width)
        }
        muteImageView.snp.makeConstraints { (make) in
            make.center.equalTo(avatarImageView.snp.center)
            make.height.width.equalTo(snp.width).multipliedBy(0.5)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func bindInteraction() {
        /// 此方法负责做viewModel和视图的绑定操作
    }
    
    func setSeatInfo(model: SeatInfoModel) {
        if model.isClosed {
            // close 状态
            avatarImageView.image = UIImage.init(named: "voiceroom_seat_lock")
            nameLabel.text = .lockedText
            return
        }
        muteImageView.isHidden = !(model.seatInfo?.mute ?? false)
        if model.isUsed {
            // 有人
            if let userSeatInfo = model.seatUser {
                avatarImageView.sd_setImage(with: URL.init(string: userSeatInfo.userAvatar), placeholderImage: UIImage.init(named: "voiceroom_placeholder_avatar"), options: .allowInvalidSSLCertificates, context: nil)
                nameLabel.text = userSeatInfo.userName
            }
        } else {
            // 无人
            avatarImageView.image = UIImage.init(named: "voiceroom_placeholder_avatar")
            nameLabel.text = model.isOwner ? .inviteHandsupText : .handsupText
        }
    }
}

extension TRTCVoiceRoomSeatView {
    
    private func stateChange() {
        switch state {
        case .cellSeatEmpty:
            toEmptyStates(isMaster: false)
        case .masterSeatEmpty:
            toEmptyStates(isMaster: true)
        case .cellSeatFull:
            toFullStates(isMaster: false)
        case .masterSeatFull:
            toFullStates(isMaster: true)
        }
    }
    
    private func toEmptyStates(isMaster: Bool) {
        let fontSize: CGFloat = isMaster ? 18.0 : 14.0
        nameLabel.font = UIFont.systemFont(ofSize: fontSize)
        nameLabel.textColor = .placeholderBackColor
    }
    
    private func toFullStates(isMaster: Bool) {
        let fontSize: CGFloat = isMaster ? 18.0 : 14.0
        nameLabel.font = UIFont.systemFont(ofSize: fontSize)
        nameLabel.textColor = UIColor.init(0xEBF4FF)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let handsupText = TRTCLocalize("Demo.TRTC.VoiceRoom.presshandsup")
    static let lockedText = TRTCLocalize("Demo.TRTC.VoiceRoom.islocked")
    static let inviteHandsupText = TRTCLocalize("Demo.TRTC.VoiceRoom.invitehandsup")
}



