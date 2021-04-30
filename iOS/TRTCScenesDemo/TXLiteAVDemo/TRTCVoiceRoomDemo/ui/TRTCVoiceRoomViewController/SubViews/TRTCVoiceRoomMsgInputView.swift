//
//  TRTCVoiceRoomMsgInputView.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/14.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCVoiceRoomMsgInputView: UIView {
    private var isViewReady: Bool = false
    let viewModel: TRTCVoiceRoomViewModel
    
    init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        bindInteraction()
    }
    
    let containerView: UIView = {
        let view = UIView.init(frame: .zero)
        view.backgroundColor = UIColor.init(0xFFFFFF, alpha: 1.0)
        return view
    }()
    
    let msgTextFiled: UITextField = {
        let textField = UITextField.init(frame: .zero)
        textField.attributedPlaceholder = NSAttributedString.init(string: .saysmtText, attributes: [.font: UIFont.systemFont(ofSize: 16.0), .foregroundColor: UIColor.placeholderBackColor])
        textField.textColor = UIColor.init(0x000000)
        textField.font = UIFont.systemFont(ofSize: 16.0)
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle(.sendText, for: .normal)
        button.backgroundColor = UIColor(hex: "29CC85")
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        button.layer.cornerRadius = 18
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
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
        addSubview(containerView)
        containerView.addSubview(msgTextFiled)
        containerView.addSubview(sendButton)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        msgTextFiled.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.bottom.top.equalToSuperview()
            make.right.equalTo(sendButton.snp.left).offset(-10)
        }
        sendButton.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(36)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        containerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
    }

    func bindInteraction() {
        /// 此方法负责做viewModel和视图的绑定操作
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardHiden(sender:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        sendButton.addTarget(self, action: #selector(msgSend(sender:)), for: .touchUpInside)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func keyBoardShow(sender: Notification) {
        guard let value = sender.userInfo?["UIKeyboardBoundsUserInfoKey"] as? NSValue else { return }
        let rect = value.cgRectValue
        DispatchQueue.main.async {
            self.containerView.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(60)
                make.bottom.equalToSuperview().offset(-rect.height)
            }
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }
    
    @objc
    func keyBoardHiden(sender: Notification) {
        DispatchQueue.main.async {
            self.containerView.snp.remakeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(60)
            }
            self.layoutIfNeeded()
        }
    }
    
    func showMsgInput() {
        isHidden = false
        msgTextFiled.becomeFirstResponder()
    }
    
    func hideTextInput() {
        isHidden = true
        msgTextFiled.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        guard !containerView.frame.contains(touch.location(in: self)) else { return }
        hideTextInput()
    }
    
    @objc
    func msgSend(sender: UIButton) {
        if let text = msgTextFiled.text {
            if text != "" {
                viewModel.onTextMsgSend(message: text)
                msgTextFiled.text = ""
            }
        }
        hideTextInput()
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let saysmtText = TRTCLocalize("Demo.TRTC.VoiceRoom.saysomething")
    static let sendText = TRTCLocalize("Demo.TRTC.LiveRoom.send")

}



