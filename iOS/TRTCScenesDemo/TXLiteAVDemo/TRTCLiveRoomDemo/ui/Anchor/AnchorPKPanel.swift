//
//  AnchorPKPanel.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 3/13/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

@objc class AnchorPKCell: UITableViewCell {
    lazy var coverImg: UIImageView = {
       let img = UIImageView()
        addSubview(img)
        img.layer.cornerRadius = 6
        img.layer.masksToBounds = true
        return img
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        addSubview(label)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(model: TRTCLiveRoomInfo) {
        coverImg.snp.remakeConstraints { (make) in
            make.top.leading.equalTo(5)
            make.bottom.equalTo(-5)
            make.width.equalTo(50)
        }

        coverImg.sd_setImage(with: URL(string: model.coverUrl), completed: nil)
        
        infoLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(coverImg.snp.trailing).offset(5)
            make.top.equalTo(5)
            make.bottom.trailing.equalTo(-5)
        }
        infoLabel.text = "房间名:\(model.roomName) 主播:\(model.ownerName)"
    }
}

@objc class AnchorPKPanel: UIView, UITableViewDelegate,
                           UITableViewDataSource {
    @objc public weak var liveRoom: TRTCLiveRoom? = nil
    var isLoading: Bool = false
    var roomInfos: [TRTCLiveRoomInfo] = []
    @objc var pkWithRoom: ((TRTCLiveRoomInfo)->Void)? = nil
    @objc var shouldHidden: (()->Void)? = nil
    lazy var anchorTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(AnchorPKCell.classForCoder(), forCellReuseIdentifier: "AnchorPKCell")
        addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.separatorColor = UIColor.clear
        table.allowsSelection = true
        return table
    }()
    
    override func didMoveToSuperview() {
        anchorTable.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        anchorTable.snp.remakeConstraints { (make) in
            make.leading.top.width.equalTo(self)
            make.height.equalTo(288)
        }
    }
    
    func endLoading() {
        isLoading = false
        anchorTable.reloadData()
    }
    
    @objc func loadRoomsInfo() {
        roomInfos = []
        anchorTable.reloadData()
        isLoading = true
        
        RoomManager.shared.getRoomList(sdkAppID: SDKAPPID, success: { [weak self] (ids) in
            let uintIDs = ids.compactMap {
                UInt32($0)
            }
            if uintIDs.count == 0 {
                self?.endLoading()
                return
            }
            self?.liveRoom?.getRoomInfos(roomIDs: uintIDs, callback: { (code, error, infos) in
                DispatchQueue.main.async {
                    self?.roomInfos = infos.filter {
                        $0.ownerId != ProfileManager.shared.curUserID()
                    }
                    self?.endLoading()
                }
            })
        }) { [weak self] (code, error) in
            self?.endLoading()
            debugPrint(error)
        }
    }
    
    //MARK: - tableview dataSource
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if roomInfos.count > 0 {
            return 5.0
        }
        return 24
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .white
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if roomInfos.count > 0 {
            return " "
        }
        return isLoading ? "正在加载..." : "暂无主播"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnchorPKCell") as! AnchorPKCell
        if (indexPath.row < roomInfos.count) {
            let room = roomInfos[indexPath.row]
            cell.config(model: room)
        } else {
            cell.config(model: TRTCLiveRoomInfo.init(roomId: "", roomName: "",
                                                     coverUrl: "", ownerId: "",
                                                     ownerName: "", streamUrl: "",
                                                     memberCount: 0, roomStatus: .none))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: - delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if (indexPath.row < roomInfos.count) {
            if let pk = pkWithRoom {
                let room = roomInfos[indexPath.row]
                pk(room)
                isHidden = true
                if let hidden = shouldHidden {
                    hidden()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first {
            let loc:CGPoint = touch.location(in: touch.view)
            //insert your touch based code here
            if loc.y > 288 {
                isHidden = true
                if let hidden = shouldHidden {
                    hidden()
                }
            }
        }
    }
}
