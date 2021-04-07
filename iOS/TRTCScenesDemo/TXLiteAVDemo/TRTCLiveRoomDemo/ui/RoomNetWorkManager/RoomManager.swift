//
//  RoomManager.swift
//  trtcScenesDemo
//
//  Created by 刘智民 on 2020/3/2.
//  Copyright © 2020 xcoderliu. All rights reserved.
//
import UIKit
import Alamofire

let roomBaseUrl = "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest"

//roomModel
@objc class roomCommonModel: NSObject, Codable {
    @objc var errorCode: Int32 = -1
    @objc var errorMessage: String = ""
}

@objc class roomInfoModel: NSObject, Codable {
    @objc var appId: String = ""
    @objc var type: String = ""
    @objc var roomId: String = ""
    @objc var id: UInt32 = 0
    @objc var createTime: String = ""
}

//roomListModel
@objc class roomInfoResultModel: NSObject, Codable {
    @objc var errorCode: Int32 = -1
    @objc var errorMessage: String = ""
    @objc var data: [roomInfoModel] = []
}

@objc public class RoomManager: NSObject {
    @objc public static let shared = RoomManager()
    private override init() {}
    
    @objc public func createRoom(sdkAppID: Int32, roomID: String,
                                 success: @escaping ()->Void,
                                 failed: @escaping (_ code: Int32,  _ error: String)-> Void) {
        let params = ["method":"createRoom", "appId":String(sdkAppID),
                      "type":"liveRoom", "roomId":roomID] as [String : Any]
        Alamofire.request(roomBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(roomCommonModel.self, from: respData) else {
                    failed(-1, "roomCommonModel decode failed")
                    fatalError("roomCommonModel decode failed")
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
                      "type":"liveRoom", "roomId":roomID] as [String : Any]
        Alamofire.request(roomBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(roomCommonModel.self, from: respData) else {
                    failed(-1, "roomCommonModel decode failed")
                    fatalError("roomCommonModel decode failed")
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
                      "type":"liveRoom"] as [String : Any]
        Alamofire.request(roomBaseUrl, method: .post, parameters: params).responseJSON {(data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(roomInfoResultModel.self, from: respData) else {
                    failed(-1, "roomInfoResultModel decode failed")
                    fatalError("roomInfoResultModel decode failed")
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
