//
//  LiveManager.h
//  WMYLink
//
//  Created by yizhi on 2020/12/11.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveManager : NSObject
+ (instancetype)sharedManager;
- (void)setupLiveEnvironmentWithLog:(BOOL)showLog;
- (void)startStreamingInController:(UIViewController *)controller toPath:(NSString *)path success:(SimpleBlock)block;
- (void)toggleCamera;
- (void)pauseStreaming;
- (void)resumeStreaming;
- (void)stopStreaming;
- (void)stopPush;
- (void)startPushWithUrl:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
