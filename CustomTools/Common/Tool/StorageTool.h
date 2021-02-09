//
//  StorageTool.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/9.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StorageTool : NSObject
+ (void)saveSearchStringToLocal:(NSString *)string;
+ (NSArray *)getLocalSearchStrings;
+ (void)clearLocalSearchStrings;

+ (void)saveTokenInfoToLocal:(NSDictionary *)tokenInfo;
+ (NSDictionary *)getLocalTokenInfo;
+ (void)clearLocalTokenInfo;

+ (void)saveLoginInfoToLocal:(NSDictionary *)info;
+ (NSDictionary *)getLocalLoginInfo;
+ (void)clearLocalLoginInfo;

+ (NSString *)saveImageToLocal:(UIImage *)image withFormat:(NSString *)format;


@end

NS_ASSUME_NONNULL_END
