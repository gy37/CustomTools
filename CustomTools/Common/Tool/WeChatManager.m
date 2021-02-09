//
//  WeChatManager.m
//  WMYLink
//
//  Created by yuyuyu on 2021/1/19.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "WeChatManager.h"
#import <WechatOpenSDK/WXApi.h>
@interface WeChatManager()<WXApiDelegate>
@end
@implementation WeChatManager
static WeChatManager *manager;

+ (instancetype)sharedManager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[WeChatManager alloc] init];
    });
    return manager;
}

- (void)registerApp:(NSString *)appid {
    [WXApi registerApp:appid universalLink:UNIVERSAL_LINK];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)handleOpenUniversalLink:(NSUserActivity *)activity {
    [WXApi handleOpenUniversalLink:activity delegate:self];
}

#pragma mark - 微信分享

- (void)shareToWeChatWithType:(WeChatType)type title:(NSString *)title desc:(NSString *)desc image:(nonnull NSString *)image link:(nonnull NSString *)link {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;

    UIImage *thumbImage;
    if ([image containsString:@"http://"] || [image containsString:@"https://"]) {
        NSData *thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
        thumbImage = [UIImage imageWithData:thumbData];
    } else {
        thumbImage = [UIImage imageNamed:image];
    }
    [message setThumbImage:thumbImage];

    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = link;
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = type == WeChatTypeFriendCircle ? WXSceneTimeline : WXSceneSession;
    [WXApi sendReq:req completion:^(BOOL success) {
        NSLog(@"sendReq result: %d", success);
    }];
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req {
    NSLog(@"%@", req);
}

- (void)onResp:(BaseResp *)resp {
    NSLog(@"%@", resp);
}
@end
