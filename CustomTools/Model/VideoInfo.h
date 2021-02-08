//
//  VideoInfo.h
//  WMYLink
//
//  Created by yizhi on 2020/12/9.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoInfo : NSObject
@property (copy, nonatomic) NSString *path;
@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *coverUrl;
@property (assign, nonatomic) NSTimeInterval duration;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) NSArray<ChannelInfo *>* channels;

@end

NS_ASSUME_NONNULL_END
