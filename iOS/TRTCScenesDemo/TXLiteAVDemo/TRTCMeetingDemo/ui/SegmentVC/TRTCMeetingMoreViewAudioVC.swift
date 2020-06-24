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
        label.text = "采集音量"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    // 播放音量
    lazy var playVolumeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 70, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = "播放音量"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    // 音量提示
    lazy var volumePromptLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 110, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = "音量提示"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    // 音频录制
    lazy var audioRecordLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 150, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = "音频录制"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
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
        print("采集音量", Int(slider.value))
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
        print("播放音量", Int(slider.value))
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
        print("音量提示切换: ", sw.isOn)
        TRTCMeeting.sharedInstance().enableAudioEvaluation(sw.isOn)
    }
    
    // 停止录制button
    lazy var recordButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0 * 5, y: 150, width: 80, height: 25))
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        
        button .setTitle("开始录制", for: .normal)
        button.tag = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = UIColor(hex: "0062E3")
        button.titleLabel?.textColor = .white
        button.contentHorizontalAlignment = .center
        button .addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        
        return button
    }()
    
    @objc func stopRecording(button: UIButton) {

        let file_path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last?.appending("/test-record.aac")
        
        if button.tag == 0 {
            button.tag = 1
            button .setTitle("结束录制", for: .normal)
            print("开始录制")

            let params = TRTCAudioRecordingParams()
            params.filePath = file_path!
            TRTCMeeting.sharedInstance().startFileDumping(params)
        } else {
            button.tag = 0
            button .setTitle("开始录制", for: .normal)
            print("结束录制")
            TRTCMeeting.sharedInstance().stopFileDumping()
            
            // 提示录制的文件路径
            let message = "录音保存路径：" + file_path!
            let alertVC = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertController.Style.alert)
            let okView = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: {
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
