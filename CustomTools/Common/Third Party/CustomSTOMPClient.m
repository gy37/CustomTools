//
//  CustomSTOMPClient.m
//  WMYLink
//
//  Created by yuyuyu on 2021/1/18.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "CustomSTOMPClient.h"
#import <JFRWebSocket.h>

@implementation CustomSTOMPClient
//重写WebsocketStompKit.m中的方法
//有些地方不好修改，还是用fork来修改https://github.com/gy37/WebsocketStompKit.git



//ping 内容不能为空，ping3次后会报错
//- (void)sendPing:(NSTimer *)timer  {
//    if ([self respondsToSelector:@selector(socket)]) {
//        id socket = [self performSelector:@selector(socket)];
//        if ([socket isKindOfClass:[JFRWebSocket class]]) {
//            JFRWebSocket *jfrSocket = (JFRWebSocket *)socket;
//            if (![jfrSocket isConnected]) {
//                return;
//            }
//            [jfrSocket writeData:nil];
//            NSLog(@">>>");
//        }
//    }
//}

//- (void)receivedFrame:(STOMPFrame *)frame {
//    if (!frame) {
//        return;
//    }
//    [self performSelectorInSuper:@selector(receivedFrame:) withObject:frame];
//    //错误写法，super只是编译字符提示编译器去父类找方法，实际调用的还是self，导致死循环
//    if ([super respondsToSelector:@selector(receivedFrame:)]) {
//        [super performSelector:@selector(receivedFrame:) withObject:frame];
//        [super receivedFrame:frame];
//    }
//}



@end
