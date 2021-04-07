//
//  loginProfileViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/2/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Material
import RxSwift
import RxCocoa
import Toast_Swift

extension ProfileViewController {
    func setupUI() {
        view.backgroundColor = .appBackGround
        
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
        
        view.addSubview(trtcTitle)
        trtcTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(32)
            make.top.equalTo(100)
            make.trailing.equalTo(-32)
            make.height.equalTo(30)
        }
        
        view.addSubview(avatarTip)
        avatarTip.snp.makeConstraints { (make) in
            make.leading.equalTo(32)
            make.top.equalTo(trtcTitle.snp.bottom).offset(40)
            make.trailing.equalTo(-32)
            make.height.equalTo(30)
        }
        
        view.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarTip)
            make.top.equalTo(avatarTip.snp.bottom).offset(4)
            make.width.height.equalTo(60)
        }
        
        view.addSubview(userNameTip)
        userNameTip.snp.makeConstraints { (make) in
            make.leading.equalTo(32)
            make.top.equalTo(avatarView.snp.bottom).offset(10)
            make.trailing.equalTo(-32)
            make.height.equalTo(30)
        }
        
        let (userName, nameSignal) = getTextObservable(placeholder: V2Localize("V2.Live.LoginMock.enterusername"))
        userName.delegate = self
        view.addSubview(userName)
        userName.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(userNameTip)
            make.top.equalTo(userNameTip.snp.bottom).offset(2)
            make.height.equalTo(30)
        }
        let _ = userName.becomeFirstResponder()
        
        let nameVailedSignal = nameSignal.map {
            $0.count >= 2
        }
        
        view.addSubview(signButton)
        signButton.snp.makeConstraints { (make) in
            make.top.equalTo(userName.snp.bottom).offset(28)
            make.height.equalTo(46)
            make.leading.trailing.equalTo(userName)
        }
        
        signButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.loading.startAnimating()
            guard let name = userName.text else {
                return
            }
            ProfileManager.shared.setNickName(name: name, success: {
                self.loading.stopAnimating()
                self.view.makeToast(V2Localize("V2.Live.LoginMock.registsuccess"))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    //show main vc
                    AppUtils.shared.showMainController()
                }
            }) { (err) in
                self.loading.stopAnimating()
                self.view.makeToast(err)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        nameVailedSignal.bind(to: signButton.rx.isEnabled).disposed(by: disposeBag)
        nameVailedSignal.subscribe(onNext: { [weak button=signButton](enabled) in
            button?.alpha = enabled ? 1 : 0.8
            button?.isEnabled = enabled
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    //MARK: - inner functionnd
    func getTextObservable( placeholder:String = "🐉" ) -> (TextField, ControlProperty<String>) {
        let edit = TextField()
        edit.textColor = .white
        edit.dividerThickness = 0.2
        edit.dividerNormalColor = .white
        edit.dividerActiveColor = .appTint
        edit.placeholderNormalColor = UIColor(red: 209.0 / 255.0, green: 209.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0)
        edit.placeholderActiveColor = UIColor(red: 209.0 / 255.0, green: 209.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0)
        edit.placeholderLabel.font = Font.boldSystemFont(ofSize: 13)
        view.addSubview(edit)
        edit.placeholder = placeholder
        edit.placeholderAnimation = .hidden
        return (edit, edit.rx.text.orEmpty)
    }
}

// set limit for username

extension ProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 20
    }
}
