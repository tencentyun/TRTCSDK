//
//  SimpleIPC.m
//  TXLiteAVDemo
//
//  Created by cui on 2020/4/21.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "SimpleIPC.h"
#import <sys/socket.h>
#import <arpa/inet.h>

@implementation SimpleIPC
{
    int sockfd;
    int _port;
    void(^_handler)(NSString *cmd, NSDictionary *info);
}

- (instancetype)initWithPort:(int)port {
    if (self = [super init]) {
        sockfd = -1;
        _port = port;
    }
    return self;
}

- (void)startListenWithHandler:(void(^)(NSString *cmd, NSDictionary *info))handler {
    if (sockfd >= 0) {
        NSLog(@"Already running");
        return;
    }
    sockfd = 0;
    _handler = handler;
    [NSThread detachNewThreadSelector:@selector(socketMain) toTarget:self withObject:nil];
}

- (void)socketMain {
    sockfd = socket(AF_INET , SOCK_STREAM , 0);

    if (sockfd == -1){
        printf("Fail to create a socket.");
        return;
    }

    struct sockaddr_in info;
    bzero(&info,sizeof(info));
    info.sin_family = PF_INET;
    info.sin_addr.s_addr = inet_addr("127.0.0.1");
    info.sin_port = htons(_port);
    bind(sockfd,(struct sockaddr *)&info, sizeof(info));
    listen(sockfd, 1);

    struct sockaddr_in clientInfo;
    socklen_t addrlen = sizeof(clientInfo);
    bzero(&clientInfo, sizeof(clientInfo));
    int clientSockfd = 0;
    NSMutableData *buffer = [[NSMutableData alloc] init];
    const size_t readLen = 1024;
    char *buff = (char*)malloc(readLen);
    while(1) {
        @autoreleasepool {
            clientSockfd = accept(sockfd, (struct sockaddr *)&clientInfo, &addrlen);
            ssize_t len = 0;
            do {
                len = read(clientSockfd, buff, readLen);
                const char boundary = '\n';
                int pos = 0;
                while(pos < len && buff[pos] != boundary) {
                    ++pos;
                }
                [buffer appendBytes:buff length:pos];

                if (pos < len) { // has boundary
                    NSError *error = nil;
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:buffer options:0 error:&error];
                    if (error) {
                        NSLog(@"Error when parsing JSON: %@", error);
                    } else {
                        NSString *cmd =  json[@"cmd"];
                        void(^handler)(NSString *cmd, NSDictionary *info) = _handler;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(cmd, json);
                        });
                    }
                    [buffer setLength:0];
                    if (len-pos-1 > 0) {
                        [buffer appendBytes:buff+pos+1 length:len-pos-1];
                    }
                } else if (buffer.length > 2048) {
                    // discard
                    [buffer setLength:0];
                }
            } while(len > 0);
            [buffer setLength:0];
            close(clientSockfd);
        }
    }
}

- (void)sendCmd:(NSString*)cmd info:(NSDictionary *)info
{
    int sockfd = 0;
    sockfd = socket(AF_INET, SOCK_STREAM , 0);

    if (sockfd == -1){
        printf("Fail to create a socket.");
        return;
    }

    struct sockaddr_in srvInfo;
    bzero(&srvInfo,sizeof(srvInfo));
    srvInfo.sin_family = PF_INET;
    srvInfo.sin_addr.s_addr = inet_addr("127.0.0.1");
    srvInfo.sin_port = htons(_port);
    int set = 1;
    setsockopt(sockfd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));

    int err = connect(sockfd,(struct sockaddr *)&srvInfo,sizeof(srvInfo));
    if(err == -1){
        printf("Connection error");
        close(sockfd);
        return;
    }
    NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithDictionary:info];
    if (msg[@"cmd"]) {
        msg[@"_cmd"] = msg[@"cmd"];
    }
    msg[@"cmd"] = cmd;
    NSData *data = [NSJSONSerialization dataWithJSONObject:msg options:0 error:nil];
    if (data) {
        write(sockfd, data.bytes, data.length);
        write(sockfd, "\n", 1);
    }
    close(sockfd);
}
@end
