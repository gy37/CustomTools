//
//  CustomNavigationViewController.m
//  WMYLink
//
//  Created by yizhi on 2020/11/30.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "CustomNavigationViewController.h"

@interface CustomNavigationViewController ()<UIGestureRecognizerDelegate>

@end

@implementation CustomNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //滑动返回时，页面顶部黑块
//    self.view.backgroundColor = UIColorFromRGB(0x173eff);
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.interactivePopGestureRecognizer]) {
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        } else if ([self.viewControllers.lastObject isKindOfClass:NSClassFromString(@"VideoViewController")]) {
            return NO;
        }
    }
    return YES;
}

@end
