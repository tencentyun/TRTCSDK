//
//  BeautyPerformer.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 3/19/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

@objc class BeautyPerformer: NSObject,TCBeautyPanelActionPerformer {
    @objc var liveRoom: TRTCLiveRoomImpl
    
    @objc init(liveRoom: TRTCLiveRoomImpl) {
        self.liveRoom = liveRoom
        super.init()
    }
    
    func setFilter(_ filterImage: UIImage?) {
        if let image = filterImage {
           liveRoom.setFilter(image: image)
        }
    }
    
    func setFilterConcentration(_ level: Float) {
        liveRoom.setFilterConcentration(concentration: level)
    }
    
    func setGreenScreenFile(_ file: URL?) {
        if let url = file {
            liveRoom.setGreenScreenFile(file: url)
        }
    }
    
    func setBeautyStyle(_ beautyStyle: Int) {
        liveRoom.beautyManager.setBeautyStyle(TXBeautyStyle(rawValue: beautyStyle) ?? .nature)
    }
    
    func setBeautyLevel(_ level: Float) {
        liveRoom.beautyManager.setBeautyLevel(level)
    }
    
    func setWhitenessLevel(_ level: Float) {
        liveRoom.beautyManager.setWhitenessLevel(level)
    }
    
    func setRuddyLevel(_ level: Float) {
        liveRoom.beautyManager.setRuddyLevel(level)
    }
    
    func setEyeScaleLevel(_ level: Float) {
        liveRoom.beautyManager.setEyeScaleLevel(level)
    }
    
    func setFaceSlimLevel(_ level: Float) {
        liveRoom.beautyManager.setFaceSlimLevel(level)
    }
    
    func setFaceVLevel(_ level: Float) {
        liveRoom.beautyManager.setFaceVLevel(level)
    }
    
    func setChinLevel(_ level: Float) {
        liveRoom.beautyManager.setChinLevel(level)
    }
    
    func setFaceShortLevel(_ level: Float) {
        liveRoom.beautyManager.setFaceShortLevel(level)
    }
    
    func setNoseSlimLevel(_ level: Float) {
        liveRoom.beautyManager.setNoseSlimLevel(level)
    }
    
    func setEyeLightenLevel(_ level: Float) {
        liveRoom.beautyManager.setEyeLightenLevel(level)
    }
    
    func setToothWhitenLevel(_ level: Float) {
        liveRoom.beautyManager.setToothWhitenLevel(level)
    }
    
    func setWrinkleRemoveLevel(_ level: Float) {
        liveRoom.beautyManager.setWrinkleRemoveLevel(level)
    }
    
    func setPounchRemoveLevel(_ level: Float) {
        liveRoom.beautyManager.setPounchRemoveLevel(level)
    }
    
    func setSmileLinesRemoveLevel(_ level: Float) {
        liveRoom.beautyManager.setSmileLinesRemoveLevel(level)
    }
    
    func setForeheadLevel(_ level: Float) {
        liveRoom.beautyManager.setForeheadLevel(level)
    }
    
    func setEyeDistanceLevel(_ level: Float) {
        liveRoom.beautyManager.setEyeDistanceLevel(level)
    }
    
    func setEyeAngleLevel(_ level: Float) {
        liveRoom.beautyManager.setEyeAngleLevel(level)
    }
    
    func setMouthShapeLevel(_ level: Float) {
        liveRoom.beautyManager.setMouthShapeLevel(level)
    }
    
    func setNoseWingLevel(_ level: Float) {
        liveRoom.beautyManager.setNoseWingLevel(level)
    }
    
    func setNosePositionLevel(_ level: Float) {
        liveRoom.beautyManager.setNosePositionLevel(level)
    }
    
    func setLipsThicknessLevel(_ level: Float) {
        liveRoom.beautyManager.setLipsThicknessLevel(level)
    }
    
    func setFaceBeautyLevel(_ level: Float) {
        liveRoom.beautyManager.setFaceBeautyLevel(level)
    }
    
    func setMotionTmpl(_ tmplName: String?, inDir tmplDir: String?) {
        liveRoom.beautyManager.setMotionTmpl(tmplName, inDir: tmplDir)
    }
    
    func setMotionMute(_ motionMute: Bool) {
        liveRoom.beautyManager.setMotionMute(motionMute)
    }
    
}
