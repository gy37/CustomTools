//
//  NetWorkTool.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/10.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestSuccess)(NSDictionary *response);
typedef void(^RequestFailed)(NSError *error);

@interface NetWorkTool : NSObject
+ (void)getUrlPath:(NSString *)path parameters:(NSDictionary *)parameters success:(RequestSuccess)success failed:(RequestFailed)failed;
+ (void)postUrlPath:(NSString *)path parameters:(NSDictionary *)parameters success:(RequestSuccess)success failed:(RequestFailed)failed;
+ (void)uploadImage:(NSString *)path parameters:(NSDictionary *)parameters image:(UIImage *)image success:(RequestSuccess)success failed:(RequestFailed)failed;

@end

NS_ASSUME_NONNULL_END
