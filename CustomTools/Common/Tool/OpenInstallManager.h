//
//  OpenInstallManager.h
//  WMYLink
//
//  Created by yuyuyu on 2021/2/4.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenInstallManager : NSObject
+ (instancetype)sharedManager;
- (void)initWithManager;
- (BOOL)handleOpenUrl:(NSURL *)url;
- (void)continueUserActivity:(NSUserActivity *)activity;
@end

NS_ASSUME_NONNULL_END
