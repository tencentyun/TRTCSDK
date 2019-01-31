#pragma once
#include "TXLiteAVBase.h"
#include <memory>

enum TXVodPlayerError
{
    TXVodPlayerErrorFileNotExist,
    TXVodPlayerErrorFormatNotSupport
};

class ITXVodPlayerCallback
{
public:
    virtual ~ITXVodPlayerCallback() {}

    /**
	* \brief 当多媒体文件播放开始时，SDK会通过此回调通知
	*
	* \param msLength 多媒体文件总长度，单位毫秒
	*/
	virtual void onVodPlayerStarted(uint64_t msLength) {}

    /**
	* \brief 当多媒体文件播放进度改变时，SDK会通过此回调通知
	*
	* \param msPos 多媒体文件播放进度，单位毫秒
	*/
	virtual void onVodPlayerProgress(uint64_t msPos) {}

	/**
	* \brief 当多媒体文件播放暂停时，SDK会通过此回调通知
	*/
	virtual void onVodPlayerPaused() {};

	/**
	* \brief 当多媒体文件播放恢复时，SDK会通过此回调通知
	*/
	virtual void onVodPlayerResumed() {};

	/**
	* \brief 当多媒体文件播放停止时，SDK会通过此回调通知
	*
	* \param reason 停止原因，0表示用户主动停止，1表示文件播放完，2表示视频断流
	*/
	virtual void onVodPlayerStoped(int reason) {};

    /**
	* \brief 当多媒体文件播放出错时，SDK会通过此回调通知
	*
	* \param error 错误码
	*/
    virtual void onVodPlayerError(int error) = 0;
};

class TXVodPlayerImpl;

class LITEAV_API TXVodPlayer : public ILiteAVStreamDataSource
{
public:
    /**
    * \brief 创建多媒体文件播放器
    * \param mediaFile 要播放的多媒体文件地址（本地文件路径）
    * \param repeat 循环播放
    */
    TXVodPlayer(const char *mediaFile, bool repeat = false);

    /**
    * \brief 释放多媒体文件播放器
    * \param instance 要释放的多媒体文件播放器
    */
    virtual ~TXVodPlayer();

    /**
    * \brief 设置多媒体文件播放回调
    * \param callback 要使用的多媒体文件播放回调接收实例
    */
    void setCallback(ITXVodPlayerCallback *callback);

    /**
    * \brief 开始多媒体文件播放
    * 
    * \note 用于TRTC播片场景下，TRTCSDK内部会自动调用该接口，用户无需自己手动调用
    */
    void start();

    /**
    * \brief 暂停多媒体文件播放
    */
    void pause();

    /**
    * \brief 恢复多媒体文件播放
    */
    void resume();

    /**
    * \brief 停止多媒体文件播放
    * 
    * \note 用于TRTC播片场景下，TRTCSDK内部会自动调用该接口，用户无需自己手动调用
    */
    void stop();

    /**
    * \brief 设置多媒体文件播放进度
    * \param msPos 播放进度（单位毫秒）
    */
    void seek(uint64_t msPos);

private:
    void onStart() override;

    void onStop() override;

    int onRequestVideoFrame(LiteAVVideoFrame &frame) override;

    int onRequestAudioFrame(LiteAVAudioFrame &frame) override;

    std::shared_ptr<TXVodPlayerImpl> m_impl; 
};

