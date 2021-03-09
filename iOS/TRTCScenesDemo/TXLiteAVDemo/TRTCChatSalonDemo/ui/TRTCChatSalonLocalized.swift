//
//  TRTCChatSalonLocalized.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2021/3/3.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation


class ChatSalonLocalized {
    static func getLocalizedString(key: String, comment: String = "") -> String {
        return .localized(of: key, comment: comment)
    }
}

private let bundleID = Bundle.main.bundleIdentifier ?? ""
private let bundle = Bundle.init(identifier: bundleID)
private let tableName = "TRTCChatSalonDemoLocalized"

private extension String {
    static func localized(of key: String, comment: String = "") -> String {
            guard let bundle = bundle else {
                return key
            }
            return NSLocalizedString(key,
                                     tableName: tableName,
                                     bundle: bundle,
                                     comment: comment)
        }
}
