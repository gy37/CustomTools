//
//  OpenInstallManager.m
//  WMYLink
//
//  Created by yuyuyu on 2021/2/4.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "OpenInstallManager.h"
#import <OpenInstallSDK.h>

@interface OpenInstallManager()<OpenInstallDelegate>

@end

@implementation OpenInstallManager
static OpenInstallManager *manager;

+ (instancetype)sharedManager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[OpenInstallManager alloc] init];
    });
    return manager;
}

- (void)initWithManager {
    [OpenInstallSDK initWithDelegate:self];
}

- (BOOL)handleOpenUrl:(NSURL *)url {
    return [OpenInstallSDK handLinkURL:url];
}

- (void)continueUserActivity:(NSUserActivity *)activity {
    //处理通过openinstall一键唤起App时传递的数据
    [OpenInstallSDK continueUserActivity:activity];
}

//通过OpenInstall获取已经安装App被唤醒时的参数（如果是通过渠道页面唤醒App时，会返回渠道编号）
-(void)getWakeUpParams:(OpeninstallData *)appData{
    if (appData.data) {//(动态唤醒参数)
        //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
    }
    if (appData.channelCode) {//(通过渠道链接或二维码唤醒会返回渠道编号)
        //e.g.可自己统计渠道相关数据等
    }
    NSLog(@"OpenInstallSDK:\n动态参数：%@;\n渠道编号：%@",appData.data,appData.channelCode);
}
@end
