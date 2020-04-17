//
//  AudioSelectContactViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/8/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift

class AudioSelectContactViewController: UIViewController {
    var selectedFinished: (([UserModel])->Void)? = nil
    
    let disposebag = DisposeBag()
    let searchBar = UISearchBar()
    
    /// 是否展示搜索结果
    var shouldShowSearchResult: Bool = false {
        didSet {
            if oldValue != shouldShowSearchResult {
                if !shouldShowSearchResult {
                    getHistroy()
                }
                selectTable.reloadData()
            }
        }
    }
    
    /// 已选择的用户列表
    var selectedUsers: [UserModel] = [] {
        didSet {//更新UI
            userPanel.snp.remakeConstraints { (make) in
                make.leading.equalTo(view).offset(kUserPanelLeftSpacing)
                make.trailing.equalTo(view)
                make.top.equalTo(searchBar.snp.bottom).offset(6)
                make.height.equalTo(userPanelHeight)
            }
            userPanel.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.userPanel.reloadSections(IndexSet(integer: 0))
            }){ _ in
                
            }
            selectTable.reloadData()
            doneBtn.alpha = selectedUsers.count == 0 ? 0.5 : 1
        }
    }
    
    /// 完成按钮
    lazy var doneBtn: UIButton = {
       let done = UIButton()
        done.backgroundColor = .appTint
        done.setTitle("完成", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.alpha = 0.5
        done.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        done.layer.cornerRadius = 4.0
        done.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
        guard let self = self else {return}
        if self.selectedUsers.count == 0 {
            return
        }
        var users:[UserModel] = []
        for user in self.selectedUsers {
            users.append(user.copy())
        }
        if let finish = self.selectedFinished {
            self.navigationController?.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [users] in
                finish(users)
            })
        }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        return done
    }()
    
    /// 搜索结果model
    var searchResult: UserModel? = nil
    
    /// 历史搜索列表
    var historyList: [UserModel] = []
    
    /// 选择列表
    lazy var selectTable: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = .appBackGround
        table.register(AudioSelectUserTableViewCell.classForCoder(),
                       forCellReuseIdentifier: "AudioSelectUserTableViewCell")
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    let kUserBorder: CGFloat = 44.0
    let kUserSpacing: CGFloat = 2
    let kUserPanelLeftSpacing: CGFloat = 28
    
    /// 已选用户面板
    lazy var userPanel: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let panel = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width),
                                    collectionViewLayout: layout)
        panel.backgroundColor = .appBackGround
        panel.register(AudioSelectUserCollectionViewCell.classForCoder(),
                       forCellWithReuseIdentifier: "AudioSelectUserCollectionViewCell")
        if #available(iOS 10.0, *) {
            panel.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        
        panel.showsVerticalScrollIndicator = false
        panel.showsHorizontalScrollIndicator = false
        panel.contentMode = .scaleToFill
        panel.backgroundColor = .appBackGround
        panel.isScrollEnabled = false
        view.addSubview(panel)
        panel.delegate = self
        panel.dataSource = self
        return panel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
