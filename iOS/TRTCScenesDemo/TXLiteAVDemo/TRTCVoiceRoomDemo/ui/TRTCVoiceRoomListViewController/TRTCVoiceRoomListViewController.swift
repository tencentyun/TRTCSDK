//
//  VoiceRoomListViewController.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/12.
//Copyright © 2020 tencent. All rights reserved.
//
import UIKit


/// 语聊房列表页
public class TRTCVoiceRoomListViewController: UIViewController {
    // 依赖管理者
    let dependencyContainer: TRTCVoiceRoomEnteryControl
    
    var viewModel: TRTCVoiceRoomListViewModel?
        
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
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
    // MARK: - life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.getRoomList() // 调整房间列表的刷新时机
        guard let rootView = self.view as? TRTCVoiceRoomListRootView else {
            return
        }
        rootView.updateBaseCollectionOffsetY()
    }


    public override func loadView() {
        // Reload view in this function
        let viewModel = dependencyContainer.makeVoiceRoomListViewModel()
        let rootView = TRTCVoiceRoomListRootView.init(viewModel: viewModel)
        viewModel.viewResponder = rootView
        self.viewModel = viewModel
        rootView.rootViewController = self
        view = rootView
    }
    
    /// 取消
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 连接官方文档
    @objc public func connectWeb() {
        if let url = URL(string: "https://cloud.tencent.com/document/product/647/35428") {
            UIApplication.shared.openURL(url)
        }
    }
}

private extension String {
    static let controllerTitle = TRTCLocalize("Demo.TRTC.VoiceRoom.voicechatroom")
}
