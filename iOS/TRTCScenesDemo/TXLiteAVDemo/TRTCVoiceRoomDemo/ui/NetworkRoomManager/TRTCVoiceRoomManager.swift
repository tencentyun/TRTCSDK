//
//  TRTCVoiceRoomManager.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import Alamofire

let voiceRoomBaseUrl = "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest"

//roomModel
@objc class VoiceRoomCommonModel: NSObject, Codable {
    @objc var errorCode: Int32 = -1
    @objc var errorMessage: String = ""
}

@objc class VoiceRoomInfoModel: NSObject, Codable {
    @objc var appId: String = ""
    @objc var type: String = ""
    @objc var roomId: String = ""
    @objc var id: UInt32 = 0
    @objc var createTime: String = ""
}

//roomListModel
@objc class VoiceRoomInfoResultModel: NSObject, Codable {
    @objc var errorCode: Int32 = -1
    @objc var errorMessage: String = ""
    @objc var data: [VoiceRoomInfoModel] = []
}

@objc public class TRTCVoiceRoomManager: NSObject {
    @objc public static let shared = TRTCVoiceRoomManager()
    private override init() {}
    
    @objc public func createRoom(sdkAppID: Int32, roomID: String,
                                 success: @escaping ()->Void,
                                 failed: @escaping (_ code: Int32,  _ error: String)-> Void) {
        let params = ["method":"createRoom", "appId":String(sdkAppID),
                      "type":"voiceRoom", "roomId":roomID] as [String : Any]
        Alamofire.request(voiceRoomBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(VoiceRoomCommonModel.self, from: respData) else {
                    failed(-1, "VoiceRoomCommonModel decode failed")
                    fatalError("VoiceRoomCommonModel decode failed")
                }
                if result.errorCode == 0 {
                    success()
                } else {
                    failed(result.errorCode, result.errorMessage)
                }
            } else {
                failed(-1,"return null")
            }
        }
    }
    
    @objc public func destroyRoom(sdkAppID: Int32, roomID: String,
    success: @escaping ()->Void,
    failed: @escaping (_ code: Int32,  _ error: String)-> Void) {
        let params = ["method":"destroyRoom", "appId":String(sdkAppID),
                      "type":"voiceRoom", "roomId":roomID] as [String : Any]
        Alamofire.request(voiceRoomBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(VoiceRoomCommonModel.self, from: respData) else {
                    failed(-1, "VoiceRoomCommonModel decode failed")
                    fatalError("VoiceRoomCommonModel decode failed")
                }
                if result.errorCode == 0 {
                    success()
                } else {
                    failed(result.errorCode, result.errorMessage)
                }
            } else {
                failed(-1,"return null")
            }
        }
    }
    
    @objc public func getRoomList(sdkAppID: Int32,
                                  success: @escaping (_ roomIDs:[String])->Void,
                                  failed: @escaping (_ code: Int32,  _ error: String)-> Void) {
        let params = ["method":"getRoomList", "appId":String(sdkAppID),
                      "type":"voiceRoom"] as [String : Any]
        Alamofire.request(voiceRoomBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(VoiceRoomInfoResultModel.self, from: respData) else {
                    failed(-1, "VoiceRoomInfoResultModel decode failed")
                    fatalError("VoiceRoomInfoResultModel decode failed")
                }
                if result.errorCode == 0 {
                    var roomIDs: [String] = []
                    for roomInfo in result.data {
                        roomIDs.append(roomInfo.roomId)
                    }
                    success(roomIDs)
                } else {
                    failed(result.errorCode, result.errorMessage)
                }
            } else {
                failed(-1,"return null")
            }
        }
    }
}

