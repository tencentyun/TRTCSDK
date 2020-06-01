//
//  VideoSelectContactViewController+search.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/13/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Material

extension VideoSelectContactViewController: UITextFieldDelegate, UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let input = searchBar.text, input.count > 0 {
            searchUser(input: input)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text?.count ?? 0 == 0 {
            //show recent table
            shouldShowSearchResult = false
        }
    }
    
    func searchUser(input: String)  {
        ProfileManager.shared.queryUserInfo(phone: input, success: { [weak self] (user) in
            guard let self = self else {return}
            self.saveRecentContacts(users: [user])
            self.searchResult = user
            self.shouldShowSearchResult = true
        }) { [weak self] (error) in
            guard let self = self else {return}
            self.searchResult = nil
            self.view.makeToast("查询失败")
        }
    }
}
