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
    ~GenerateTestUserSig();
    static GenerateTestUserSig& instance();

    std::string genTestUserSig(int appid,std::string & token,std::string userId) const;

 private:
	explicit GenerateTestUserSig();
};

#endif  // QTMACDEMO_BASE_GenerateTestUserSig_H_
