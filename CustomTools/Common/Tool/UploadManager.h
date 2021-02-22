//
//  UploadManager.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/11.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface UploadManager : NSObject
+ (instancetype)sharedManager;
- (void)uploadVideo:(VideoInfo *)video withAddress:(NSString *)address andAuth:(NSString *)auth completion:(SimpleBlock)block;
- (void)uploadImage:(NSString *)imagePath withAddress:(NSString *)address andAuth:(NSString *)auth completion:(SimpleBlock)block;
- (void)uploadAudioFile:(NSString *)filePath complete:(void (^)(NSString *url))complete;

- (void)uploadFileThroughOSS:(NSString *)filePath;
@end

NS_ASSUME_NONNULL_END
