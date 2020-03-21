//
//  LiveViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

import Cocoa

/**
 * RTC视频互动直播的入口页面
 *
 * 页面显示了当前正在直播的房间列表，以及“开始直播”的入口
 * 可以点击列表中的某个房间，以观众的身份进入房间，观看直播
 * 也可以点击“开始直播”，创建自己的直播房间，创建房间后，你的房间id会在房间列表上显示出来
 */
class LiveViewController: NSViewController {
    
    @IBOutlet weak var liveRoomTableView: NSTableView!
    
    var liveRoomList: [LiveRoomItem] = []
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        /// 拉取视频直播房间列表
        LiveRoomManager.sharedInstance.queryLiveRoomList { [weak self] (roomList) in
            guard let self = self else { return }
            self.liveRoomList = roomList
            self.liveRoomTableView.reloadData()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        if "beginLivePush" == segueId { /// 开始直播
            (NSApp.delegate as? AppDelegate)?.closeAllWindows()
            
            guard let winController = segue.destinationController as? NSWindowController else {
                return
            }
            let liveVC = winController.contentViewController as? LivePushViewController
            let roomId = UInt32((CACurrentMediaTime() * 1000))
            liveVC?.roomId = roomId
            liveVC?.userId = "\(roomId)"
        }
    }
    
}

/// 视频直播房间列表显示逻辑
extension LiveViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    // MARK: NSTableViewDelegate
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let storyboard = NSStoryboard.init(name: "Live", bundle: nil)
        let winController = storyboard.instantiateController(withIdentifier: "LivePlayWindowControllerId")
        guard let vc = (winController as? NSWindowController)?.contentViewController as? LivePlayViewController else {
            return false
        }
        
        if row < liveRoomList.count {
            (NSApp.delegate as? AppDelegate)?.closeAllWindows()
            /// 点击房间列表中的某个房间，以观众身份进入观看
            vc.roomId = UInt32(liveRoomList[row].roomId) ?? 0
            vc.userId = "\(UInt32((CACurrentMediaTime() * 1000)))"
            (winController as? NSWindowController)?.showWindow(nil)
        }
        return true
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return liveRoomList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("LiveRoomCellId"), owner: nil) as? NSTableCellView
        if row < liveRoomList.count {
            let attrText = NSMutableAttributedString.init(string: "直播间ID：", attributes: [
                NSAttributedString.Key.foregroundColor : NSColor.lightGray
            ])
            attrText.append(NSAttributedString.init(string: liveRoomList[row].roomId, attributes: [
                NSAttributedString.Key.foregroundColor : NSColor.white
            ]))
            cellView?.textField?.attributedStringValue = attrText;
        }
        return cellView
    }
}
