//
//  TRTCLiveRoomSoundEffectViewModel.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/30.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

class TRTCLiveRoomAudioEffectCellModel: NSObject {
    var actionID: Int = 0
    var title: String = ""
    var icon: UIImage?
    var selectIcon: UIImage?
    var selected: Bool = false
    var action: (()->())?
}

class TRTCLiveRoomMusicModel: NSObject {
    var musicID : Int32 = 0
    var musicName : String = ""
    var singerName : String = ""
    var isLocal : Bool = true
    var resourceUrl : String = ""
    var action : ((_ isSelected :Bool, _ model: TRTCLiveRoomMusicModel)->())?
    
    var currentTime: Int = 0
    var totalTime: Int = 0
}

protocol TRTCLiveRoomSoundEffectViewResponder: class {
    func bgmOnPrepareToPlay()
    func bgmOnPlaying(current: Int, total: Int)
    func bgmOnCompletePlaying()
}

@objc class TRTCLiveRoomSoundEffectViewModel: NSObject {
    
    weak var viewResponder: TRTCLiveRoomSoundEffectViewResponder?
    
    let room: TRTCLiveRoom
    @objc public init(liveRoom: TRTCLiveRoom) {
        self.room = liveRoom
        super.init()
    }
    
    lazy var manager : TXAudioEffectManager? = {
        return room.getAudioEffectManager()
    }()
    
    var currentMusicVolum: Int = 0
    var currentPitchVolum: Double = 0
    
    var bgmID : Int32 = 0
    
    public func setVolume(music: Int) {
        currentMusicVolum = music
        guard let manager = manager else {
            return
        }
        if bgmID != 0 {
            manager.setMusicPlayoutVolume(bgmID, volume: music)
            manager.setMusicPublishVolume(bgmID, volume: music)
        }
    }
    
    public func setEarMonitor(_ enable: Bool) {
        guard let manager = manager else {
            return
        }
        manager.enableVoiceEarMonitor(enable)
    }
    
    public func setVolume(person: Int) {
        guard let manager = manager else {
            return
        }
        manager.setVoiceVolume(person)
    }
    
    public func setPitch(person: Double) {
        currentPitchVolum = person
        guard let manager = manager else {
            return
        }
        if bgmID != 0 {
            manager.setMusicPitch(bgmID, pitch: person)
        }
    }
    
    // MARK: - BGM
    var isPlaying = false
    var isPlayingComplete = false
    var currentPlayingModel: TRTCLiveRoomMusicModel?
    lazy var bgmDataSource: [TRTCLiveRoomMusicModel] = {
        var res : [TRTCLiveRoomMusicModel] = []
        let urls = [
            "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/PositiveHappyAdvertising.mp3",
            "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/SadCinematicPiano.mp3",
            "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/WonderWorld.mp3"]
        let names : [String] = [
            .musicTitle1Text,
            .musicTitle2Text,
            .musicTitle3Text,
        ]
        for i in 0..<3 {
            let model = TRTCLiveRoomMusicModel()
            model.musicID = Int32(1000 + i)
            model.musicName = names[i]
            model.resourceUrl = urls[i]
            model.action = { [weak self] (isSelected, model) in
                guard let `self` = self else { return }
                self.stopPlay()
                self.playMusic(model)
            }
            res.append(model)
        }
        return res
    }()
    
