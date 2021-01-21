//
//  WebSocketManager.h
//  WMYLink
//
//  Created by yizhi on 2021/1/14.
//  Copyright © 2021 YiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^DidReceiveMessage)(NSDictionary *message);

@interface WebSocketManager : NSObject
+ (instancetype)sharedManager;
- (void)openWebSocketWithId:(long long)liveId;
- (void)closeWebSocket;
- (void)sendMessage:(NSDictionary *)info;
- (void)setReceiveMessage:(DidReceiveMessage)receiveMessage;
@end

NS_ASSUME_NONNULL_END
