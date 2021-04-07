//
//  TRTCChatSalonTipsTableCell.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCChatSalonTipsTableCell: UITableViewCell {
    private var isViewReady: Bool = false
    
    private var acceptAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let containerView: UIView = {
        let view = UIView.init(frame: .zero)
        view.backgroundColor = UIColor.init(0x13233F, alpha: 0.4)
        view.layer.cornerRadius = 3.0
        return view
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setBackgroundImage(UIColor.init(0xE84B40).trans2Image(), for: .normal)
        button.setTitle(String.accept, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHidden = true
        button.layer.cornerRadius = 3.0
        button.layer.masksToBounds = true
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
        /// 此方法内只做add子视图操作
        contentView.addSubview(containerView)
        containerView.addSubview(contentLabel)
        containerView.addSubview(acceptButton)
    }
    
    func activateConstraints() {
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 2.0 / 3.0)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        containerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        acceptButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }
    }
    
    func bindInteraction() {
        acceptButton.addTarget(self, action: #selector(acceptAction(sender:)), for: .touchUpInside)
    }
    
    @objc
    private func acceptAction(sender: UIButton) {
        self.acceptAction?()
    }
    
    func setCell(info: String, action: (() -> Void)?){
        contentLabel.text = info
        contentLabel.sizeToFit()
        self.acceptAction = action
    }
    
    func updateCell() {
        if self.acceptAction != nil {
            acceptButton.isHidden = false
            // 重新布局
            contentLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-80)
                make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 2.0 / 3.0)
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-10)
            }
        } else {
            acceptButton.isHidden = true
            contentLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 2.0 / 3.0)
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-10)
            }
        }
        layoutIfNeeded()
    }
}

fileprivate extension String {
    static let accept = TRTCLocalize("Demo.TRTC.LiveRoom.accept")
}
