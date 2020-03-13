//
//  LiveSubVideoView.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit

/**
 * RTC视频互动直播房间内的小视频画面
 *
 * 用于管理小视频画面上的“关闭声音”、“关闭视频”按钮的状态
 */
class LiveSubVideoView: UIView {
    
    @IBOutlet var muteAudioButton: UIButton!
    @IBOutlet var muteVideoButton: UIButton!
    @IBOutlet var videoMutedTipsView: UIView!
    
    private lazy var roomManager = LiveRoomManager.sharedInstance
    
    var userId: String = ""
    
    func reset() {
        userId = ""
        videoMutedTipsView.isHidden = true
        muteAudioButton.isSelected = false
        muteVideoButton.isSelected = false
    }
    
    func reset(with userId: String) {
        self.userId = userId
        muteAudioButton.isSelected = roomManager.isAudioMuted(forUser: userId)
        muteVideoButton.isSelected = roomManager.isVideoMuted(forUser: userId)
        videoMutedTipsView.isHidden = !muteVideoButton.isSelected
    }
    
    func muteVideo(_ mute: Bool) {
        muteVideoButton.isSelected = mute
        videoMutedTipsView.isHidden = !mute
        roomManager.muteRemoteVideo(forUser: userId, muted: mute)
    }
    
    func muteAudio(_ mute: Bool) {
        muteAudioButton.isSelected = mute
        roomManager.muteRemoteAudio(forUser: userId, muted: mute)
    }
}
