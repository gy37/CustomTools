//
//  ChannelInfo.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/9.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "ChannelInfo.h"
#import <MJExtension.h>

@implementation ChannelInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
     return @{
               @"ID" : @"id",
               @"Description": @"description"
              };
}


- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
    BOOL isNullOrNil = NO;
    if ([oldValue isEqual:[NSNull null]] || [oldValue isKindOfClass:[NSNull class]]) {
        isNullOrNil = YES;
    } else if (oldValue == nil){
        isNullOrNil = YES;
    }
    return isNullOrNil ? @"" : oldValue;
}

@end
