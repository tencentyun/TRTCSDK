//
//  BeautyPerformer.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 3/19/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

@objc class BeautyPerformer: NSObject, TCBeautyPanelActionPerformer {
    func setFilterConcentration(_ level: Float) {
//        liveRoom.setFilterConcentration(concentration: level)
    }

    func setGreenScreenFile(_ file: URL?) {
//        liveRoom.setGreenScreenFile(file: file)
    }
    
    @objc var liveRoom: TRTCLiveRoom
    
    @objc init(liveRoom: TRTCLiveRoom) {
        self.liveRoom = liveRoom
        super.init()
    }
    
    func setFilter(_ filterImage: UIImage?) {
        guard let filterImage = filterImage else {
            TRTCCloud.sharedInstance()?.setFilter(nil)
            return
        }
        liveRoom.getBeautyManager().setFilter(filterImage)
    }
    
    func setFilterStrength(_ level: Float) {
        liveRoom.getBeautyManager().setFilterStrength(level)
    }
    
    func setGreenScreenFile(_ file: String?) {
        guard let file = file else {
            TRTCCloud.sharedInstance()?.setGreenScreenFile(nil)
            return
        }
        liveRoom.getBeautyManager().setGreenScreenFile(file)
    }
    
    func setBeautyStyle(_ beautyStyle: Int) {
        liveRoom.getBeautyManager().setBeautyStyle(TXBeautyStyle(rawValue: beautyStyle) ?? .nature)
    }
    
    func setBeautyLevel(_ level: Float) {
        liveRoom.getBeautyManager().setBeautyLevel(level)
    }
    
    func setWhitenessLevel(_ level: Float) {
        liveRoom.getBeautyManager().setWhitenessLevel(level)
    }
    
    func setRuddyLevel(_ level: Float) {
        liveRoom.getBeautyManager().setRuddyLevel(level)
    }
    
    func setEyeScaleLevel(_ level: Float) {
        liveRoom.getBeautyManager().setEyeScaleLevel(level)
    }
    
    func setFaceSlimLevel(_ level: Float) {
        liveRoom.getBeautyManager().setFaceSlimLevel(level)
    }
    
    func setFaceVLevel(_ level: Float) {
        liveRoom.getBeautyManager().setFaceVLevel(level)
    }
    
    func setChinLevel(_ level: Float) {
        liveRoom.getBeautyManager().setChinLevel(level)
    }
    
    func setFaceShortLevel(_ level: Float) {
        liveRoom.getBeautyManager().setFaceShortLevel(level)
    }
    
    func setNoseSlimLevel(_ level: Float) {
        liveRoom.getBeautyManager().setNoseSlimLevel(level)
    }
    
    func setEyeLightenLevel(_ level: Float) {
        liveRoom.getBeautyManager().setEyeLightenLevel(level)
    }
    
    func setToothWhitenLevel(_ level: Float) {
        liveRoom.getBeautyManager().setToothWhitenLevel(level)
    }
    
    func setWrinkleRemoveLevel(_ level: Float) {
        liveRoom.getBeautyManager().setWrinkleRemoveLevel(level)
    }
    
    func setPounchRemoveLevel(_ level: Float) {
        liveRoom.getBeautyManager().setPounchRemoveLevel(level)
    }
    
    func setSmileLinesRemoveLevel(_ level: Float) {
        liveRoom.getBeautyManager().setSmileLinesRemoveLevel(level)
    }
    
    func setForeheadLevel(_ level: Float) {
        liveRoom.getBeautyManager().setForeheadLevel(level)
    }
    
    func setEyeDistanceLevel(_ level: Float) {
        liveRoom.getBeautyManager().setEyeDistanceLevel(level)
    }
    
    func setEyeAngleLevel(_ level: Float) {
        liveRoom.getBeautyManager().setEyeAngleLevel(level)
    }
    
    func setMouthShapeLevel(_ level: Float) {
        liveRoom.getBeautyManager().setMouthShapeLevel(level)
    }
    
    func setNoseWingLevel(_ level: Float) {
        liveRoom.getBeautyManager().setNoseWingLevel(level)
    }
    
    func setNosePositionLevel(_ level: Float) {
        liveRoom.getBeautyManager().setNosePositionLevel(level)
    }
    
    func setLipsThicknessLevel(_ level: Float) {
        liveRoom.getBeautyManager().setLipsThicknessLevel(level)
    }
    
    func setFaceBeautyLevel(_ level: Float) {
        liveRoom.getBeautyManager().setFaceBeautyLevel(level)
    }
    
    func setMotionTmpl(_ tmplName: String?, inDir tmplDir: String?) {
        liveRoom.getBeautyManager().setMotionTmpl(tmplName, inDir: tmplDir)
    }
    
    func setMotionMute(_ motionMute: Bool) {
        liveRoom.getBeautyManager().setMotionMute(motionMute)
    }
    
}
