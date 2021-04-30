//
//  ChatSalonListViewController.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/12.
//Copyright © 2020 tencent. All rights reserved.
//
import UIKit

/// 语聊房列表页
public class TRTCChatSalonListViewController: UIViewController {
    // 依赖管理者
    let dependencyContainer: TRTCChatSalonEnteryControl
    var viewModel: TRTCChatSalonListViewModel?
        
    init(dependencyContainer: TRTCChatSalonEnteryControl) {
        self.dependencyContainer = dependencyContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    // MARK: - life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = .controllerTitle
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "navigationbar_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        backBtn.sizeToFit()
        let backItem = UIBarButtonItem(customView: backBtn)
        backItem.tintColor = .black
        self.navigationItem.leftBarButtonItem = backItem
        
        let helpBtn = UIButton(type: .custom)
        helpBtn.setImage(UIImage(named: "help_small"), for: .normal)
        helpBtn.addTarget(self, action: #selector(connectWeb), for: .touchUpInside)
        helpBtn.sizeToFit()
        let rightItem = UIBarButtonItem(customView: helpBtn)
        rightItem.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightItem
    }
        
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.getRoomList() // 调整房间列表的刷新时机
        guard let rootView = self.view as? TRTCChatSalonListRootView else {
            return
        }
        rootView.updateBaseCollectionOffsetY()
    }


    public override func loadView() {
        // Reload view in this function
        let viewModel = dependencyContainer.makeChatSalonListViewModel()
        let rootView = TRTCChatSalonListRootView.init(viewModel: viewModel)
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
    @objc func connectWeb() {
        if let url = URL(string: "https://cloud.tencent.com/document/product/647/35428") {
            UIApplication.shared.openURL(url)
        }
    }
}

private extension String {
    static let controllerTitle = TRTCLocalize("Demo.TRTC.Salon.chatsalon")
}
