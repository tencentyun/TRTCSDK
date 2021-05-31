//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef QTMACDEMO_BASE_GenerateTestUserSig_H_
#define QTMACDEMO_BASE_GenerateTestUserSig_H_

#include <string>
#include <vector>
#include <stdint.h>

class GenerateTestUserSig {
 public:
    GenerateTestUserSig();
    ~GenerateTestUserSig();
    static const char* genTestUserSig(const char* identifier, int appId, const char* secretKey);
};

#endif  // QTMACDEMO_BASE_GenerateTestUserSig_H_
