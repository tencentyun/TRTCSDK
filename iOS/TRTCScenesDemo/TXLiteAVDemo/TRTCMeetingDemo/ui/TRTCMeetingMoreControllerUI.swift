//
//  TRTCMeetingMoreControllerUI.swift
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/14.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

final class TRTCMeetingMoreControllerUI: TRTCMeetingMoreViewController {
    
    let screenHeight = UIScreen.main.bounds.size.height
    let screenWidth = UIScreen.main.bounds.size.width
    
    //当前选中分页的视图下标
    var selectIndex = 0
    
    lazy var segView:CenterSegmentView = {
        let nameArray : [String] = [.videoText, .audioText, .shareText]
        let vcVideo = TRTCMeetingMoreViewVideoVC()
        let vcAudio = TRTCMeetingMoreViewAudioVC()
        let vcShare = TRTCMeetingMoreViewShareVC()
        
        let controllers = [vcVideo, vcAudio, vcShare]
        
        let view = CenterSegmentView(frame: CGRect(x: 0, y: 55, width: self.view.bounds.size.width, height: self.view.bounds.size.height), controllers: controllers, titleArray: nameArray, selectIndex: self.selectIndex, lineHeight: 2)
        
        return view
    }()
    
    override var controllerHeight: CGFloat{
        return screenHeight / 2.0
    }
        
    lazy var setLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 16, width: screenWidth, height: 30))
        label.textAlignment = NSTextAlignment.center
        label.text = .settingText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        view.addSubview(setLabel)
        view.addSubview(self.segView)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let videoText = TRTCLocalize("Demo.TRTC.Meeting.video")
    static let audioText = TRTCLocalize("Demo.TRTC.Meeting.audio")
    static let shareText = TRTCLocalize("Demo.TRTC.Meeting.share")
    static let settingText = TRTCLocalize("Demo.TRTC.Meeting.setting")
}
