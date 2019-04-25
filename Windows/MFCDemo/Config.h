#pragma once

#include <string>
#include <vector>
#include <stdint.h>

struct UserInfo
{
    std::string userId;
    std::string userSig;
};

class Config
{
protected:
    Config();
    Config(const Config&);
    Config operator =(const Config&);
public:
    ~Config();

    static Config& instance();

    bool load();

    uint32_t getSdkAppId() const;
    std::vector<UserInfo> getUserInfos() const;
private:
    uint32_t m_sdkAppId;
    std::vector<UserInfo> m_userInfos;
};
