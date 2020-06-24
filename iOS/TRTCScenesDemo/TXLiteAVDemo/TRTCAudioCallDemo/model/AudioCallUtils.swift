//
//  AudioCallUtils.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/10/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit

@objc class AudioCallUtils: NSObject {
    @objc public static let shared = AudioCallUtils()
    private override init() {}
    
    @objc public func data2CallModel(data: Data) -> AudioCallModel? {
        do {
            let decoder = JSONDecoder()
            let model = try decoder.decode(AudioCallModel.self, from: data)
            return model
        } catch let err {
            debugPrint("call dataToModel failed: \(err)")
            return nil
        }
    }
    
    @objc public func callModel2Data(model: AudioCallModel) -> Data? {
        do {
            let encoder = JSONEncoder()
            let json = try encoder.encode(model)
            return json
        } catch let err {
            debugPrint("call callModel2Data failed: \(err)")
            return nil
        }
    }
    
    @objc public func randomStr(len: Int) -> String {
        let randomSrc = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(randomSrc.count)))
            ranStr.append(randomSrc[randomSrc.index(randomSrc.startIndex, offsetBy: index)])
        }
        return ranStr
    }
    
    @objc public func curUserId() -> String {
        if let user = V2TIMManager.sharedInstance()?.getLoginUser(), user.count > 0 {
            return user
        } else {
            return randomStr(len: 5)
        }
    }
    
    @objc public func generateCallID() -> String {
        return "\(TIMManager.sharedInstance()?.getVersion() ?? "0.0.1")-\(curUserId())-\(randomStr(len: 32))"
    }
    
    @objc public func generateRoomID() -> UInt32 {
       return UInt32.random(in: 0...(UInt32.max / 2 - 1))
    }
}
