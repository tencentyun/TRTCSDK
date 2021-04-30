//
//  TRTCCreateVoiceRoomRootView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

class TRTCCreateVoiceRoomRootView: UIView {
    
    private let bgView : UIView = {
        let bg = UIView(frame: .zero)
        bg.backgroundColor = .black
        bg.alpha = 0.6
        return bg
    }()
    
    private let contentView : UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    } ()
    
    private let titleLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        label.textColor = .black
        label.textAlignment = .left
        label.text = .titleText
        return label
    }()
    
    private lazy var textView : UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.text = LocalizeReplaceXX(.defaultCreateText, viewModel.userName)
        textView.textColor = .black
        textView.layer.cornerRadius = 20
        textView.backgroundColor = UIColor(hex: "F4F5F9")
        return textView
    }()
    
    private let createBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(.createText, for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
        btn.setBackgroundImage((UIColor(hex: "006EFF") ?? UIColor.blue).trans2Image(), for: .normal)
        btn.isEnabled = true
        btn.clipsToBounds = true
        return btn
    }()
    
    private func createScreenShot() {
        guard let view = viewModel.screenShot else {
            return
        }
        insertSubview(view, belowSubview: bgView)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private let viewModel: TRTCCreateVoiceRoomViewModel
    
    weak var rootViewController: UIViewController?
    
    init(viewModel: TRTCCreateVoiceRoomViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        super.init(frame: frame)
        bindInteraction()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChange(noti:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func keyboardFrameChange(noti : Notification) {
        guard let info = noti.userInfo else {
            return
        }
        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey], value is CGRect else {
            return
        }
        let rect = value as! CGRect
        transform = CGAffineTransform(translationX: 0, y: -ScreenHeight+rect.minY)
    }
    
    var isViewReady = false
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        createScreenShot()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        createBtn.layer.cornerRadius = createBtn.frame.height*0.5
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
    }
    
    private func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        contentView.addSubview(createBtn)
    }
    
    private func activateConstraints() {
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
        textView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
            make.height.equalTo(176)
        }
        createBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(textView.snp_bottom).offset(32)
            make.height.equalTo(52)
            make.width.equalTo(160)
            make.bottom.equalToSuperview().offset(-54)
        }
    }
    
    private func bindInteraction() {
        createBtn.addTarget(self, action: #selector(createBtnClick), for: .touchUpInside)
        textView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        if contentView.frame.contains(point) {
            textView.endEdit()
        }
        else {
            textView.resignFirstResponder()
            rootViewController?.navigationController?.popViewController(animated: false)
        }
    }
    
    @objc
    func createBtnClick() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let `self` = self else { return }
                self.enterRoom()
            }
        }
        else {
            enterRoom()
        }
    }
    
    private func enterRoom() {
        if textView.text == String.placeholderTitleText {
            viewModel.roomName = LocalizeReplaceXX(.defaultCreateText, viewModel.userName)
        }
        else {
            viewModel.roomName = textView.text
        }
        viewModel.createRoom()
    }
}


extension TRTCCreateVoiceRoomRootView : UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.beganEdit()
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEdit()
        createBtn.isEnabled = textView.text != String.placeholderTitleText
    }
    func textViewDidChange(_ textView: UITextView) {
        createBtn.isEnabled = textView.text != ""
    }
}

extension UITextView {
    func beganEdit() {
        if self.text == String.placeholderTitleText {
            self.text = ""
            self.textColor = .black
        }
    }
    func endEdit() {
        if self.text == "" {
            self.text = .placeholderTitleText
            self.textColor = UIColor(hex: "BBBBBB")
        }
        self.resignFirstResponder()
    }
}
extension UIView {
    /// 切部分圆角
    ///
    /// - Parameters:
    ///   - rect: 传入View的Rect
    ///   - byRoundingCorners: 裁剪位置
    ///   - cornerRadii: 裁剪半径
    public func roundedRect(rect:CGRect, byRoundingCorners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: byRoundingCorners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 切圆角
    ///
    /// - Parameter rect: 传入view的Rect
    public func roundedCircle(rect: CGRect) {
        roundedRect(rect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.size.width / 2, height: bounds.size.height / 2))
    }
}

extension TRTCCreateVoiceRoomRootView : TRTCCreateVoiceRoomViewResponder {
    func push(viewController: UIViewController) {
        rootViewController?.navigationController?.pushViewController(viewController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else { return }
            guard let vc = self.rootViewController else { return }
            guard let vcs = vc.navigationController?.viewControllers else {
                return
            }
            var controllers = vcs
            if let index = controllers.firstIndex(of: vc) {
                controllers.remove(at: index)
                vc.navigationController?.viewControllers = controllers
            }
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = TRTCLocalize("Demo.TRTC.VoiceRoom.roomsubject")
    static let placeholderTitleText = TRTCLocalize("Demo.TRTC.VoiceRoom.enterroomsubject")
    static let createText = TRTCLocalize("Demo.TRTC.VoiceRoom.starttalking")
    static let defaultCreateText = TRTCLocalize("Demo.TRTC.VoiceRoom.xxxsroom")
}
