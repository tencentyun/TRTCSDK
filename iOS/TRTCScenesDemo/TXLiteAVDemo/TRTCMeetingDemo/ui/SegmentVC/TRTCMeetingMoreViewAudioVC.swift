//
//  TRTCMeetingMoreViewAudioVC.swift
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/15.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

class TRTCMeetingMoreViewAudioVC: UIViewController {
    // 采集音量
    lazy var captureVolumeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 30, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .captureVolumeText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    // 播放音量
    lazy var playVolumeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 70, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .playingVolumeText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    // 音量提示
    lazy var volumePromptLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 110, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .volumePromptText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    // 音频录制
    lazy var audioRecordLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 150, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .audioRecordingText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    // 采集音量Slider
    lazy var captureVolumeSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: UIScreen.main.bounds.size.width / 3.0 * 1.2, y: 37, width: UIScreen.main.bounds.size.width / 2.0, height: 10))
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 100
        slider.addTarget(self, action: #selector(captureVolumeSliderChanged), for: .valueChanged)
        return slider
    }()
    
    // 采集音量函数
    @objc func captureVolumeSliderChanged(slider: UISlider) {
        print(String.captureVolumeText, Int(slider.value))
        TRTCMeeting.sharedInstance().setAudioCaptureVolume(Int(slider.value))
    }
    
    // 播放音量Slider
    lazy var playVolumeSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: UIScreen.main.bounds.size.width / 3.0 * 1.2, y: 77, width: UIScreen.main.bounds.size.width / 2.0, height: 10))
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 100
        slider.addTarget(self, action: #selector(playVolumeSliderChanged), for: .valueChanged)
        return slider
    }()
    
    // 播放音量函数
    @objc func playVolumeSliderChanged(slider: UISlider) {
        print(String.playingVolumeText, Int(slider.value))
        TRTCMeeting.sharedInstance().setAudioPlayoutVolume(Int(slider.value))
    }
    
    // 音量提示switch
    lazy var volumePromptSwitch: UISwitch = {
        let sw = UISwitch(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0 * 5.4, y: 108, width: 80, height: 50))
        sw.onTintColor = .blue
        sw.isOn = true
        sw.addTarget(self, action: #selector(volumePromptChanged), for: .valueChanged)
        return sw
    }()
    
    @objc func volumePromptChanged(sw: UISwitch) {
        print(String.volumePromptSwitchText, sw.isOn)
        TRTCMeeting.sharedInstance().enableAudioEvaluation(sw.isOn)
    }
    
    // 停止录制button
    lazy var recordButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0 * 5, y: 150, width: 80, height: 25))
        button.layer.cornerRadius = 25*0.5
        button.layer.masksToBounds = true
        
        button.setTitle(.startRecordingText, for: .normal)
        button.tag = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = .buttonBackColor
        button.titleLabel?.textColor = .black
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        
        return button
    }()
    
    @objc func stopRecording(button: UIButton) {

        let file_path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last?.appending("/test-record.aac")
        
        if button.tag == 0 {
            button.tag = 1
            button.setTitle(.endRecordingText, for: .normal)
            print(String.startRecordingText)

            let params = TRTCAudioRecordingParams()
            params.filePath = file_path!
            TRTCMeeting.sharedInstance().startFileDumping(params)
        } else {
            button.tag = 0
            button.setTitle(.startRecordingText, for: .normal)
            print(String.endRecordingText)
            TRTCMeeting.sharedInstance().stopFileDumping()
            
            // 提示录制的文件路径
            let message = String.recordingSavePathText + file_path!
            let alertVC = UIAlertController(title: .promptText, message: message, preferredStyle: UIAlertController.Style.alert)
            let okView = UIAlertAction(title: .confirmText, style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            alertVC.addAction(okView)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(playVolumeLabel)
        self.view.addSubview(captureVolumeLabel)
        self.view.addSubview(volumePromptLabel)
        self.view.addSubview(audioRecordLabel)
        
        self.view.addSubview(captureVolumeSlider)
        self.view.addSubview(playVolumeSlider)
        self.view.addSubview(volumePromptSwitch)
        self.view.addSubview(recordButton)
    }

}

/// MARK: - internationalization string
fileprivate extension String {
    static let captureVolumeText = TRTCLocalize("Demo.TRTC.Meeting.capturevolume")
    static let playingVolumeText = TRTCLocalize("Demo.TRTC.Meeting.playingvolume")
    static let volumePromptText = TRTCLocalize("Demo.TRTC.Meeting.volumeprompt")
    static let audioRecordingText = TRTCLocalize("Demo.TRTC.Meeting.audiorecording")
    static let volumePromptSwitchText = TRTCLocalize("Demo.TRTC.Meeting.volumepromptswitch")
    static let startRecordingText = TRTCLocalize("Demo.TRTC.Meeting.startrecording")
    static let endRecordingText = TRTCLocalize("Demo.TRTC.Meeting.endrecording")
    static let recordingSavePathText = TRTCLocalize("Demo.TRTC.Meeting.recordingsavepath")
    static let promptText = TRTCLocalize("Demo.TRTC.LiveRoom.prompt")
    static let confirmText = TRTCLocalize("Demo.TRTC.LiveRoom.confirm")    
}
