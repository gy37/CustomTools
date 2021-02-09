//
//  LiveModel.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/15.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "LiveModel.h"
#import <MJExtension.h>

@implementation LiveModel

// 实现这个方法的目的：告诉MJExtension框架模型中的属性名对应着字典的哪个key
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
      return @{
               @"ID" : @"id",
      };
}

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
//    if ([property.name isEqualToString:@"startTime"] || [property.name isEqualToString:@"endTime"]) {
//        return [NSString getMillisecondOfDate:[[oldValue stringByReplacingOccurrencesOfString:@"T" withString:@" "] endDateTimeStringToDate]];
//    }
    
    BOOL isNullOrNil = NO;
    if ([oldValue isEqual:[NSNull null]] || [oldValue isKindOfClass:[NSNull class]]) {
        isNullOrNil = YES;
    } else if (oldValue == nil){
        isNullOrNil = YES;
    }
    if ([property.name isEqualToString:@"liveStatus"] && isNullOrNil) {
        return @(-1);
    }
    return isNullOrNil ? @"" : oldValue;
}

@end
