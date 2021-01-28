//
//  MainViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TRTC示例教程"
    }
    
    @IBAction func onRTCClicked(_ sender: NSButton) {
        presentStoryboard("RTC")
    }
    
    @IBAction func onLiveClicked(_ sender: NSButton) {
        presentStoryboard("Live")
    }
    
    func presentStoryboard(_ name: String) {
        (NSApp.delegate as? AppDelegate)?.closeAllWindows()
        
        let storyboard = NSStoryboard.init(name: name, bundle: nil)
        guard let vc = storyboard.instantiateInitialController() else { return }
        (vc as? NSWindowController)?.showWindow(nil)
    }
    
}
