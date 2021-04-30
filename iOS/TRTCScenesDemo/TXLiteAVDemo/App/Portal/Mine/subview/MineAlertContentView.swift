//
//  MineAlertContentView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

// MARK: - User ID Edit
class MineUserIdEditView: MineAlertContentView {
    
    override init(frame: CGRect = .zero, viewModel: MineViewModel) {
        super.init(viewModel: viewModel)
        titleLabel.text = .changeUseridText
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChange(noti:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func keyboardFrameChange(noti : Notification) {
        guard let info = noti.userInfo else {
            return
        }
        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey], value is CGRect else {
            return
        }
        let rect = value as! CGRect
        transform = CGAffineTransform(translationX: 0, y: -ScreenHeight+rect.minY)
    }
    
    lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(.confirmText, for: .normal)
        btn.isEnabled = false
        return btn
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor(hex: "333333")
        textField.backgroundColor = UIColor(hex: "F4F5F9")
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        leftView.backgroundColor = .clear
        leftView.isUserInteractionEnabled = false
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        let attr = NSAttributedString(string: .useridPlaceholderText, attributes:
                                        [NSAttributedString.Key.font : UIFont(name: "PingFangSC-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                         NSAttributedString.Key.foregroundColor : UIColor(hex: "BBBBBB") ?? .lightGray,
        ])
        textField.attributedPlaceholder = attr
        textField.layer.cornerRadius = 52/2
        return textField
    }()
    
    lazy var alertTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.textColor = enableColor
        label.text = .useridDescText
        return label
    }()
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(confirmBtn)
        contentView.addSubview(textField)
        contentView.addSubview(alertTitleLabel)
    }
    override func activateConstraints() {
        super.activateConstraints()
        confirmBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
        }
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(confirmBtn)
            make.height.equalTo(52)
        }
        alertTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(textField)
            make.top.equalTo(textField.snp_bottom).offset(10)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20-kDeviceSafeBottomHeight)
        }
    }
    override func bindInteraction() {
        super.bindInteraction()
        confirmBtn.addTarget(self, action: #selector(confirmBtnClick(btn:)), for: .touchUpInside)
        textField.delegate = self
    }
    
    @objc func confirmBtnClick(btn: UIButton) {
        textField.resignFirstResponder()
        guard let name = textField.text, name.count > 0 else {
            return
        }
        ProfileManager.shared.curUserModel?.name = name
        ProfileManager.shared.synchronizUserInfo()
        dismiss()
        ProfileManager.shared.setNickName(name: name) {
            debugPrint("sms set profile success")
        } failed: { (err) in
            debugPrint("sms set profile err:\(err)")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        textField.resignFirstResponder()
        if !contentView.frame.contains(point) {
            dismiss()
        }
        else {
            checkConfirmBtnState()
        }
    }
    
    var canUse = false
    let enableColor = UIColor(hex: "BBBBBB") ?? UIColor.gray
    let disableColor = UIColor(hex: "FA585E") ?? UIColor.red
}

extension MineUserIdEditView : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkConfirmBtnState()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCount = 20
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        let res = count <= maxCount
        if res {
            let newText = (textFieldText as NSString).replacingCharacters(in: range, with: string)
            checkAlertTitleLState(newText)
            
            checkConfirmBtnState(count)
        }
        return res
    }
    
    func checkAlertTitleLState(_ text: String = "") {
        if text == "" {
            if let str = textField.text {
                canUse = viewModel.validate(userName: str)
                alertTitleLabel.textColor = canUse ? enableColor : disableColor
            }
            else {
                canUse = false
                alertTitleLabel.textColor = disableColor
            }
        }
        else {
            canUse = viewModel.validate(userName: text)
            alertTitleLabel.textColor = canUse ? enableColor : disableColor
        }
    }
    
    func checkConfirmBtnState(_ count: Int = -1) {
        var ctt = textField.text?.count ?? 0
        if count > -1 {
            ctt = count
        }
        confirmBtn.isEnabled = canUse && ctt > 0
    }
}

class MineAlertContentView: UIView {
    lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        return label
    }()
    
    let viewModel: MineViewModel
    
    public var willDismiss: (()->())?
    public var didDismiss: (()->())?
    
    public init(frame: CGRect = .zero, viewModel: MineViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    public func show() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    public func dismiss() {
        if let action = willDismiss {
            action()
        }
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        } completion: { (finish) in
            if let action = self.didDismiss {
                action()
            }
            self.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        if !contentView.frame.contains(point) {
            dismiss()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
    }
    func activateConstraints() {
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(32)
        }
    }
    func bindInteraction() {
        
    }
}
/// MARK: - internationalization string
fileprivate extension String {
    static let changeUseridText = AppPortalLocalize("Demo.TRTC.Portal.changenickname")
    static let confirmText = AppPortalLocalize("Demo.TRTC.Portal.confirm")
    static let useridPlaceholderText = AppPortalLocalize("Demo.TRTC.Portal.enterusername")
    static let useridDescText = AppPortalLocalize("Demo.TRTC.Portal.limit20count")
}
