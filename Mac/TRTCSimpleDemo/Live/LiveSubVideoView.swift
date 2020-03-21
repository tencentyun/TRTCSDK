//
//  LiveSubVideoView.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

import Cocoa

let TRTC_DEMO_MIC_ICON = [
    NSControl.StateValue.on : NSImage.init(named: "rtc_mic_off"),
    NSControl.StateValue.off : NSImage.init(named: "rtc_mic_on"),
]

let TRTC_DEMO_CAMERA_ICON = [
    NSControl.StateValue.on : NSImage.init(named: "rtc_camera_off"),
    NSControl.StateValue.off : NSImage.init(named: "rtc_camera_on"),
]

let TRTC_DEMO_LINKMIC_ICON = [
    NSControl.StateValue.on : NSImage.init(named: "link_mic_on"),
    NSControl.StateValue.off : NSImage.init(named: "link_mic_off")
]

let TRTC_DEMO_SCREENSHARE_ICON = [
    NSControl.StateValue.on : NSImage.init(named: "screen_share_on"),
    NSControl.StateValue.off : NSImage.init(named: "screen_share_off")
]

/**
 * RTC视频互动直播房间内的小视频画面
 *
 * 用于管理小视频画面上的“关闭声音”、“关闭视频”按钮的状态
 */
class LiveSubVideoView: NSView {
    
    @IBOutlet var muteAudioButton: NSButton!
    @IBOutlet var muteVideoButton: NSButton!
    @IBOutlet var videoView: NSView!
    
    @IBInspectable var viewTag: Int = 0
    
    private lazy var roomManager = LiveRoomManager.sharedInstance
    
    var userId: String = ""
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 1).setFill()
        dirtyRect.fill()
    }
    
    func reset() {
        userId = ""
        setAudioButtonState(state: NSControl.StateValue.off)
        setVideoButtonState(state: NSControl.StateValue.off)
    }
    
    func reset(with userId: String) {
        self.userId = userId
        if roomManager.isAudioMuted(forUser: userId) {
            setAudioButtonState(state: NSControl.StateValue.on)
        } else {
            setAudioButtonState(state: NSControl.StateValue.off)
        }
        if roomManager.isVideoMuted(forUser: userId) {
            setVideoButtonState(state: NSControl.StateValue.on)
        } else {
            setVideoButtonState(state: NSControl.StateValue.off)
        }
    }
    
    func muteVideo(_ mute: Bool) {
        setVideoButtonState(state: mute ? NSControl.StateValue.on : NSControl.StateValue.off)
        roomManager.muteRemoteVideo(forUser: userId, muted: mute)
    }
    
    func muteAudio(_ mute: Bool) {
        setAudioButtonState(state: mute ? NSControl.StateValue.on : NSControl.StateValue.off)
        roomManager.muteRemoteAudio(forUser: userId, muted: mute)
    }
    
    func setVideoButtonState(state: NSControl.StateValue) {
        muteVideoButton.state = state
        muteVideoButton.image = TRTC_DEMO_CAMERA_ICON[muteVideoButton.state]!
    }
    
    func setAudioButtonState(state: NSControl.StateValue) {
        muteAudioButton.state = state
        muteAudioButton.image = TRTC_DEMO_MIC_ICON[muteAudioButton.state]!
    }
    
}
