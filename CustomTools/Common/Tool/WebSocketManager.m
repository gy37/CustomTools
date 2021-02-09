//
//  WebSocketManager.m
//  WMYLink
//
//  Created by yuyuyu on 2021/1/14.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "WebSocketManager.h"
#import <WebsocketStompKit/WebsocketStompKit.h>
#import "CustomSTOMPClient.h"

@interface WebSocketManager()<STOMPClientDelegate>
@property (copy, nonatomic) DidReceiveMessage receiveMessage;

@property (strong, nonatomic) CustomSTOMPClient *webSocket;
@property (assign, nonatomic) long long liveId;
@end
@implementation WebSocketManager
static WebSocketManager *manager;

#pragma mark - init
+ (instancetype)sharedManager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[WebSocketManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [self closeWebSocket];
}

#pragma mark - set get

- (CustomSTOMPClient *)webSocket {
    if (!_webSocket) {
        NSURL *url = [NSURL URLWithString:SOCKET_SERVER_URL];
        NSDictionary *headers = @{
            @"Authorization": [NSString getAccessTokenString],
        };
        _webSocket = [[CustomSTOMPClient alloc] initWithURL:url webSocketHeaders:headers useHeartbeat:YES];
        _webSocket.delegate = self;
    }
    return _webSocket;
}

#pragma mark - public

- (void)openWebSocketWithId:(long long)liveId {
    [self openWebSocket];
    self.liveId = liveId;
}

- (void)closeWebSocket {
    if (self.webSocket) {
        [self.webSocket disconnect];
        self.webSocket = nil;
    }
}

- (void)sendMessage:(NSDictionary *)message {
    NSDictionary *headers = @{
        @"Authorization": [NSString getAccessTokenString],
    };
    [self.webSocket sendTo:SOCKET_SEND_URL(message[@"accountId"]) headers:headers body:[NSString getJsonStringOfDictionary:message]];
}

- (void)setReceiveMessage:(DidReceiveMessage)receiveMessage {
    _receiveMessage = receiveMessage;
}

#pragma mark - private

- (void)openWebSocket {
    NSDictionary *headers = @{
        @"Authorization": [NSString getAccessTokenString],
    };
    [self.webSocket connectWithHeaders:headers completionHandler:^(STOMPFrame *connectedFrame, NSError *error) {
        NSLog(@"connectWithHeaders: %@---%@", connectedFrame, error);
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CustomProgressHUD showTextHUD:@"连接服务器失败"];
            });
        } else {
            [self subscribeNewMessage];
        }
    }];
}

- (void)subscribeNewMessage {
    [self.webSocket subscribeTo:SOCKET_SUBSCRIBE_URL(@(self.liveId)) headers:@{} messageHandler:^(STOMPMessage *message) {
        NSLog(@"receive message: %@", message);
        if (self.receiveMessage) {
            self.receiveMessage([NSString getDictionaryFromJsonString:message.body]);
        }
    }];
}

#pragma mark - Delegate

- (void)websocketDidDisconnect:(NSError *)error {
    NSLog(@"websocketDidDisconnect: %@", error);
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomProgressHUD showTextHUD:@"与服务器断开连接"];
        });
    }
}

@end
