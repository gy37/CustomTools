//
//  CustomProgressHUD.h
//  WMYLink
//
//  Created by yizhi on 2020/12/10.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomProgressHUD : UIView
+ (void)showHUDToView:(UIView *)view;
+ (void)showProgressHUDToView:(UIView *)view;
+ (void)updateProgress:(float)progress inView:(UIView *)view;
+ (void)showTextHUD:(NSString *)text;
+ (void)hideHUDForView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
