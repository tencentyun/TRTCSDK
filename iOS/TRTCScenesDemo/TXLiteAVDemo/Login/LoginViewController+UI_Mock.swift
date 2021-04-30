//
//  TRTCLoginViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/16/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Material
import Toast_Swift

extension TRTCLoginViewController {
    
    /// 绘制UI
    func setupUI() {
        ToastManager.shared.position = .center
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        
        view.addSubview(phoneTip)
        phoneTip.snp.makeConstraints { (make) in
            make.leading.equalTo(32)
            make.top.equalTo(trtcTitle.snp.bottom).offset(60)
            make.trailing.equalTo(-32)
            make.height.equalTo(30)
        }
        
        //UserID
        let (phoneNumber, numberSignal) = getTextObservable(placeholder: V2Localize("V2.Live.LinkMicNew.enteruserid"))
        phoneNumber.keyboardType = .numberPad
        phoneNumber.delegate = self
        view.addSubview(phoneNumber)
        phoneNumber.snp.makeConstraints { (make) in
            make.top.equalTo(phoneTip.snp.bottom).offset(2)
            make.leading.equalTo(32)
            make.trailing.equalTo(-32)
            make.height.equalTo(34)
        }
        
        numberSignal.subscribe(onNext: { (text) in
            print("phoneNumber:\(String(describing: text))")
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        numberSignal.bind(to: ProfileManager.shared.phone).disposed(by: disposeBag)
        
        let phoneValid = numberSignal
            .map {
                $0.count > 0
        }.share(replay: 1)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumber.snp.bottom).offset(28)
            make.height.equalTo(46)
            make.leading.trailing.equalTo(phoneNumber)
        }
        
        loginButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self, weak phoneNumber] in
            guard let self = self else {return}
            self.loading.startAnimating()
            
            ProfileManager.shared.login(success: {
                if ProfileManager.shared.curUserModel?.name.count == 0 {
                    self.showProfileVC()
                } else {
                    self.loading.stopAnimating()
                    self.view.makeToast(V2Localize("V2.Live.LinkMicNew.loginsuccess"))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        //show main vc
                        AppUtils.shared.showMainController()
                    }
                }
            }, failed: { err in
                self.loading.stopAnimating()
                self.view.makeToast(err)
            })
            guard let phoneNumber = phoneNumber else {return}
            phoneNumber.resignFirstResponder()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        phoneValid.bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        phoneValid.subscribe(onNext: { [weak button=loginButton](enabled) in
            button?.alpha = enabled ? 1 : 0.8
            button?.isEnabled = enabled
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        view.addSubview(bottomTip)
        bottomTip.snp.makeConstraints { (make) in
            make.bottomMargin.equalTo(view).offset(-12)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(30)
        }
        
        view.addSubview(versionTip)
        versionTip.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomTip.snp.top).offset(-2)
            make.height.equalTo(12)
            make.leading.trailing.equalTo(view)
        }
        
        /// auto login
        if ProfileManager.shared.autoLogin(success: { [weak self] in
            guard let self = self else {return}
            if ProfileManager.shared.curUserModel?.name.count == 0 {
                self.showProfileVC()
            } else {
                self.loading.stopAnimating()
                self.view.makeToast(V2Localize("V2.Live.LinkMicNew.loginsuccess"))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    //show main vc
                    AppUtils.shared.showMainController()
                }
            }
            }, failed: { [weak self] (err) in
                guard let self = self else {return}
                self.loading.stopAnimating()
                self.view.makeToast(err)
        }) {
            loading.startAnimating()
            phoneNumber.text = ProfileManager.shared.curUserModel?.phone ?? ""
        }
        
        // tap to resign
        let tap = UITapGestureRecognizer.init()
        tap.rx.event.subscribe(onNext: { [weak phoneNumber] _ in
            guard let phoneNumber = phoneNumber else {return}
            phoneNumber.resignFirstResponder()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        view.addGestureRecognizer(tap)
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
        edit.placeholderLabel.font = Font.boldSystemFont(ofSize: 14)
        view.addSubview(edit)
        edit.placeholder = placeholder
        edit.placeholderAnimation = .hidden
        return (edit, edit.rx.text.orEmpty)
    }
    
    func showProfileVC() {
        let profileVC = ProfileViewController.init()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension TRTCLoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCount = 11
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= maxCount
    }
}
