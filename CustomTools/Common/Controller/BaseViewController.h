//
//  BaseViewController.h
//  WMYLink
//
//  Created by yizhi on 2020/11/30.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImagePickerController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ImagePickerCompletion)(UIImage *image, NSString *url);
typedef void(^VideoPickerCompletion)(UIImage *cover, NSString *coverPath, NSString *videoPath, NSTimeInterval duration);

@interface BaseViewController : UIViewController
@property (assign, nonatomic) BOOL isLogin;
@property (assign, nonatomic) BOOL keepNormalNavigationBar;
- (void)showLoginController;

- (void)setClearNavigationBar;
- (void)setNormalNavigationBar;

- (void)setupLeftBarButtonItem;
- (void)setupLeftBarButtonItemWithTitle:(NSString *)title iconName:(NSString *)iconName;
- (void)leftBarButtonItemClicked;
- (void)showLogoutBarButtonItem;
- (void)showCustomRightBarButtonItem:(NSString *)title titleColor:(UIColor *)color;
- (void)rightBarButtonItemClicked;

- (void)showImagePickerType:(CustomImagePickerType)pickerType andPickImage:(ImagePickerCompletion)pickImage;
- (void)showImagePickerAndPickVideo:(VideoPickerCompletion)pickVideo cancel:(SimpleBlock)cancel;

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
