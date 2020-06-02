//
//  Portal+Swift.swift
//  TXLiteAVDemo
//
//  Created by xcoderliu on 5/29/20.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import Toast_Swift

extension PortalViewController {
    @objc func setupToast() {
        ToastManager.shared.position = .bottom
    }
    
    @objc func makeToast(message: String) {
        view.makeToast(message)
    }
}
