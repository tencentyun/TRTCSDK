//
//  AudioCallViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/14/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Toast_Swift

extension AudioCallViewController {
    func setupUI() {
        
        view.addSubview(OnInviteePanel)
        OnInviteePanel.addSubview(OninviteeStackView)
        OninviteeStackView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(OnInviteePanel)
            make.top.equalTo(OnInviteePanel.snp.bottom)
        }
        
        ToastManager.shared.position = .bottom
        var topPadding: CGFloat = 0
        
        gradientLayer.colors = colors.compactMap{ $0 }
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        view.addSubview(userCollectionView)
        userCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.height.equalTo(view.snp.width)
            make.top.equalTo(topPadding + 62)
        }
        setupControls()
        autoSetUIByState()
        accept.isHidden = (curSponsor == nil)
    }
    
    func setupControls() {
        if hangup.superview == nil {
            hangup.setImage(UIImage(named: "ic_hangup"), for: .normal)
            view.addSubview(hangup)
            hangup.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                 TRTCAudioCall.shared.hangup()
                self.disMiss()
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        }
        
        
        if accept.superview == nil {
            accept.setImage(UIImage(named: "ic_dialing"), for: .normal)
            view.addSubview(accept)
            accept.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                TRTCAudioCall.shared.accept()
                var curUser = AudioCallUserModel()
                if let name = ProfileManager.shared.curUserModel?.name,
                    let avatar = ProfileManager.shared.curUserModel?.avatar,
                    let userId = ProfileManager.shared.curUserModel?.userId {
                    curUser.name = name
                    curUser.avatarUrl = avatar
                    curUser.userId = userId
                    curUser.isEnter = true
                }
                self.enterUser(user: curUser)
                self.curState = .calling
                self.accept.isHidden = true
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        }
        
        if mute.superview == nil {
            mute.setImage(UIImage(named: "ic_mute"), for: .normal)
            view.addSubview(mute)
            mute.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                TRTCAudioCall.shared.isMicMute = !TRTCAudioCall.shared.isMicMute
                self.mute.setImage(UIImage(named: TRTCAudioCall.shared.isMicMute ? "ic_mute_on" : "ic_mute"), for: .normal)
                self.view.makeToast(TRTCAudioCall.shared.isMicMute ? "开启静音" : "关闭静音")
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
            mute.isHidden = true
            mute.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-120)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(50)
                make.height.equalTo(50)
            }
        }
        
        if handsfree.superview == nil {
            handsfree.setImage(UIImage(named: "ic_handsfree_on"), for: .normal)
            view.addSubview(handsfree)
            handsfree.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                TRTCAudioCall.shared.isHandsFreeOn = !TRTCAudioCall.shared.isHandsFreeOn
                self.handsfree.setImage(UIImage(named: TRTCAudioCall.shared.isHandsFreeOn ? "ic_handsfree_on" : "ic_handsfree"), for: .normal)
                self.view.makeToast(TRTCAudioCall.shared.isHandsFreeOn ? "开启免提" : "关闭免提")
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
            handsfree.isHidden = true
            handsfree.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(120)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(50)
                make.height.equalTo(50)
            }
        }
        
        if callTimeLabel.superview == nil {
            callTimeLabel.textColor = .white
            callTimeLabel.backgroundColor = .clear
            callTimeLabel.text = "00:00"
            callTimeLabel.textAlignment = .center
            view.addSubview(callTimeLabel)
            callTimeLabel.isHidden = true
            callTimeLabel.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(view)
                make.bottom.equalTo(hangup.snp.top).offset(-10)
                make.height.equalTo(30)
            }
        }
    }
    
    func autoSetUIByState() {
        switch curState {
        case .dailing:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(80)
                make.height.equalTo(80)
            }
            break
        case .onInvitee:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-80)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(80)
                make.height.equalTo(80)
            }
            
            accept.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(80)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(80)
                make.height.equalTo(80)
            }
            break
        case .calling:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
            startGCDTimer()
            break
        }
        
        if curState == .calling {
            mute.isHidden = false
            handsfree.isHidden = false
            callTimeLabel.isHidden = false
            mute.alpha = 0.0
            handsfree.alpha = 0.0
            callTimeLabel.alpha = 0.0
        }
        
        let shouldHideOnInviteePanel = (OnInviteePanelList.count == 0 || (self.curState != .onInvitee))
        
        OnInviteePanel.snp.remakeConstraints { (make) in
            make.bottom.equalTo(self.hangup.snp.top).offset(-100)
            make.width.equalTo(max(44, 44 * OnInviteePanelList.count + 2 * max(0, OnInviteePanelList.count - 1)))
            make.centerX.equalTo(view)
            make.height.equalTo(80)
        }
        
        OninviteeStackView.safelyRemoveArrangedSubviews()
        if OnInviteePanelList.count > 0,!shouldHideOnInviteePanel {
            for user in OnInviteePanelList {
                let userAvatar = UIImageView()
                userAvatar.sd_setImage(with: URL(string: user.avatarUrl), completed: nil)
                userAvatar.widthAnchor.constraint(equalToConstant: 44).isActive = true
                OninviteeStackView.addArrangedSubview(userAvatar)
            }
        }
        
        OnInviteePanel.isHidden = shouldHideOnInviteePanel
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            if self.curState == .calling {
                self.mute.alpha = 1.0
                self.handsfree.alpha = 1.0
                self.callTimeLabel.alpha = 1.0
            }
        }) { _ in
            
        }
    }
    
    // Dispatch Timer
     func startGCDTimer() {
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        // 设定时间源的触发事件
        codeTimer.setEventHandler(handler: { [weak self] in
            guard let self = self else {return}
            self.callingTime += 1
            // UI 更新
            DispatchQueue.main.async {
                var mins: UInt32 = 0
                var seconds: UInt32 = 0
                mins = self.callingTime / 60
                seconds = self.callingTime % 60
                self.callTimeLabel.text = String(format: "%02d:", mins) + String(format: "%02d", seconds)
            }
        })
        
        // 判断是否取消，如果已经取消了，调用resume()方法时就会崩溃！！！
        if codeTimer.isCancelled {
            return
        }
        // 启动时间源
        codeTimer.resume()
    }
}
