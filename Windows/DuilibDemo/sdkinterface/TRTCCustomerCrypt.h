#ifndef TRTC_CUSTOMER_CYRPT_H
#define TRTC_CUSTOMER_CYRPT_H
#include <string>

class TRTCCustomerCrypt {
public:
    static void setEncryptKey(const std::string & key);
    static void * getEncodedDataProcessingListener();
};

#endif // TRTC_CUSTOMER_CYRPT_H