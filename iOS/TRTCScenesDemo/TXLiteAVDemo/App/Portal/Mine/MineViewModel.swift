//
//  MineViewModel.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

enum MineListType {
    case privacy
    case disclaimer
    case about
}

class MineViewModel: NSObject {
    public var user: LoginResultModel? {
        get {
            return ProfileManager.shared.curUserModel
        }
    }
    public lazy var tableDataSource: [MineTableViewCellModel] = {
        var res: [MineTableViewCellModel] = []
        tableTypeSource.forEach { (type) in
            switch type {
            case .privacy:
                let model = MineTableViewCellModel(title: .privacyTitleText, image: UIImage(named: "main_mine_privacy"), type: type)
                res.append(model)
            case .disclaimer:
                let model = MineTableViewCellModel(title: .disclaimerTitleText, image: UIImage(named: "main_mine_disclaimer"), type: type)
                res.append(model)
            case .about:
                let model = MineTableViewCellModel(title: .aboutTitleText, image: UIImage(named: "main_mine_about"), type: type)
                res.append(model)
            }
        }
        return res
    }()
    public lazy var tableTypeSource: [MineListType] = {
        return [.privacy, .disclaimer, .about]
    }()
    
    public func validate(userName: String) -> Bool {
        let reg = "^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reg)
        return predicate.evaluate(with: userName)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let privacyTitleText = AppPortalLocalize("Demo.TRTC.Portal.privacy")
    static let disclaimerTitleText = AppPortalLocalize("Demo.TRTC.Portal.disclaimer")
    static let aboutTitleText = AppPortalLocalize("Demo.TRTC.Portal.Mine.about")
}
