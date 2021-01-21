//
//  UploadManager.h
//  WMYLink
//
//  Created by yizhi on 2020/12/11.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface UploadManager : NSObject
+ (instancetype)sharedManager;
- (void)uploadVideo:(VideoInfo *)video withAddress:(NSString *)address andAuth:(NSString *)auth completion:(SimpleBlock)block;
- (void)uploadImage:(NSString *)imagePath withAddress:(NSString *)address andAuth:(NSString *)auth completion:(SimpleBlock)block;
@end

NS_ASSUME_NONNULL_END
