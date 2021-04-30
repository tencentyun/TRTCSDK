//
//  TRTCMeetingNewViewController.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/22/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
import RxSwift

class TRTCMeetingNewViewController: UIViewController {

    let disposeBag = DisposeBag()
    let roomInput = UITextField()
    let openCameraSwitch = UISwitch()
    let openMicSwitch = UISwitch()
    
    let speechQualityButton = UIButton()
    let defaultQualityButton = UIButton()
    let musicQualityButton = UIButton()
    var audioQuality: Int = 1
    
    let distinctVideoButton = UIButton()
    let fluencyVideoButton = UIButton()
    var videoQuality: Int = 1 // 1 流畅, 2清晰
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
