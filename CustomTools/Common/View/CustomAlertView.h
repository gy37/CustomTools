//
//  CustomAlertView.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/3.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CustomAlertViewType) {
    CustomAlertViewTypeInfo,
    CustomAlertViewTypeConfirm,
    CustomAlertViewTypeError,
    CustomAlertViewTypeSuccess,
    CustomAlertViewTypeErrorConfirm
};

@interface CustomAlertView : UIView
+ (void)showInfo:(NSString *)message confirmBlock:(SimpleBlock)block;
+ (void)showConfirm:(NSString *)message confirmBlock:(SimpleBlock)block;
+ (void)showError:(NSString *)title message:(NSString *)message confirmBlock:(SimpleBlock)block;
+ (void)showErrorConfirm:(NSString *)title message:(NSString *)message confirmBlock:(SimpleBlock)block;

@end

NS_ASSUME_NONNULL_END
