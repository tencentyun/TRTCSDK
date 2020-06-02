//
//  TRTCBgmManager.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 3/19/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
@objc public protocol TRTCCustomAudioEffectManager: class {
    typealias Callback = (_ code: Int, _ message: String?) -> Void
    /// 播放背景音乐
    /// - Parameters:
    ///   - url: 背景音乐文件路径
    ///   - progress: 进度回调，返回当前已播放的时间，和总的bgm时长，单位是毫秒(ms)
    ///   - completion: Bgm播放结束回调
    /// - Note:
    ///   - 手动调用stopBgm时，不会回调completion
    @objc func playBgm(_ url: String,
                 progress:@escaping (_ progressMs: Int, _ duration: Int) -> Void,
                 completion: Callback?)
    
    /// 暂停背景音乐
    @objc func pauseBgm()
    
    /// 继续播放背景音乐
    @objc func resumeBgm()
    
    /// 停止播放背景音乐
    @objc func stopBgm()
    
    /// 设置背景音乐的音量大小，播放背景音乐混音时使用，用来控制背景音音量大小。
    /// - Parameter volume:音量大小，100为正常音量，取值范围为0 - 100；默认值：100
    @objc func setBGMVolume(volume: Int)
    
    /// 设置背景音乐播放进度 0 表示成功
    /// - Parameter pos: 单位毫秒
    @objc func setBGMPosition(pos: Int) -> Int
    
    /// 设置麦克风的音量大小，播放背景音乐混音时使用，用来控制麦克风音量大小。
    /// - Parameter volume: 音量大小，取值0 - 100，默认值为100
    @objc func setMicVolume(volume: Int)
    
    /// 设置混响效果
    /// - Parameter reverbType: 混响类型，详情请参见 TXReverbType
    @objc func setReverbType(reverbType:TRTCReverbType)
    
    /// 设置变声类型
    /// - Parameter reverbType: 变声类型，详情请参见 TXVoiceChangerType
    @objc func setVoiceChangerType(voiceChangerType:TRTCVoiceChangerType)
    
    /// 每个音效都需要您指定具体的 ID，您可以通过该 ID 对音效的开始、停止、音量等进行设置。
    /// 支持 aac、mp3 以及 m4a 格式。
    /// - 若您想同时播放多个音效，请分配不同的 ID 进行播放。因为使用同一个 ID 播放不同音效，SDK 会先停止播放旧的音效，再播放新的音效。
    /// - Parameters:
    ///   - effectId: 音效 ID
    ///   - path: 音效路径
    ///   - count: 循环次数
    ///   - publish: 是否推送 / true 推送给观众, false 本地预览
    ///   - volume: 音量大小,取值范围为0 - 100；默认值：100
    @objc func playAudioEffect(effectId: Int32, path: String, count: Int32, publish: Bool, volume: Int32)

    /// 设置音效音量
    /// - 该操作会覆盖通过 setAllAudioEffectsVolume 指定的整体音效音量。
    /// - Parameters:
    ///   - effectId: effectId 音效 ID
    ///   - volume: volume   音量大小，取值范围为0 - 100；默认值：100
    @objc func setAudioEffectVolume(effectId: Int32, volume: Int32)
    
    /// 设置所有音效音量
    /// - 该操作会覆盖通过 setAudioEffectVolume 指定的单独音效音量。
    /// - Parameter volume: 音量大小，取值范围为0 - 100；默认值：100
    @objc func setAllAudioEffectsVolume(volume: Int32)
    
    /// 暂停音效
    /// - Parameter effectId: 音效 ID
    @objc func pauseAudioEffect(effectId: Int32)

    /// 恢复音效
    /// - Parameter effectId: 音效 ID
    @objc func resumeAudioEffect(effectId: Int32)

    /// 停止音效
    /// - Parameter effectId: 音效 ID
    @objc func stopAudioEffect(effectId: Int32)

    /// 停止所有音效
    @objc func stopAllAudioEffects()
}
