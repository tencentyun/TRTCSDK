//
//  TRTCMeetingMoreViewVideoVC.swift
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/15.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

class TRTCMeetingBitrateTable : NSObject {
    var resolutionName: String = ""
    var resolution: Int = 0
    var defaultBitrate: Float = 0
    var minBitrate: Float = 0
    var maxBitrate: Float = 0
    var stepBitrate: Float = 0
    
    init(resolutionName: String, resolution: Int, defaultBitrate: Float, minBitrate: Float, maxBitrate: Float, stepBitrate: Float) {
        super.init()
        
        self.resolutionName = resolutionName
        self.resolution = resolution
        self.defaultBitrate = defaultBitrate
        self.minBitrate = minBitrate
        self.maxBitrate = maxBitrate
        self.stepBitrate = stepBitrate
    }
}

class TRTCMeetingMoreViewVideoVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let TAG_RESOLUTION = 100
    let TAG_FPS = 200
    
    var resolutionTextField = UITextField()
    var fpsTextField = UITextField()
    
    
    lazy var resolutionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 30, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .resolutionText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    lazy var frameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 80, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .framerateText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    lazy var bitrateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 130, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .bitrateText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    lazy var mirrorLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 180, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .localmirrorText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    lazy var mirrorSwich: UISwitch = {
        let swich = UISwitch(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0*5.5, y: 177, width: 50, height: 23))
        swich.onTintColor = .blue
        swich.isOn = true // 默认是开启镜像的
        swich.addTarget(self, action: #selector(mirrorSwitchChanged), for: .valueChanged)
        return swich
    }()

    // 帧率
    let frameArray = ["15", "20"]
    
    // 创建码表, resolution 的值详见：TRTCVideoResolution
    let bitrateTable = [TRTCMeetingBitrateTable](
        arrayLiteral:
        TRTCMeetingBitrateTable(resolutionName: "180 * 320", resolution:TRTCVideoResolution._320_180.rawValue, defaultBitrate: 350, minBitrate: 80, maxBitrate: 350, stepBitrate: 10),
        TRTCMeetingBitrateTable(resolutionName: "270 * 480", resolution: TRTCVideoResolution._480_270.rawValue, defaultBitrate: 500, minBitrate: 200, maxBitrate: 1000, stepBitrate: 10),
        TRTCMeetingBitrateTable(resolutionName: "360 * 640", resolution: TRTCVideoResolution._640_360.rawValue, defaultBitrate: 600, minBitrate: 200, maxBitrate: 1000, stepBitrate: 10),
        TRTCMeetingBitrateTable(resolutionName: "540 * 960", resolution: TRTCVideoResolution._960_540.rawValue, defaultBitrate: 900, minBitrate: 400, maxBitrate: 1600, stepBitrate: 50),
        TRTCMeetingBitrateTable(resolutionName: "720 * 1280", resolution: TRTCVideoResolution._1280_720.rawValue, defaultBitrate: 1250, minBitrate: 500, maxBitrate: 2000, stepBitrate: 50)
    )
    var bitrateIndex = 3 // 默认540 * 960
    
    // 码率SliderView
    lazy var bitrateSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0*2.5 - 8, y: 136, width: UIScreen.main.bounds.size.width / 2.0*0.8, height: 10))
        
        let item = bitrateTable[bitrateIndex]
        slider.minimumValue = item.minBitrate / item.stepBitrate
        slider.maximumValue = item.maxBitrate / item.stepBitrate
        slider.value = item.defaultBitrate / item.stepBitrate
        slider.addTarget(self, action: #selector(bitrateSliderChanged), for: .valueChanged)
        
        return slider
    }()
    
    // 码率显示label
    lazy var bitrateShowLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0*5.5, y: 130, width: 100, height: 20))
        label.textAlignment = NSTextAlignment.left
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = String(Int(bitrateTable[bitrateIndex].defaultBitrate)) + "kbps"
        return label
    }()
    
    // 本地镜像开关切换函数
    @objc func mirrorSwitchChanged(_ sw: UISwitch) {
        if (sw.isOn) {
            TRTCMeeting.sharedInstance().setLocalViewMirror(TRTCLocalVideoMirrorType.enable);
        } else {
            TRTCMeeting.sharedInstance().setLocalViewMirror(TRTCLocalVideoMirrorType.disable);
        }
    }
    
    
    // 滑动条拖动函数
    @objc func bitrateSliderChanged(_ slider: UISlider) {
        updateBitrate(bitrate: Int(slider.value * bitrateTable[bitrateIndex].stepBitrate))
    }

    
    // 创建分辨率和帧率pickView以及textField
    @objc func setPickViewAndTextField() {
        
        // 分辨率：
        
        // 创建UITextField
        resolutionTextField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width / 3.0, y: 30, width: UIScreen.main.bounds.size.width / 3.0, height: 25))
        
        // 创建UIPickerView
        let pickerViewResolution = UIPickerView()
        
        // 设置pickerView的代理以及dataSource
        pickerViewResolution.delegate = self
        pickerViewResolution.dataSource = self
        
        resolutionTextField.tintColor = .clear
        // 设置UITextField的tag值
        resolutionTextField.tag = TAG_RESOLUTION
        pickerViewResolution.tag = TAG_RESOLUTION
        
        // 将textField视图转换成pickerView
        resolutionTextField.inputView = pickerViewResolution
        
        // 设置textField预设内容
        resolutionTextField.text = bitrateTable[bitrateIndex].resolutionName
        
        resolutionTextField.backgroundColor = .clear
        resolutionTextField.textAlignment = .left
        
        resolutionTextField.textColor = .black
        
        self.view.addSubview(resolutionTextField)
        
        // 增加触控事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        
        // 帧率：
        
        // 创建UITextField
        fpsTextField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width / 3.0, y: 80, width: UIScreen.main.bounds.size.width / 3.0, height: 25))
        
        // 创建UIPickerView
        let pickerViewFrame = UIPickerView()
        
        // 设置pickerView的代理以及dataSource
        pickerViewFrame.delegate = self
        pickerViewFrame.dataSource = self
        
        fpsTextField.tintColor = .clear
        // 设置UITextField的tag值
        fpsTextField.tag = TAG_FPS
        pickerViewFrame.tag = TAG_FPS
        
        // 将textField视图转换成pickerView
        fpsTextField.inputView = pickerViewFrame
        
        // 设置textField预设内容
        fpsTextField.text = frameArray[0]
        
        fpsTextField.backgroundColor = .clear
        fpsTextField.textAlignment = .left
        
        fpsTextField.textColor = .black
        
        self.view.addSubview(fpsTextField)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bitrateShowLabel)
        view.addSubview(resolutionLabel)
        view.addSubview(frameLabel)
        view.addSubview(bitrateLabel)
        view.addSubview(mirrorLabel)
        view.addSubview(mirrorSwich)
        view.addSubview(bitrateSlider)
        
        self.setPickViewAndTextField()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == TAG_RESOLUTION {
            return bitrateTable.count
        }
        else if pickerView.tag == TAG_FPS {
            return frameArray.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == TAG_RESOLUTION {
            return bitrateTable[row].resolutionName
        }
        else if pickerView.tag == TAG_FPS {
            return frameArray[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == TAG_RESOLUTION {
            print(String.resolutionSelectedText)
            updateResolution(index: row)
            
        } else if pickerView.tag == TAG_FPS {
            print(String.framerateSelectedText)
            updateFps(index: row)
        }
    }
    
    func updateResolution(index: Int) {
        bitrateIndex = index
        
        let item = bitrateTable[bitrateIndex]
        
        // 更新分辨率
        resolutionTextField.text = item.resolutionName
        let resolution = TRTCVideoResolution(rawValue: item.resolution)!
        TRTCMeeting.sharedInstance().setVideoResolution(resolution)
        
        // 设置码率进度条 && 更新码率
        bitrateSlider.minimumValue = item.minBitrate / item.stepBitrate
        bitrateSlider.maximumValue = item.maxBitrate / item.stepBitrate
        bitrateSlider.value = item.defaultBitrate / item.stepBitrate
        updateBitrate(bitrate: Int(item.defaultBitrate))
    }
    
    func updateFps(index: Int) {
        fpsTextField.text = frameArray[index]
        TRTCMeeting.sharedInstance().setVideoFps(Int32(frameArray[index])!)
    }
    
    func updateBitrate(bitrate: Int) {
        bitrateShowLabel.text = String(bitrate) + "kbps"
        TRTCMeeting.sharedInstance().setVideoBitrate(Int32(bitrate))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //点击空白处隐藏编辑状态
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let resolutionText = TRTCLocalize("Demo.TRTC.Meeting.resolution")
    static let framerateText = TRTCLocalize("Demo.TRTC.Meeting.framerate")
    static let bitrateText = TRTCLocalize("Demo.TRTC.Meeting.bitrate")
    static let localmirrorText = TRTCLocalize("Demo.TRTC.Meeting.localmirror")
    static let resolutionSelectedText = TRTCLocalize("Demo.TRTC.Meeting.resolutionselected")
    static let framerateSelectedText = TRTCLocalize("Demo.TRTC.Meeting.framerateselected")
}
