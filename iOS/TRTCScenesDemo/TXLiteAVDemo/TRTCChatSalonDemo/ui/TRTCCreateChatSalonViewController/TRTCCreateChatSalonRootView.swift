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
        roomNameInputTextFiled.text = viewModel.roomName
        userNameTextFiled.text = viewModel.userName
        bindInteraction()
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    let backgroundLayer: CALayer = {
        // fillCode
        let layer = CAGradientLayer()
        layer.colors = [UIColor.init(0x13294b).cgColor, UIColor.init(0x000000).cgColor]
        layer.locations = [0.2, 1.0]
        layer.startPoint = CGPoint(x: 0.4, y: 0)
        layer.endPoint = CGPoint(x: 0.6, y: 1.0)
        return layer
    }()
    
    // 输入框
    let inputContainer: UIView = {
        let view = UIView.init(frame: .zero)
        // fillCode
        let layer = CAGradientLayer()
        layer.colors = [UIColor(red: 0.05, green: 0.17, blue: 0.36, alpha: 1).cgColor, UIColor(red: 0.07, green: 0.15, blue: 0.33, alpha: 1).cgColor]
        layer.locations = [0, 1]
        layer.frame = CGRect.init(origin: .zero, size: .init(width: UIScreen.main.bounds.width - 40, height: 113))
        layer.startPoint = CGPoint(x: 0.26, y: 0.13)
        layer.endPoint = CGPoint(x: 0.92, y: 0.92)
        view.layer.addSublayer(layer)
        return view
    }()
    
    let roomNumberLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = .topicText
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let roomNameInputTextFiled: UITextField = {
        let textField = UITextField.init(frame: .zero)
        textField.attributedPlaceholder = NSAttributedString.init(string: .topicPlaceholdText, attributes: [.font: UIFont.systemFont(ofSize: 16.0), .foregroundColor: UIColor.placeholderBackColor])
        textField.textColor = UIColor.init(0xEBF4FF)
        textField.font = UIFont.systemFont(ofSize: 16.0)
        return textField
    }()

    
    let cuttingLine: UIView = {
        let view = UIView.init(frame: .zero)
        view.backgroundColor = UIColor.init(0xFFFFFF, alpha: 0.11)
        return view
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = .userNameText
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let userNameTextFiled: UITextField = {
        let textField = UITextField.init(frame: .zero)
        textField.attributedPlaceholder = NSAttributedString.init(string: .userNamePlaceholdText, attributes: [.font: UIFont.systemFont(ofSize: 16.0), .foregroundColor: UIColor.placeholderBackColor])
        textField.textColor = UIColor.init(0xEBF4FF)
        textField.font = UIFont.systemFont(ofSize: 16.0)
        return textField
    }()
    
    let enterRoomButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.setTitleColor(UIColor.init(0x56749E), for: .disabled)
        button.setTitleColor(UIColor.init(0xFFFFFF), for: .normal)
        button.setTitle(.startButtonText, for: .normal)
        button.setBackgroundImage(UIColor.inputImageBackColor.trans2Image(), for: .disabled)
        button.setBackgroundImage(UIColor.buttonBackColor.trans2Image(), for: .normal)
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
        backgroundLayer.frame = self.bounds;
        layer.insertSublayer(backgroundLayer, at: 0)
        // 输入区域
        addSubview(inputContainer)
        inputContainer.addSubview(roomNumberLabel)
        inputContainer.addSubview(roomNameInputTextFiled)
        inputContainer.addSubview(cuttingLine)
        inputContainer.addSubview(userNameLabel)
        inputContainer.addSubview(userNameTextFiled)
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
        userNameTextFiled.delegate = self
        
        roomNameInputTextFiled.text = viewModel.roomName
        userNameTextFiled.text = viewModel.userName
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
        } else if textField == userNameTextFiled {
            // 可以对输入做限制
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
        guard let roomNameString = roomNameInputTextFiled.text, let userNameString = userNameTextFiled.text else {
            return
        }
        guard roomNameString != "" && userNameString != ""  else {
            makeToast(String.nameEmptyToast)
            return
        }
        viewModel.roomName = roomNameString
        viewModel.userName = userNameString
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
            make.height.equalTo(113)
        }
        cuttingLine.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        roomNumberLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(cuttingLine.snp.top)
            make.left.equalTo(cuttingLine.snp.left)
            make.width.equalTo(55)
        }
        roomNameInputTextFiled.snp.makeConstraints { (make) in
            make.right.equalTo(cuttingLine.snp.right)
            make.top.equalToSuperview()
            make.bottom.equalTo(cuttingLine.snp.top)
            make.left.equalTo(roomNumberLabel.snp.right).offset(30)
        }
        userNameLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.top.equalTo(cuttingLine.snp.bottom)
            make.left.equalTo(cuttingLine.snp.left)
            make.width.equalTo(55)
        }
        userNameTextFiled.snp.makeConstraints { (make) in
            make.right.equalTo(cuttingLine.snp.right)
            make.bottom.equalToSuperview()
            make.top.equalTo(cuttingLine.snp.bottom)
            make.left.equalTo(userNameLabel.snp.right).offset(30)
        }
    }
    
    func activateConstraintsOfEnterRoom() {
        enterRoomButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(48)
            make.top.equalTo(userNameTextFiled.snp.bottom).offset(30)
        }
        
//        tipsLabel.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(enterRoomButton.snp.bottom).offset(30)
//            make.left.right.equalTo(enterRoomButton)
//        }
    }
}

fileprivate extension String {
    static let titleText = ChatSalonLocalized.getLocalizedString(key: "create a chat salon room")
    static let topicText = ChatSalonLocalized.getLocalizedString(key: "topic")
    static let topicPlaceholdText = ChatSalonLocalized.getLocalizedString(key: "default room topic")
    static let userNameText = ChatSalonLocalized.getLocalizedString(key: "user ID")
    static let userNamePlaceholdText = ChatSalonLocalized.getLocalizedString(key: "default user ID")
    static let startButtonText = ChatSalonLocalized.getLocalizedString(key: "Let’s go")
    static let nameEmptyToast = ChatSalonLocalized.getLocalizedString(key: "Nickname or username is empty")
}
