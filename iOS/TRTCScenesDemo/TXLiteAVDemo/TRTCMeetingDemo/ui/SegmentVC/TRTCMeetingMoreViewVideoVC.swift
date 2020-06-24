//
//  TRTCMeetingMoreViewVideoVC.swift
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/15.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

class TRTCMeetingMoreViewVideoVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let TAG_RESOLUTION = 100
    let TAG_FPS = 200
    
    var resolutionTextField = UITextField()
    var fpsTextField = UITextField()
    
    
    lazy var resolutionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 30, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = "分辨率"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    lazy var frameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 80, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = "帧率"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    lazy var bitrateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 130, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = "码率"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    lazy var mirrorLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 180, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = "本地镜像"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    lazy var mirrorSwich: UISwitch = {
        let swich = UISwitch(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0*5.5, y: 177, width: 50, height: 23))
        swich.onTintColor = .blue
        swich.addTarget(self, action: #selector(mirrorSwitchChanged), for: .valueChanged)
        return swich
    }()

    // 码率和帧率
    var bitrateArray = [Int]()
    let frameArray = ["15", "20"]
    
    // 创建分辨率, resolutionIndexArray 为对应分辨率的索引，详见定义：TRTCVideoResolution
    let resolutionIndexArray = [Int](arrayLiteral: 3, 104, 56, 7, 108, 62, 110, 112, 114)
    let resolutionArray = ["160 * 160", "180 * 320", "240 * 320", "480 * 480", "360 * 640", "480 * 640", "540 * 960", "720 * 1280", "1080 * 1920"]
    
    
    // 码率SliderView
    lazy var bitrateSlider: UISlider = {
        // 设定值400～1600
        for index in 0...24 {
            bitrateArray.append(index * 50 + 400)
        }
        
        let slider = UISlider(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0*2.5, y: 136, width: UIScreen.main.bounds.size.width / 2.0*0.8, height: 10))
        slider.minimumValue = 400
        slider.maximumValue = 1600
        slider.value = 1000
        slider.addTarget(self, action: #selector(bitrateSliderChanged), for: .valueChanged)
        
        return slider
    }()
    
    // 码率显示label
    lazy var bitrateShowLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0*5.5, y: 130, width: 100, height: 20))
        label.textAlignment = NSTextAlignment.left
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    // 本地镜像开关切换函数
    @objc func mirrorSwitchChanged(_ sw: UISwitch) {
        if (sw.isOn) {
            let mirrorOpen = TRTCLocalVideoMirrorType(rawValue: 2)!
            TRTCMeeting.sharedInstance().setLocalViewMirror(mirrorOpen);
        } else {
            let mirrorClose = TRTCLocalVideoMirrorType(rawValue: 1)!
            TRTCMeeting.sharedInstance().setLocalViewMirror(mirrorClose);
        }
    }
    
    
    // 滑动条拖动函数
    @objc func bitrateSliderChanged(_ slider: UISlider) {
        let value = bitrateArray[(Int(slider.value) - 400) / 50]
        bitrateShowLabel.text = String(value) + "kbps"
        
        TRTCMeeting.sharedInstance().setVideoBitrate(Int32(value))
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
        resolutionTextField.text = resolutionArray[6]
        
        resolutionTextField.backgroundColor = .clear
        resolutionTextField.textAlignment = .left
        
        resolutionTextField.textColor = .white
        
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
        
        fpsTextField.textColor = .white
        
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
        if pickerView.tag == 100 {
            return resolutionArray.count
        }
        else if pickerView.tag == 200 {
            return frameArray.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 100 {
            return resolutionArray[row]
        }
        else if pickerView.tag == 200 {
            return frameArray[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == TAG_RESOLUTION {
            let myTextField = self.view.viewWithTag(100) as? UITextField
            myTextField?.text = resolutionArray[row]
            print("分辨率选择完毕")
            
            let resolution = TRTCVideoResolution(rawValue: resolutionIndexArray[row])!
            TRTCMeeting.sharedInstance().setVideoResolution(resolution)
            
        } else if pickerView.tag == TAG_FPS {
            let myTextField = self.view.viewWithTag(200) as? UITextField
            myTextField?.text = frameArray[row]
            print("帧率选择完毕")
            

            TRTCMeeting.sharedInstance().setVideoFps(Int32((myTextField?.text)!)!)
            print(Int32((myTextField?.text)!)!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bitrateShowLabel.text = String(bitrateArray[(Int(bitrateSlider.value) - 400) / 50]) + "kbps"
    }
    
    //点击空白处隐藏编辑状态
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}
