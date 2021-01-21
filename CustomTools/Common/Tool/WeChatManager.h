//
//  WeChatManager.h
//  WMYLink
//
//  Created by yizhi on 2021/1/19.
//  Copyright © 2021 YiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, WeChatType) {
    WeChatTypeFriends,
    WeChatTypeFriendCircle
};

@interface WeChatManager : NSObject
+ (instancetype)sharedManager;
- (void)registerApp:(NSString *)appid;
- (BOOL)handleOpenURL:(NSURL *)url;
/**
 分享到微信
 
 @param title    分享的文字标题
 @param desc  分享的文字描述
 @param link   分享的图片URL字符串
 */
- (void)shareToWeChatWithType:(WeChatType)type title:(NSString *)title desc:(NSString *)desc image:(nonnull NSString *)image link:(nonnull NSString *)link ;
@end

NS_ASSUME_NONNULL_END
