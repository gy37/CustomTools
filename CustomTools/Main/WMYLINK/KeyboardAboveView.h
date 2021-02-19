//
//  KeyboardAboveView.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/18.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SendText)(NSString *text);
@interface KeyboardAboveView : UIView
@property (copy, nonatomic) SendText sendText;
@end

NS_ASSUME_NONNULL_END
