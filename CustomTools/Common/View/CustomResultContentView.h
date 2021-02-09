//
//  CustomResultContentView.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/3.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomResultContentView : UIView
- (void)setupErrorContent:(NSString *)title message:(NSString *)message cancel:(SimpleBlock)cancel confirm:(SimpleBlock)confirm;
- (void)setupErrorConfirmContent:(NSString *)title message:(NSString *)message cancel:(SimpleBlock)cancel confirm:(SimpleBlock)confirm;

@end

NS_ASSUME_NONNULL_END