    func playMusic(_ model: TRTCLiveRoomMusicModel) {
        
        guard let manager = manager else {
            return
        }
        if bgmID == model.musicID {
            resumePlay()
            return
        }
        else {
            stopPlay()
        }
        currentPlayingModel = model
        bgmID = model.musicID
        let param = TXAudioMusicParam()
        param.id = bgmID
        param.path = model.resourceUrl
        param.loopCount = 0
        manager.startPlayMusic(param) { [weak self] (errCode) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.isPlaying = true
                self.isPlayingComplete = false
                self.viewResponder?.bgmOnPrepareToPlay()
            }
        } onProgress: { [weak self] (progress, duration) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                let current = progress/1000
                let total = duration/1000
                if let model = self.currentPlayingModel {
                    model.currentTime = current
                    model.totalTime = total
                }
                self.viewResponder?.bgmOnPlaying(current: current, total: total)
            }
        } onComplete: { [weak self] (errCode) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.bgmID = 0
                self.isPlaying = false
                self.isPlayingComplete = true
                self.viewResponder?.bgmOnCompletePlaying()
            }
        }
    }
    
    func stopPlay() {
        isPlaying = false
        guard let manager = manager else {
            return
        }
        if bgmID != 0 {
            manager.stopPlayMusic(bgmID)
            currentPlayingModel = nil
            bgmID = 0
        }
    }
    
    func pausePlay() {
        isPlaying = false
        guard let manager = manager else {
            return
        }
        if bgmID != 0 {
            manager.pausePlayMusic(bgmID)
        }
    }
    
    func resumePlay() {
        isPlaying = true
        guard let manager = manager else {
            return
        }
        if bgmID != 0 {
            manager.resumePlayMusic(bgmID)
        }
    }
    
    func clearStatus() {
        currentPlayingModel = nil
        if bgmID != 0 {
            setPitch(person: 0)
            stopPlay()
            bgmID = 0
        }
        setVolume(music: 100)
        setVolume(person: 100)
        
    }
    
    
    // MARK: - Voice change and reverb
    var currentChangerType : TXVoiceChangeType = ._0
    var currentReverb : TXVoiceReverbType = ._0
    
    lazy var reverbDataSource: [TRTCLiveRoomAudioEffectCellModel] = {
        var res: [TRTCLiveRoomAudioEffectCellModel] = []
        let titleArray = [
            TRTCLocalize("ASKit.MenuItem.No effect"),
            TRTCLocalize("ASKit.MenuItem.Karaoke room"),
            TRTCLocalize("ASKit.MenuItem.Metallic"),
            TRTCLocalize("ASKit.MenuItem.Deep"),
            TRTCLocalize("ASKit.MenuItem.Resonant"),
            ]
        let iconNameArray = [
            "originState_nor",
            "Reverb_KTV_nor",
            "Reverb_jinshu_nor",
            "Reverb_dichen_nor",
            "Reverb_hongliang_nor",
        ]
        let iconSelectedNameArray = [
            "originState_sel",
            "Reverb_KTV_sel",
            "Reverb_jinshu_sel",
            "Reverb_dichen_sel",
            "Reverb_hongliang_sel",
        ]
        for index in 0..<titleArray.count {
            let title = titleArray[index]
            let normalIconName = iconNameArray[index]
            let selectIconName = iconSelectedNameArray[index]
            
            let model = TRTCLiveRoomAudioEffectCellModel()
            model.actionID = index
            model.title = title
            model.selected = title == TRTCLocalize("ASKit.MenuItem.No effect")
            model.icon = UIImage(named: normalIconName)
            model.selectIcon = UIImage(named: selectIconName)
            model.action = { [weak self] in
                guard let `self` = self else { return }
                let type = self.switch2ReverbType(index)
                self.manager?.setVoiceReverbType(type)
                self.currentReverb = type
            }
            if model.icon != nil {
                res.append(model)
            }
        }
        return res
    }()
    
    lazy var voiceChangeDataSource: [TRTCLiveRoomAudioEffectCellModel] = {
        var res: [TRTCLiveRoomAudioEffectCellModel] = []
        
        let titleArray =
            [TRTCLocalize("ASKit.MenuItem.Original"),
             TRTCLocalize("ASKit.MenuItem.Naughty boy"),
             TRTCLocalize("ASKit.MenuItem.Little girl"),
             TRTCLocalize("ASKit.MenuItem.Middle-aged man"),
             TRTCLocalize("ASKit.MenuItem.Ethereal voice"),
             ]
        
        let iconNameArray = [
            "originState_nor",
            "voiceChange_xionghaizi_nor",
            "voiceChange_loli_nor",
            "voiceChange_dashu_nor",
            "voiceChange_kongling_nor",
        ]
        
        let iconSelectedNameArray = [
            "originState_sel",
            "voiceChange_xionghaizi_sel",
            "voiceChange_loli_sel",
            "voiceChange_dashu_sel",
            "voiceChange_kongling_sel",
            ]
        
        for index in 0..<titleArray.count {
            let title = titleArray[index]
            let normalIconName = iconNameArray[index]
            let selectedIconName = iconSelectedNameArray[index]
            let model = TRTCLiveRoomAudioEffectCellModel()
            model.title = title
            model.actionID = index
            model.selected = title == TRTCLocalize("ASKit.MenuItem.Original")
            model.icon = UIImage(named: normalIconName)
            model.selectIcon = UIImage(named: selectedIconName)
            model.action = { [weak self] in
                guard let `self` = self else { return }
                let type = self.switch2VoiceChangeType(index)
                self.manager?.setVoiceChangerType(type)
                self.currentChangerType = type
            }
            if model.icon != nil {
                res.append(model)
            }
        }
        return res
    }()
    
    func switch2VoiceChangeType(_ index: Int) -> TXVoiceChangeType {
        switch index {
        case 0:
            return ._0
        case 1:
            return ._1
        case 2:
            return ._2
        case 3:
            return ._3
        case 4:
            return ._11
        default:
            return ._0
        }
    }
    
    func switch2ReverbType(_ index: Int) -> TXVoiceReverbType {
        switch index {
        case 0:
            return ._0
        case 1:
            return ._1
        case 2:
            return ._6
        case 3:
            return ._4
        case 4:
            return ._5
        default:
            return ._0
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let musicTitle1Text = TRTCLocalize("Demo.TRTC.VoiceRoom.musicname1")
    static let musicTitle2Text = TRTCLocalize("Demo.TRTC.VoiceRoom.musicname2")
    static let musicTitle3Text = TRTCLocalize("Demo.TRTC.VoiceRoom.musicname3")
}
