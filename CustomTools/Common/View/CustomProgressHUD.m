//
//  CustomProgressHUD.m
//  WMYLink
//
//  Created by yizhi on 2020/12/10.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "CustomProgressHUD.h"
#import <MBProgressHUD.h>

@implementation CustomProgressHUD

+ (void)showHUDToView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Loading";
}

+ (void)showProgressHUDToView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;//MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Loading";
}

+ (void)updateProgress:(float)progress inView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    hud.progress = progress;
}

+ (void)showTextHUD:(NSString *)text {
    if ([MBProgressHUD HUDForView:KEY_WINDOW]) {
        [MBProgressHUD hideHUDForView:KEY_WINDOW animated:NO];
    }
    [self showTextHUDToView:KEY_WINDOW withText:text];
}

+ (void)showTextHUDToView:(UIView *)view withText:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:1];
}

+ (void)hideHUDForView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
