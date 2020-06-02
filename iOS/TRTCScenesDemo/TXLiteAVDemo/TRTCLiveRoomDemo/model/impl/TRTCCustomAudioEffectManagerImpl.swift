//
//  TRTCBgmManagerImpl.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 3/19/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
@objc public class TRTCCustomAudioEffectManagerImpl: NSObject, TRTCCustomAudioEffectManager {
    // MARK: - BGM
    
    @objc public func playBgm(_ url: String,
                        progress:@escaping (_ progressMs: Int, _ duration: Int) -> Void,
                        completion: Callback?) {
        TRTCCloud.sharedInstance()?.playBGM(url, withBeginNotify: { code in
            if (code != 0) {
                completion?(code, "")
            }
        }, withProgressNotify: progress, andCompleteNotify: { code in
            completion?(code, "")
        })
    }
    
    @objc public func pauseBgm() {
        TRTCCloud.sharedInstance()?.pauseBGM()
    }
    
    @objc public func resumeBgm() {
        TRTCCloud.sharedInstance()?.resumeBGM()
    }
    
    @objc public func stopBgm() {
        TRTCCloud.sharedInstance()?.stopBGM()
    }
    
    @objc public func setBGMVolume(volume: Int) {
        TRTCCloud.sharedInstance()?.setBGMVolume(volume)
    }
    
    @objc public func setBGMPosition(pos: Int) -> Int {
        return Int(TRTCCloud.sharedInstance()?.setBGMPosition(pos) ?? -1)
    }
    
    @objc public func setMicVolume(volume: Int) {
        TRTCCloud.sharedInstance()?.setAudioCaptureVolume(volume)
    }
    
    //MARK: - 音效
    
    @objc public func setReverbType(reverbType: TRTCReverbType) {
        TRTCCloud.sharedInstance()?.setReverbType(reverbType)
    }
    
    @objc public func setVoiceChangerType(voiceChangerType: TRTCVoiceChangerType) {
        TRTCCloud.sharedInstance()?.setVoiceChangerType(voiceChangerType)
    }
    
    @objc public func playAudioEffect(effectId: Int32, path: String, count: Int32, publish: Bool, volume: Int32) {
        let effect = TRTCAudioEffectParam(effectId, path: path)
        effect.loopCount = count
        effect.publish = publish
        effect.volume = volume
        TRTCCloud.sharedInstance()?.playAudioEffect(effect)
    }
    
    @objc public func setAudioEffectVolume(effectId: Int32, volume: Int32) {
        TRTCCloud.sharedInstance()?.setAudioEffectVolume(effectId, volume: volume)
    }
    
    @objc public func stopAudioEffect(effectId: Int32) {
        TRTCCloud.sharedInstance()?.stopAudioEffect(effectId)
    }
    
    @objc public func stopAllAudioEffects() {
        TRTCCloud.sharedInstance()?.stopAllAudioEffects()
    }
    
    @objc public func setAllAudioEffectsVolume(volume: Int32) {
        TRTCCloud.sharedInstance()?.setAllAudioEffectsVolume(volume)
    }
    
    @objc public func pauseAudioEffect(effectId: Int32) {
        TRTCCloud.sharedInstance()?.pauseAudioEffect(effectId)
    }
    
    @objc public func resumeAudioEffect(effectId: Int32) {
        TRTCCloud.sharedInstance()?.resumeAudioEffect(effectId)
    }
}
