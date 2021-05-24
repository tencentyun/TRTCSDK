//
//  LiveViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit

/**
 * RTC视频互动直播的入口页面
 *
 * 页面显示了当前正在直播的房间列表，以及“开始直播”的入口
 * 可以点击列表中的某个房间，以观众的身份进入房间，观看直播
 * 也可以点击“开始直播”，创建自己的直播房间，创建房间后，你的房间id会在房间列表上显示出来
 */
class LiveViewController: UIViewController {
    
    @IBOutlet weak var liveRoomTableView: UITableView!
    
    var liveRoomList: [LiveRoomItem] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// 拉取视频直播房间列表
        LiveRoomManager.sharedInstance.queryLiveRoomList { [weak self] (roomList) in
            guard let self = self else { return }
            self.liveRoomList = roomList
            self.liveRoomTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        if "beginLivePush" == segueId { /// 开始直播
            let liveVC = segue.destination as? LivePushViewController
            let roomId = UInt32((CACurrentMediaTime() * 1000))
            liveVC?.roomId = roomId
            liveVC?.userId = "\(roomId)"
        }
    }
}

/// 视频直播房间列表显示逻辑
extension LiveViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Live", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LivePlayViewControllerId") as? LivePlayViewController
        if nil != vc {
            guard let roomId = tableView.cellForRow(at: indexPath)?.tag else {
                return
            }
            /// 点击房间列表中的某个房间，以观众身份进入观看
            vc!.roomId = UInt32(roomId)
            vc!.userId = "\(UInt32((CACurrentMediaTime() * 1000)))"
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return liveRoomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveRoomCellId")!
        if indexPath.section < liveRoomList.count {
            let attrText = NSMutableAttributedString.init(string: "直播间ID：", attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.lightGray
            ])
            attrText.append(NSAttributedString.init(string: liveRoomList[indexPath.section].roomId, attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]))
            cell.textLabel?.attributedText = attrText;
            cell.tag = Int(liveRoomList[indexPath.section].roomId) ?? 0
        }
        return cell
    }
}
