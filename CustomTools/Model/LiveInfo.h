//
//  LiveInfo.h
//  WMYLink
//
//  Created by 高申宇 on 2020/12/6.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveInfo : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *cover;
@property (assign, nonatomic) BOOL isBook;
@property (copy, nonatomic) NSString *date;
@property (copy, nonatomic) NSString *time;
@property (assign, nonatomic) int bookState;
@end

NS_ASSUME_NONNULL_END
