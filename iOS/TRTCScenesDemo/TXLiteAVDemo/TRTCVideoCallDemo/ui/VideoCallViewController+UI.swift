//
//  VideoCallViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/17/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Toast_Swift

extension VideoCallViewController {
    func setupUI() {
        VideoCallViewController.renderViews = []
        ToastManager.shared.position = .bottom
        view.backgroundColor = .appBackGround
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        view.addSubview(userCollectionView)
        userCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view).offset(-132)
            make.top.equalTo(topPadding + 62)
        }
        
        view.addSubview(localPreView)
        localPreView.backgroundColor = .appBackGround
        localPreView.frame = UIApplication.shared.keyWindow?.bounds ?? CGRect.zero
        localPreView.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(pan:)))
        localPreView.addGestureRecognizer(tap)
        pan.require(toFail: tap)
        localPreView.addGestureRecognizer(pan)
        userCollectionView.isHidden = true
        
        setupSponsorPanel(topPadding: topPadding)
        setupControls()
        autoSetUIByState()
        accept.isHidden = (curSponsor == nil)
        AppUtils.shared.alertUserTips(self)
        TRTCVideoCall.shared.openCamera(frontCamera: true, view: localPreView)
    }
    
    func setupSponsorPanel(topPadding: CGFloat) {
        // sponsor
        if let sponsor = curSponsor {
            view.addSubview(sponsorPanel)
            sponsorPanel.snp.makeConstraints { (make) in
                make.leading.trailing.equalTo(view)
                make.top.equalTo(topPadding + 18)
                make.height.equalTo(60)
            }
            //发起者头像
            let userImage = UIImageView()
            sponsorPanel.addSubview(userImage)
            userImage.snp.makeConstraints { (make) in
                make.trailing.equalTo(sponsorPanel).offset(-18)
                make.top.equalTo(sponsorPanel)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
            userImage.sd_setImage(with: URL(string: sponsor.avatarUrl), completed: nil)
            
            //发起者名字
            let userName = UILabel()
            userName.textAlignment = .right
            userName.font = UIFont.boldSystemFont(ofSize: 30)
            userName.textColor = .white
            userName.text = sponsor.name
            sponsorPanel.addSubview(userName)
            userName.snp.makeConstraints { (make) in
                make.trailing.equalTo(userImage.snp.leading).offset(-6)
                make.height.equalTo(32)
                make.top.equalTo(sponsorPanel)
                make.leading.equalTo(sponsorPanel)
            }
            
            //提醒文字
            let invite = UILabel()
            invite.textAlignment = .right
            invite.font = UIFont.systemFont(ofSize: 13)
            invite.textColor = .white
            invite.text = "邀请你视频通话"
            sponsorPanel.addSubview(invite)
            invite.snp.makeConstraints { (make) in
                make.trailing.equalTo(userImage.snp.leading).offset(-6)
                make.height.equalTo(32)
                make.top.equalTo(userName.snp.bottom).offset(2)
                make.leading.equalTo(sponsorPanel)
            }
        }
    }
    
    func setupControls() {
        if hangup.superview == nil {
            hangup.setImage(UIImage(named: "ic_hangup"), for: .normal)
            view.addSubview(hangup)
            hangup.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                 TRTCVideoCall.shared.hangup()
                self.disMiss()
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        }
        
        
        if accept.superview == nil {
            accept.setImage(UIImage(named: "ic_dialing"), for: .normal)
            view.addSubview(accept)
            accept.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                TRTCVideoCall.shared.accept()
                var curUser = VideoCallUserModel()
                if let name = ProfileManager.shared.curUserModel?.name,
                    let avatar = ProfileManager.shared.curUserModel?.avatar,
                    let userId = ProfileManager.shared.curUserModel?.userId {
                    curUser.name = name
                    curUser.avatarUrl = avatar
                    curUser.userId = userId
                    curUser.isEnter = true
                    curUser.isVideoAvaliable = true
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
                make.width.equalTo(60)
                make.height.equalTo(60)
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
                make.width.equalTo(60)
                make.height.equalTo(60)
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
        userCollectionView.isHidden = ((curState != .calling) || (collectionCount <= 2))
        if let _ = curSponsor {
            sponsorPanel.isHidden = curState == .calling
        }
        
        switch curState {
        case .dailing:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
            break
        case .onInvitee:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-80)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
            
            accept.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(80)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(60)
                make.height.equalTo(60)
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
    
    @objc func handleTapGesture(tap: UIPanGestureRecognizer) {
        if collectionCount != 2 {
            return
        }
        
        if tap.view == localPreView {
            if localPreView.frame.size.width == kSmallVideoWidth {
                let userFirst = avaliableList.filter {
                    $0.userId != VideoCallUtils.shared.curUserId()
                }.first
                
                if let user = userFirst {
                    if let firstRender = VideoCallViewController.getRenderView(userId: user.userId) {
                        firstRender.removeFromSuperview()
                        self.view.insertSubview(firstRender, aboveSubview: localPreView)
                        UIView.animate(withDuration: 0.3) { [weak firstRender] in
                            self.localPreView.frame = self.view.frame
                            firstRender?.frame = CGRect(x: self.view.frame.size.width - kSmallVideoWidth - 18,
                            y: 20, width: kSmallVideoWidth, height: kSmallVideoWidth / 9.0 * 16.0)
                        }
                    }
                }
                
            }
        } else {
            if let smallView = tap.view {
                if smallView.frame.size.width == kSmallVideoWidth {
                    smallView.removeFromSuperview()
                    view.insertSubview(smallView, belowSubview: localPreView)
                    UIView.animate(withDuration: 0.3) { [weak smallView, weak self] in
                        guard let self = self else {return}
                        smallView?.frame = self.view.frame
                        self.localPreView.frame = CGRect(x: self.view.frame.size.width - kSmallVideoWidth - 18,
                       y: 20, width: kSmallVideoWidth, height: kSmallVideoWidth / 9.0 * 16.0)
                    }
                }
            }
        }
    }
    
    @objc func handlePanGesture(pan: UIPanGestureRecognizer) {
        if let smallView = pan.view {
            if smallView.frame.size.width == kSmallVideoWidth {
                if (pan.state == .began) {
                    
                } else if (pan.state == .changed) {
                    let translation = pan.translation(in: view)
                    let newCenterX = translation.x + (smallView.center.x)
                    let newCenterY = translation.y + (smallView.center.y)
                    if ( newCenterX < (smallView.bounds.width) / 2) ||
                        ( newCenterX > view.bounds.size.width - (smallView.bounds.width) / 2)  {
                        return
                    }
                    if ( newCenterY < (smallView.bounds.height) / 2) ||
                        (newCenterY > view.bounds.size.height - (smallView.bounds.height) / 2)  {
                        return
                    }
                    
                    UIView.animate(withDuration: 0.1) {
                        smallView.center = CGPoint(x: newCenterX, y: newCenterY)
                    }
                    
                    pan.setTranslation(.zero, in: view)
                } else if (pan.state == .ended || pan.state == .cancelled) {
                    
                }
            }
        }
    }
}
