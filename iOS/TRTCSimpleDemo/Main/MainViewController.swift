//
//  MainViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TRTC示例教程"
    }
    
    @IBAction func onRTCClicked(_ sender: UIButton) {
        presentStoryboard("RTC")
    }
    
    @IBAction func onLiveClicked(_ sender: UIButton) {
        presentStoryboard("Live")
    }
    
    @IBAction func onScreenClicked(_ sender: UIButton) {
        jumpToScreenVC()
    }
    
    func presentStoryboard(_ name: String) {
        let storyboard = UIStoryboard.init(name: name, bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func jumpToScreenVC() {
        let screenVC = ScreenViewController()
        
        self.navigationController?.pushViewController(screenVC, animated: true)
    }
    
}
