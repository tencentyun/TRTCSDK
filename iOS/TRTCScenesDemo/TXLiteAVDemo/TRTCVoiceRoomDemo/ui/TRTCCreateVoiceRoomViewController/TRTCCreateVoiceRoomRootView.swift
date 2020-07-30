//
//  TRTCCreateVoiceRoomRootView.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/4.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit
import SnapKit
import Toast_Swift

class TRTCCreateVoiceRoomRootView: UIView {
    
    private var isViewReady: Bool = false
    private let viewModel: TRTCCreateVoiceRoomViewModel
    
    weak var rootViewController: UIViewController?
    
    required init?(coder: NSCoder) {
        fatalError("init corder is not permit in this view")
    }
    
    init(viewModel: TRTCCreateVoiceRoomViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        super.init(frame: frame)
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
        label.text = "主题"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let roomNameInputTextFiled: UITextField = {
        let textField = UITextField.init(frame: .zero)
        textField.attributedPlaceholder = NSAttributedString.init(string: "请输入房间主题", attributes: [.font: UIFont.systemFont(ofSize: 16.0), .foregroundColor: UIColor.placeholderBackColor])
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
        label.text = "昵称"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let userNameTextFiled: UITextField = {
        let textField = UITextField.init(frame: .zero)
        textField.attributedPlaceholder = NSAttributedString.init(string: "请输入昵称", attributes: [.font: UIFont.systemFont(ofSize: 16.0), .foregroundColor: UIColor.placeholderBackColor])
        textField.textColor = UIColor.init(0xEBF4FF)
        textField.font = UIFont.systemFont(ofSize: 16.0)
        return textField
    }()
    
    let roleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = "上麦需要房主同意"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        return label
    }()
    
    let roleButtonStack: UIStackView = {
        let stack = UIStackView.init(frame: .zero)
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    let roleSwitchButton: UISwitch = {
        let roleSwitchButton = UISwitch.init()
        roleSwitchButton.isOn = true // 默认同意
        roleSwitchButton.onTintColor = .buttonBackColor
        return roleSwitchButton
    }()
    
    let toneQualityLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = "音质选择"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        return label
    }()
    
    let toneQualityStack: UIStackView = {
        let stack = UIStackView.init(frame: .zero)
        stack.axis = .horizontal // 布局方向
        stack.distribution = .equalSpacing // 主方向上的排布方式
        stack.alignment = .center // 子方向的对齐方式
        return stack
    }()
    
    let heightQualityButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("音乐", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.setImage(UIImage.init(named: "voiceroom_oval"), for: .normal)
        button.setImage(UIImage.init(named: "voiceroom_selected"), for: .selected)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 5)
        button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let mediumQualityButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("标准", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.setImage(UIImage.init(named: "voiceroom_oval"), for: .normal)
        button.setImage(UIImage.init(named: "voiceroom_selected"), for: .selected)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 5)
        button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let lowQualityButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("语音", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.setImage(UIImage.init(named: "voiceroom_oval"), for: .normal)
        button.setImage(UIImage.init(named: "voiceroom_selected"), for: .selected)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 5)
        button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let enterRoomButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.setTitleColor(UIColor.init(0x56749E), for: .disabled)
        button.setTitleColor(UIColor.init(0xFFFFFF), for: .normal)
        button.setTitle("创建聊天室", for: .normal)
        button.setBackgroundImage(UIColor.inputImageBackColor.trans2Image(), for: .disabled)
        button.setBackgroundImage(UIColor.buttonBackColor.trans2Image(), for: .normal)
        return button
    }()
    
