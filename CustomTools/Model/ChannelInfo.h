//
//  ChannelInfo.h
//  WMYLink
//
//  Created by yizhi on 2020/12/9.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChannelInfo : NSObject
@property (assign, nonatomic) long long ID;
@property (copy, nonatomic) NSString *Description;
@property (copy, nonatomic) NSString *logo;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger subscribeNum;
@property (assign, nonatomic) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
