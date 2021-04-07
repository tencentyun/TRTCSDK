//
//  TRTCChatSalonManager.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import Alamofire

let chatSalonBaseUrl = "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest"

//roomModel
@objc class ChatSalonCommonModel: NSObject, Codable {
    @objc var errorCode: Int32 = -1
    @objc var errorMessage: String = ""
}

@objc class ChatSalonInfoModel: NSObject, Codable {
    @objc var appId: String = ""
    @objc var type: String = ""
    @objc var roomId: String = ""
    @objc var id: UInt32 = 0
    @objc var createTime: String = ""
}

//roomListModel
@objc class ChatSalonInfoResultModel: NSObject, Codable {
    @objc var errorCode: Int32 = -1
    @objc var errorMessage: String = ""
    @objc var data: [ChatSalonInfoModel] = []
}

@objc public class TRTCChatSalonManager: NSObject {
    @objc public static let shared = TRTCChatSalonManager()
    private override init() {}
    
    @objc public func createRoom(sdkAppID: Int32, roomID: String,
                                 success: @escaping ()->Void,
                                 failed: @escaping (_ code: Int32,  _ error: String)-> Void) {
        let params = ["method":"createRoom", "appId":String(sdkAppID),
                      "type":"chatSalon", "roomId":roomID] as [String : Any]
        Alamofire.request(chatSalonBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(ChatSalonCommonModel.self, from: respData) else {
                    failed(-1, "ChatSalonCommonModel decode failed")
                    fatalError("ChatSalonCommonModel decode failed")
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
                      "type":"chatSalon", "roomId":roomID] as [String : Any]
        Alamofire.request(chatSalonBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(ChatSalonCommonModel.self, from: respData) else {
                    failed(-1, "ChatSalonCommonModel decode failed")
                    fatalError("ChatSalonCommonModel decode failed")
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
                      "type":"chatSalon"] as [String : Any]
        Alamofire.request(chatSalonBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(ChatSalonInfoResultModel.self, from: respData) else {
                    failed(-1, "ChatSalonInfoResultModel decode failed")
                    fatalError("ChatSalonInfoResultModel decode failed")
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

