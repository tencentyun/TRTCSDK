//
//  ViewController.swift
//  AudioSettingKitExample
//
//  Created by abyyxwang on 2020/5/26.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit
import TCAudioSettingKit

class ViewController: UIViewController {
    
    let showButton: UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("显示", for: .normal)
        button.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        button.frame = CGRect.init(origin: .zero, size: .init(width: 60, height: 40))
        return button
    }()
    
    let audioSettingView: AudioEffectSettingView = {
        let view = AudioEffectSettingView.init(type: .custom)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(showButton)
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        showButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        view.addSubview(audioSettingView)
    }
    
    @objc
    func showMenu() {
        audioSettingView.show()
    }

}

