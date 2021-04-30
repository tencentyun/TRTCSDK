//
//  TRTCCreateChatSalonRootView.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/4.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit
import SnapKit
import Toast_Swift

class TRTCCreateChatSalonRootView: UIView {
    static let viewTitle: String = .titleText
    private var isViewReady: Bool = false
    private let viewModel: TRTCCreateChatSalonViewModel
    
    weak var rootViewController: UIViewController?
    
    required init?(coder: NSCoder) {
        fatalError("init corder is not permit in this view")
    }
    
    init(viewModel: TRTCCreateChatSalonViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .white
        roomNameInputTextFiled.text = viewModel.roomName
        bindInteraction()
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    // 输入框
    let inputContainer: UIView = {
        let view = UIView.init(frame: .zero)
        return view
    }()
    
    let roomNumberLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = .topicText
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = .black
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let roomNameInputTextFiled: UITextField = {
        let textField = UITextField.init(frame: .zero)
        textField.attributedPlaceholder = NSAttributedString.init(string: .topicPlaceholdText, attributes: [.font: UIFont.systemFont(ofSize: 16.0), .foregroundColor: UIColor.placeholderBackColor])
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 16.0)
        return textField
    }()
    
    let enterRoomButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.setTitleColor(UIColor.init(0x56749E), for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.setTitle(.startButtonText, for: .normal)
        button.setBackgroundImage(UIColor.inputImageBackColor.trans2Image(), for: .disabled)
        button.setBackgroundImage(UIColor.buttonBackColor.trans2Image(), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 24
        return button
    }()
    
//    let tipsLabel: UILabel = {
//        let label = UILabel.init(frame: .zero)
//        label.text = "若房间号不存在将自动创建并加入该房间"
//        label.font = UIFont.systemFont(ofSize: 16.0)
//        label.textColor = .placeholderBackColor
//        label.textAlignment = .center
//        label.adjustsFontSizeToFitWidth = true
//        return label
//    }()
    
    // MARK: - 视图生命周期
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
        // 输入区域
        addSubview(inputContainer)
        inputContainer.addSubview(roomNumberLabel)
        inputContainer.addSubview(roomNameInputTextFiled)
        // 进入按钮区域
        addSubview(enterRoomButton)
//        addSubview(tipsLabel)
    }

    func activateConstraints() {
        activateConstraintsOfInput()
        activateConstraintsOfEnterRoom()
    }

    func bindInteraction() {
        roomNameInputTextFiled.delegate = self
        
        roomNameInputTextFiled.text = viewModel.roomName
        enterRoomButton.addTarget(self, action: #selector(enterRoomAction(_:)), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.endEditing(true)
    }
}

extension TRTCCreateChatSalonRootView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == roomNameInputTextFiled {
            // 限制只能输入数字
            return true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == roomNameInputTextFiled {
            viewModel.roomName = textField.text ?? ""
        } else {
            viewModel.userName = textField.text ?? ""
        }
    }
}

extension TRTCCreateChatSalonRootView {
    
    @objc
    func enterRoomAction(_ sender: UIButton) {
        // 获取输入
        guard let roomNameString = roomNameInputTextFiled.text else {
            return
        }
        guard roomNameString != ""  else {
            makeToast(String.nameEmptyToast)
            return
        }
        viewModel.roomName = roomNameString
        viewModel.createRoom()
    }
}

extension TRTCCreateChatSalonRootView: TRTCCreateChatSalonViewResponder {
    func push(viewController: UIViewController) {
        rootViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - 自动化约束
extension TRTCCreateChatSalonRootView {
    func activateConstraintsOfInput() {
        inputContainer.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(15)
            } else {
                 make.top.equalToSuperview().offset(15)
            }
            make.height.equalTo(113*0.5)
        }
        roomNumberLabel.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(55)
        }
        roomNameInputTextFiled.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.left.equalTo(roomNumberLabel.snp.right).offset(30)
        }
    }
    
    func activateConstraintsOfEnterRoom() {
        enterRoomButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(48)
            make.top.equalTo(inputContainer.snp.bottom).offset(30)
        }
        
//        tipsLabel.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(enterRoomButton.snp.bottom).offset(30)
//            make.left.right.equalTo(enterRoomButton)
//        }
    }
}

fileprivate extension String {
    static let titleText = TRTCLocalize("Demo.TRTC.Salon.createsalonroom")
    static let topicText = TRTCLocalize("Demo.TRTC.Salon.topic")
    static let topicPlaceholdText = TRTCLocalize("Demo.TRTC.Salon.defaultroomtopic")
    static let userNameText = TRTCLocalize("Demo.TRTC.Salon.userid")
    static let userNamePlaceholdText = TRTCLocalize("Demo.TRTC.Salon.defaultuserid")
    static let startButtonText = TRTCLocalize("Demo.TRTC.Salon.letsgo")
    static let nameEmptyToast = TRTCLocalize("Demo.TRTC.Salon.nicknameorusernameisempty")
}
