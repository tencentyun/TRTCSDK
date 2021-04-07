//
//  TRTCAudienceTableViewCell.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/15.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCAudienceTableViewCell: UITableViewCell {
    private var isViewReady: Bool = false
    private var model: AudienceInfoModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let iconView: UIImageView = {
        let view = UIImageView.init(frame: .zero)
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 22.0
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        return label
    }()
    
    let inviateButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle(.inviteText, for: .normal)
        button.setBackgroundImage(UIColor.buttonBackColor.trans2Image(), for: .normal)
        button.setTitle(.acceptText, for: .selected)
        button.setBackgroundImage(UIColor.init(0xE84B40).trans2Image(), for: .selected)
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - 视图的生命周期函数
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        contentView.removeFromSuperview()
        constructViewHierarchy()
        activateConstraints()
    }
    
    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(inviateButton)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
        iconView.image = UIImage.init(named: "voiceroom_placeholder_avatar")
    }
    
    func activateConstraints() {
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.width.equalTo(44)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(10)
        }
        inviateButton.snp.makeConstraints { (make) in
            make.width.equalTo(68)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    func bindInteraction() {
        inviateButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
    }
    
    @objc
    func buttonAction(sender: UIButton) {
        model?.action(sender.isSelected ? 1 : 0)
    }
    
    func setCell(model: AudienceInfoModel) {
        let avatarUrl = URL.init(string: model.userInfo.userAvatar)
        iconView.sd_setImage(with: avatarUrl, placeholderImage:UIImage.init(named: "voiceroom_placeholder_avatar") ,completed: nil)
        nameLabel.text = model.userInfo.userName
        inviateButton.isSelected = model.type == AudienceInfoModel.TYPE_WAIT_AGREE
        inviateButton.isHidden = model.type == AudienceInfoModel.TYPE_IN_SEAT
        self.model = model
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let acceptText = TRTCLocalize("Demo.TRTC.LiveRoom.accept")
    static let inviteText = TRTCLocalize("Demo.TRTC.LiveRoom.invite")
}

