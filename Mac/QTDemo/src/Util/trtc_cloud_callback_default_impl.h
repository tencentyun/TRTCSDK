#pragma once

#ifndef TRTCCLOUDCALLBACKDEFAULTIMPL_H
#define TRTCCLOUDCALLBACKDEFAULTIMPL_H

#include "ITRTCCloud.h"

class TrtcCloudCallbackDefaultImpl:public trtc::ITRTCCloudCallback
{
public:
    virtual void onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* extraInfo) override{

    };
    virtual void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) override{

    }

    virtual void onEnterRoom(int result) override{

    };
    virtual void onExitRoom(int reason) override{

    };
};

#endif // TRTCCLOUDCALLBACKDEFAULTIMPL_H
