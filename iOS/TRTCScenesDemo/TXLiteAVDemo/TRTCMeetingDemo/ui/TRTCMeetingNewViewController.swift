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
    let userNameInput = UITextField()
    let openCameraSwitch = UISwitch()
    let openMicSwitch = UISwitch()
    
    let speechQualityButton = UIButton()
    let defaultQualityButton = UIButton()
    let musicQualityButton = UIButton()
    var audioQuality: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
