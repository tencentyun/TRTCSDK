//
//  TRTCCreateVoiceRoomViewController.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/4.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCCreateVoiceRoomViewController: UIViewController {
    // 依赖管理者
    let dependencyContainer: TRTCVoiceRoomEnteryControl
    
    init(dependencyContainer: TRTCVoiceRoomEnteryControl) {
        self.dependencyContainer = dependencyContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    public var screenShot : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .controllerTitle
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "navigationbar_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        backBtn.sizeToFit()
        let backItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    override func loadView() {
        let voiceRoomModel = dependencyContainer.makeCreateVoiceRoomViewModel()
        voiceRoomModel.screenShot = screenShot
        let rootView = TRTCCreateVoiceRoomRootView.init(viewModel: voiceRoomModel)
        voiceRoomModel.viewResponder = rootView
        rootView.rootViewController = self
        view = rootView
        
    }
    
    /// 取消
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
}

private extension String {
    static let controllerTitle = TRTCLocalize("Demo.TRTC.VoiceRoom.createvoicechatroom")
}

