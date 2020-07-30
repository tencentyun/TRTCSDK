//
//  TRTCMeetingMemberController+UI.swift
//  TRTCScenesDemo
//
//  Created by lijie on 2020/5/7.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
import Toast_Swift

extension TRTCMeetingMemberViewController {
    func setupUI() {
        title = "成员列表"
        
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.colors = [UIColor(rgb: 0x13294b).cgColor,UIColor(rgb: 0x050c17).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(memberCollectionView)
        memberCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view)
            make.top.equalTo(topPadding + 45)
            make.height.equalTo(view).offset(-150)
        }
        
        setupControls()
        reloadData()
        
        NotificationCenter.default.rx.notification(refreshUserListNotification).subscribe(onNext: { [weak self] notification in
            guard let self = self else {return}
            if notification.object != nil {
                self.attendeeList = notification.object as! [MeetingAttendeeModel]
            }
            self.reloadData()
        }).disposed(by: disposeBag)
    }
    
    func setupControls() {
        // 全体静音按钮
        muteAllAudioButton.setTitle("全体静音", for: .normal)
        muteAllAudioButton.backgroundColor = UIColor(hex: "#E84B40")
        muteAllAudioButton.layer.cornerRadius = 4.0
        view.addSubview(muteAllAudioButton)
        muteAllAudioButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(-130)
            make.bottom.equalTo(view).offset(-20)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        muteAllAudioButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            self.delegate?.onMuteAllAudio(mute: true)
            self.view.hideToast()
            self.view.makeToast("全体静音")
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        // 解除全体静音按钮
        unmuteAllAudioButton.setTitle("解除全体静音", for: .normal)
        unmuteAllAudioButton.backgroundColor = .buttonBackColor
        unmuteAllAudioButton.layer.cornerRadius = 4.0
        view.addSubview(unmuteAllAudioButton)
        unmuteAllAudioButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(0)
            make.bottom.equalTo(view).offset(-20)
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
        unmuteAllAudioButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            self.delegate?.onMuteAllAudio(mute: false)
            self.view.hideToast()
            self.view.makeToast("解除全体静音")
        }).disposed(by: disposeBag)
        
        
        // 全体禁画按钮
        muteAllVideoButton.setTitle("全体禁画", for: .normal)
        muteAllVideoButton.backgroundColor = UIColor(hex: "#E84B40")
        muteAllVideoButton.layer.cornerRadius = 4.0
        view.addSubview(muteAllVideoButton)
        muteAllVideoButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(130)
            make.bottom.equalTo(view).offset(-20)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        muteAllVideoButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            self.delegate?.onMuteAllVideo(mute: true)
            self.view.hideToast()
            self.view.makeToast("全体禁画")
        }).disposed(by: disposeBag)
        
    }
}
