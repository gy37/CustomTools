//
//  LiveModel.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/15.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveModel : NSObject

@property (assign, nonatomic) long long accountId;
@property (copy, nonatomic) NSString *anchor;
@property (copy, nonatomic) NSString *channel;
@property (assign, nonatomic) long long channelId;
@property (copy, nonatomic) NSString *endTime;
@property (assign, nonatomic) long long ID;
@property (assign, nonatomic) NSUInteger liveStatus;
@property (copy, nonatomic) NSString *logoImage;
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *pullUrl;
@property (copy, nonatomic) NSString *pushUrl;
@property (assign, nonatomic) long long watchNum;
@property (assign, nonatomic) long long liveAdmireCount;
@property (assign, nonatomic) BOOL isScheduleLive;
@property (assign, nonatomic) long long state;
@end

NS_ASSUME_NONNULL_END
