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
    
    deinit {
        TRTCLog.out("seat view deinit")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height*0.5
        
        speakView.layer.cornerRadius = speakView.frame.height*0.5
        speakView.layer.borderWidth = 4
        speakView.layer.borderColor = UIColor.init(0x0FA968).cgColor
    }
    let speakView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        return view
    }()
    let avatarImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "voiceroom_placeholder_avatar")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let muteImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "audience_voice_off")
        imageView.isHidden = true
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
        label.minimumScaleFactor = 0.5
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
        avatarImageView.addSubview(speakView)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        avatarImageView.snp.makeConstraints { (make) in
            make.top.centerX.width.equalToSuperview()
            make.height.equalTo(avatarImageView.snp_width)
        }
        muteImageView.snp.makeConstraints { (make) in
            make.trailing.bottom.equalTo(avatarImageView)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(avatarImageView.snp_bottom).offset(8)
            make.width.lessThanOrEqualTo(120)
        }
        speakView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func bindInteraction() {
        /// 此方法负责做viewModel和视图的绑定操作
    }
    
    func isMute(userId: String, map: [String:Bool]) -> Bool {
        if map.keys.contains(userId) {
            return map[userId]!
        }
        return true
    }
    
    func setSeatInfo(model: SeatInfoModel, userMuteMap: [String:Bool]) {
        if model.isClosed {
            // close 状态
            avatarImageView.image = UIImage.init(named: "room_lockseat")
            nameLabel.text = ""//.lockedText
            return
        }
        
        if let user = model.seatUser {
            let userMute = isMute(userId: user.userId, map: userMuteMap)
            muteImageView.isHidden = !((model.seatInfo?.mute ?? false) || userMute)
        }
        else {
            muteImageView.isHidden = true
        }
        
        if model.isUsed {
            // 有人
            if let userSeatInfo = model.seatUser {
                avatarImageView.sd_setImage(with: URL.init(string: userSeatInfo.userAvatar), placeholderImage: UIImage.init(named: "voiceroom_placeholder_avatar"), options: .allowInvalidSSLCertificates, context: nil)
                nameLabel.text = userSeatInfo.userName
            }
        } else {
            // 无人
            avatarImageView.image = UIImage.init(named: "Servingwheat")
            nameLabel.text = ""
                //model.isOwner ? .inviteHandsupText : .handsupText
        }
        if (model.isTalking) {
            speakView.isHidden = false
        } else {
            speakView.isHidden = true
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



