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
    let dependencyContainer: TRTCVoiceRoomDependencyContainer
    
    init(dependencyContainer: TRTCVoiceRoomDependencyContainer) {
        self.dependencyContainer = dependencyContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .controllerTitle
        let backItem = UIBarButtonItem.init(image: UIImage.init(named: "navigationbar_back"), style: .plain, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    override func loadView() {
        let voiceRoomModel = dependencyContainer.makeCreateVoiceRoomViewModel()
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
    static let controllerTitle = "创建语音聊天室"
}

