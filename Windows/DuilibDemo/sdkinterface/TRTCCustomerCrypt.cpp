#include <string>
#include <Windows.h>
#include <bcrypt.h>
#include <memory>
#include "TRTCCustomerCrypt.h"
#include "TXLiteAVEncodedDataProcessingListener.h"


std::string md5(std::string string) {
    //打开一个算法提供者并得到句柄
    BCRYPT_ALG_HANDLE hAlg = nullptr;
    BCryptOpenAlgorithmProvider(&hAlg, BCRYPT_MD5_ALGORITHM, MS_PRIMITIVE_PROVIDER, 0);

    //创建Hash对象
    DWORD dwHashObjectSize = 0;
    DWORD dwData = 0;
    BCryptGetProperty(hAlg, BCRYPT_OBJECT_LENGTH, (PBYTE)&dwHashObjectSize, sizeof(DWORD), &dwData, 0);
    auto pHashObject = std::make_unique<UCHAR[]>(dwHashObjectSize);

    BCRYPT_HASH_HANDLE hHash = nullptr;
    BCryptCreateHash(hAlg, &hHash, &pHashObject[0], dwHashObjectSize, nullptr, 0, 0);

    //计算Hash值
    BCryptHashData(hHash, (PBYTE)string.c_str(), string.size(), 0);

    //分配Hash缓冲区
    DWORD dwHashSize = 0;
    BCryptGetProperty(hAlg, BCRYPT_HASH_LENGTH, (PBYTE)&dwHashSize, sizeof(DWORD), &dwData, 0);
    auto pHash = std::make_unique<UCHAR[]>(dwHashSize);

    BCryptFinishHash(hHash, &pHash[0], dwHashSize, 0);

    BCryptDestroyHash(hHash);
    BCryptCloseAlgorithmProvider(hAlg, 0);

    char md5_str[33] = { 0 };
    sprintf_s(md5_str, 
        "%02x%02x%02x%02x"
        "%02x%02x%02x%02x"
        "%02x%02x%02x%02x"
        "%02x%02x%02x%02x",
        pHash[0], pHash[1], pHash[2], pHash[3],
        pHash[4], pHash[5], pHash[6], pHash[7],
        pHash[8], pHash[9], pHash[10], pHash[11],
        pHash[12], pHash[13], pHash[14], pHash[15]
    );

    return md5_str;
}

class CustomerEncryptor : public liteav::ITXLiteAVEncodedDataProcessingListener {
public:
    bool didEncodeVideo(liteav::TXLiteAVEncodedData & videoData) {
        if (videoData.processedData && encrypt_key_.size()) {
            XORData(videoData);

            return true;
        }

        return false;
    }

    bool willDecodeVideo(liteav::TXLiteAVEncodedData & videoData) {
        if (videoData.processedData && encrypt_key_.size()) {
            XORData(videoData);

            return true;
        }

        return false;
    }

    bool didEncodeAudio(liteav::TXLiteAVEncodedData & audioData) {
        if (audioData.processedData && encrypt_key_.size()) {
            XORData(audioData);

            return true;
        }

        return false;
    }

    bool willDecodeAudio(liteav::TXLiteAVEncodedData & audioData) {
        if (audioData.processedData && encrypt_key_.size()) {
            XORData(audioData);

            return true;
        }

        return false;
    }

    void XORData(liteav::TXLiteAVEncodedData & encodedData) {
        auto srcData = encodedData.originData->cdata();
        auto keySize = encrypt_key_.size();
        auto dataSize = encodedData.originData->size();
        encodedData.processedData->SetSize(dataSize);
        auto dstData = encodedData.processedData->data();
        for (int i = 0; i<dataSize; ++i) {
            dstData[i] = srcData[i] ^ encrypt_key_[i % keySize];
        }
    }

    std::string encrypt_key_;
};


CustomerEncryptor g_CustomerEncrypter;

void TRTCCustomerCrypt::setEncryptKey(const std::string & key) {
    if (key.empty()) {
        g_CustomerEncrypter.encrypt_key_ = key;
    }
    else {
        g_CustomerEncrypter.encrypt_key_ = md5(key);
    }
}

void * TRTCCustomerCrypt::getEncodedDataProcessingListener() {
    if (g_CustomerEncrypter.encrypt_key_.empty()) return 0;

    return &g_CustomerEncrypter;
}