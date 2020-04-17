//
//  VideoSelectContactViewController+file.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/8/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
extension VideoSelectContactViewController {
    
    /// save recent contacts to file
    /// - Parameter users: userlist
    func saveRecentContacts(users: [UserModel]) {
        var recent = recentContacts
        for user in users {
            if recent.contains(user) {
                recent = recent.filter { // remove for update
                    $0.userId != user.userId
                }
            }
            recent.append(user)
        }
        do {
            let cacheData = try JSONEncoder().encode(recent)
            NSKeyedArchiver.archiveRootObject(cacheData, toFile: filePath)
        } catch {
            print("Save Failed")
        }
    }
    
    /// get recent userlist from file
    var recentContacts: [UserModel] {
        if let cacheData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data {
            do {
                let contacts = try JSONDecoder().decode([UserModel].self, from: cacheData)
                return contacts
            } catch {
                print("Retrieve Failed")
                return []
            }
        }
        return []
    }
    
    /// cache file locaiton
    var filePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory,
                               in: .userDomainMask).first! as NSURL
        return url.appendingPathComponent("recentContacts")!.path
    }
}
