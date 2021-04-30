//
//  TRTCChatSalonTakeSeatTipsView.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2021/3/1.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit

class TRTCChatSalonTakeSeatTipsView: UIView {
    static let kHeight: CGFloat = 92
    
    private var isViewReady: Bool = false
    let viewModel: TRTCChatSalonViewModel
    var currentTakeSeatInfo: CSMemberRequestEntity? {
        didSet {
            contentLabel.text = "\(currentTakeSeatInfo?.userInfo.userName ?? (currentTakeSeatInfo?.userID ?? ""))\(String.takeSeatSuffix)"
        }
    }
    
    init(frame: CGRect = .zero, viewModel: TRTCChatSalonViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    let contentLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .black
        label.fontSize = 14
        return label
    }()
    
    let welcomeButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setTitle(.welcomeText, for: .normal)
        button.setBackgroundImage(UIColor.init(0x0FA968).trans2Image(), for: .normal)
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        return button
    }()
    
    let refuseButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setTitle(.refuseText, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setBackgroundImage(UIColor(hex: "F4F5F9")!.trans2Image(), for: .normal)
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        return button
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
    
    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(contentLabel)
        addSubview(welcomeButton)
        addSubview(refuseButton)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
        }
        welcomeButton.snp.makeConstraints { (make) in
            make.right.equalTo(snp.centerX).offset(-15)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(36)
            make.width.equalTo(104)
        }
        refuseButton.snp.makeConstraints { (make) in
            make.left.equalTo(snp.centerX).offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(36)
            make.width.equalTo(104)
        }
    }

    func bindInteraction() {
        welcomeButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        refuseButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
    }
    
    @objc
    func buttonAction(sender: UIButton) {
        guard let requestInfo = self.currentTakeSeatInfo else { return }
        switch sender {
        case welcomeButton:
            viewModel.acceptTakeSeat(identifier: requestInfo.userID)
        case refuseButton:
            break;
        default:
            break
        }
        viewModel.hideRequestTakeSeatTipsView()
    }
}


fileprivate extension String {
    static let welcomeText = TRTCLocalize("Demo.TRTC.Salon.welcome")
    static let refuseText = TRTCLocalize("Demo.TRTC.Salon.dismiss")
    static let takeSeatSuffix = TRTCLocalize("Demo.TRTC.Salon.appliestobecomeaspeaker")
}

fileprivate extension UIColor {
    static let backgroundBlue = UIColor.init(0x0062E3)
}
