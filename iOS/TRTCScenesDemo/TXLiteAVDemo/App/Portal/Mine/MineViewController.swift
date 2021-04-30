//
//  MineViewController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/6.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

@objc class MineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func loadView() {
        super.loadView()
        let viewModel = MineViewModel()
        let rootView = MineRootView(viewModel: viewModel)
        rootView.rootVC = self
        view = rootView
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
}
