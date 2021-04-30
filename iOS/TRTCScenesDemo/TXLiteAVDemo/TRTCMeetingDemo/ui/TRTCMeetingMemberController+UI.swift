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
    
    @objc func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        title = .memberListText
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor.black,
             NSAttributedString.Key.font : UIFont(name: "PingFangSC-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18)
            ]
        navigationController?.navigationBar.barTintColor = UIColor(hex: "F4F5F9")
        navigationController?.navigationBar.isTranslucent = false
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "meeting_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let item = UIBarButtonItem(customView: backBtn)
        item.tintColor = .black
        navigationItem.leftBarButtonItem = item
        
        view.backgroundColor = UIColor(hex: "F4F5F9")
        
        view.addSubview(memberCollectionView)
        memberCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view)
            make.top.equalTo(10)
            make.height.equalTo(view).offset(0)
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
        
        let green = UIColor(hex: "29CC85")
        let blue = UIColor(hex: "006EFF")
        
        // 全体静音按钮
        muteAllAudioButton.setTitle(.mutedAllText, for: .normal)
        muteAllAudioButton.backgroundColor = .white
        muteAllAudioButton.layer.borderWidth = 1
        muteAllAudioButton.layer.borderColor = green?.cgColor
        muteAllAudioButton.setTitleColor(green, for: .normal)
        muteAllAudioButton.layer.cornerRadius = 20
        muteAllAudioButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        muteAllAudioButton.titleLabel?.adjustsFontSizeToFitWidth = true
        muteAllAudioButton.titleLabel?.minimumScaleFactor = 0.5
        view.addSubview(muteAllAudioButton)
        muteAllAudioButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(-130)
            make.bottom.equalTo(view).offset(-20-kDeviceSafeBottomHeight)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        muteAllAudioButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            self.delegate?.onMuteAllAudio(mute: true)
            self.view.hideToast()
            self.view.makeToast(.mutedAllText)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        // 解除全体静音按钮
        unmuteAllAudioButton.setTitle(.unmutedAllText, for: .normal)
        unmuteAllAudioButton.backgroundColor = green
        unmuteAllAudioButton.setTitleColor(.white, for: .normal)
        unmuteAllAudioButton.layer.cornerRadius = 20
        unmuteAllAudioButton.titleLabel?.adjustsFontSizeToFitWidth = true
        unmuteAllAudioButton.titleLabel?.minimumScaleFactor = 0.5
        unmuteAllAudioButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        view.addSubview(unmuteAllAudioButton)
        unmuteAllAudioButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(0)
            make.bottom.equalTo(muteAllAudioButton)
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
        unmuteAllAudioButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            self.delegate?.onMuteAllAudio(mute: false)
            self.view.hideToast()
            self.view.makeToast(.unmutedAllText)
        }).disposed(by: disposeBag)
        
        
        // 全体禁画按钮
        muteAllVideoButton.setTitle(.forbidAllPicText, for: .normal)
        muteAllVideoButton.setTitleColor(blue, for: .normal)
        muteAllVideoButton.backgroundColor = .white
        muteAllVideoButton.layer.cornerRadius = 20
        muteAllVideoButton.layer.borderColor = blue?.cgColor
        muteAllVideoButton.layer.borderWidth = 1
        muteAllVideoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        muteAllVideoButton.titleLabel?.minimumScaleFactor = 0.5
        muteAllVideoButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        view.addSubview(muteAllVideoButton)
        muteAllVideoButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(130)
            make.bottom.equalTo(muteAllAudioButton)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        muteAllVideoButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            
            self.delegate?.onMuteAllVideo(mute: true)
            self.view.hideToast()
            self.view.makeToast(.forbidAllPicText)
        }).disposed(by: disposeBag)
        
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let memberListText = TRTCLocalize("Demo.TRTC.Meeting.memberlist")
    static let mutedAllText = TRTCLocalize("Demo.TRTC.Meeting.mutedall")
    static let unmutedAllText = TRTCLocalize("Demo.TRTC.Meeting.unmutedall")
    static let forbidAllPicText = TRTCLocalize("Demo.TRTC.Meeting.forbidallpic")
}