    let tipsLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = "若房间号不存在将自动创建并加入该房间"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = .placeholderBackColor
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
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
        // 设置区域
        addSubview(roleButtonStack)
        roleButtonStack.addArrangedSubview(roleLabel)
        roleButtonStack.addArrangedSubview(roleSwitchButton)
        addSubview(toneQualityStack)
        toneQualityStack.addArrangedSubview(toneQualityLabel)
        toneQualityStack.addArrangedSubview(heightQualityButton)
        toneQualityStack.addArrangedSubview(mediumQualityButton)
        // 进入按钮区域
        addSubview(enterRoomButton)
        addSubview(tipsLabel)
    }

    func activateConstraints() {
        activateConstraintsOfInput()
        activateConstraintsOfButtonItem()
        activateConstraintsOfEnterRoom()
    }

    func bindInteraction() {
        roleSwitchButton.isOn = viewModel.needRequest
        heightQualityButton.isSelected = true
        roomNameInputTextFiled.delegate = self
        userNameTextFiled.delegate = self
        
        roomNameInputTextFiled.text = viewModel.roomName
        userNameTextFiled.text = viewModel.userName
        /// 此方法负责做viewModel和视图的绑定操作
        roleSwitchButton.addTarget(self, action: #selector(roleAction(_:)), for: .touchUpInside)
        heightQualityButton.addTarget(self, action: #selector(qulityAction(_:)), for: .touchUpInside)
        mediumQualityButton.addTarget(self, action: #selector(qulityAction(_:)), for: .touchUpInside)
        enterRoomButton.addTarget(self, action: #selector(enterRoomAction(_:)), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.endEditing(true)
    }
}

extension TRTCCreateVoiceRoomRootView: UITextFieldDelegate {
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

extension TRTCCreateVoiceRoomRootView {
    
    @objc
    func roleAction(_ sender: UISwitch) {
        viewModel.needRequest = sender.isOn
    }
   
    @objc
    func qulityAction(_ sender: UIButton) {
        heightQualityButton.isSelected = sender == heightQualityButton
        mediumQualityButton.isSelected = sender == mediumQualityButton
        lowQualityButton.isSelected = sender == lowQualityButton
        var quality = VoiceRoomToneQuality.music
        if mediumQualityButton.isSelected {
            quality = .defaultQuality
        }
        if lowQualityButton.isSelected {
            quality = .speech
        }
        viewModel.toneQuality = quality
    }
    
    @objc
    func enterRoomAction(_ sender: UIButton) {
        // 获取输入
        guard let roomNameString = roomNameInputTextFiled.text, let userNameString = userNameTextFiled.text else {
            return
        }
        guard roomNameString != "" && userNameString != ""  else {
            makeToast("昵称或用户名为空")
            return
        }
        viewModel.roomName = roomNameString
        viewModel.userName = userNameString
        viewModel.createRoom()
    }
}

extension TRTCCreateVoiceRoomRootView: TRTCCreateVoiceRoomViewResponder {
    func push(viewController: UIViewController) {
        rootViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - 自动化约束
extension TRTCCreateVoiceRoomRootView {
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
    
    func activateConstraintsOfButtonItem() {
        
        roleButtonStack.snp.makeConstraints { (make) in
            make.top.equalTo(inputContainer.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-36)
            make.height.equalTo(24)
        }
        roleLabel.sizeToFit()
        [roleSwitchButton].forEach { (button) in
            button.snp.makeConstraints { (make) in
                make.height.equalTo(24)
                make.width.equalTo(60)
            }
        }
        toneQualityStack.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-36)
            make.top.equalTo(roleButtonStack.snp.bottom).offset(25)
            make.height.equalTo(24)
        }
        toneQualityLabel.sizeToFit()
        [heightQualityButton, mediumQualityButton].forEach { (button) in
            button.snp.makeConstraints { (make) in
                make.height.equalTo(24)
                make.width.equalTo(70)
            }
        }
    }
    
    func activateConstraintsOfEnterRoom() {
        enterRoomButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(48)
            make.top.equalTo(toneQualityStack.snp.bottom).offset(30)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(enterRoomButton.snp.bottom).offset(30)
            make.left.right.equalTo(enterRoomButton)
        }
    }
}
