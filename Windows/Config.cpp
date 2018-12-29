#include "Config.h"
#include "json.h"

#include <stdio.h>

Config::Config()
    : m_sdkAppId(0)
    , m_userInfos()
{

}

Config::~Config()
{

}

Config& Config::instance()
{
    static Config uniqueInstance;
    return uniqueInstance;
}

bool Config::load()
{
    FILE* file = NULL;
    fopen_s(&file, "Config.json", "rb");
    if (!file)
    {
        return false;
    }

    std::string data;
    while (true)
    {
        char buffer[512] = { 0 };
        size_t count = ::fread(buffer, 1, 512, file);
        if (count == 0)
        {
            break;
        }

        data.append(buffer, count);
    }

    Json::Reader reader;
    Json::Value root;
    if (!reader.parse(data, root))
    {
        return false;
    }

    if (!root.isMember("sdkappid") || !root.isMember("users"))
    {
        return false;
    }

    m_sdkAppId = root["sdkappid"].asUInt();

    Json::Value users = root["users"];
    for (size_t i = 0; i < users.size(); ++i)
    {
        Json::Value item = users[i];
        if (!item.isMember("userId") || !item.isMember("userToken"))
        {
            return false;
        }

        UserInfo info;
        info.userId = item["userId"].asString();
        info.userSig = item["userToken"].asString();

        m_userInfos.push_back(info);
    }

    return true;
}

uint32_t Config::getSdkAppId() const
{
    return m_sdkAppId;
}

std::vector<UserInfo> Config::getUserInfos() const
{
    return m_userInfos;
}
