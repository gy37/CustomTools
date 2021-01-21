//
//  UIFont+Custom.m
//  WMYLink
//
//  Created by yizhi on 2021/1/4.
//  Copyright © 2021 YiZhi. All rights reserved.
//

#import "UIFont+Custom.h"

@implementation UIFont (Custom)

#pragma mark - method swizzle

+ (void)load {
    static dispatch_once_t fontToken;
    dispatch_once(&fontToken, ^{
        [self exchangeClassMethod:@selector(systemFontOfSize:) withMethod:@selector(adapterSystemFontOfSize:)];
        [self exchangeClassMethod:@selector(systemFontOfSize:weight:) withMethod:@selector(adapterSystemFontOfSize:weight:)];
    });
}

+ (UIFont *)adapterSystemFontOfSize:(CGFloat)size {
    CGFloat adapterSize = [self getAdapterFontSize:size];
    return [self adapterSystemFontOfSize:adapterSize];
}

+ (UIFont *)adapterSystemFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    CGFloat adapterSize = [self getAdapterFontSize:size];
    return [self adapterSystemFontOfSize:adapterSize weight:weight];
}

+ (CGFloat)getAdapterFontSize:(CGFloat)size {
    CGFloat adapterSize = size;
    if (IS_NOTCH_SCREEN) {
        adapterSize = size + 2;
    } else if (IS_BIG_SCREEN) {
        adapterSize = size + 1;
    } else {
        adapterSize = size;
    }
//    NSLog(@"size %f, adapter %f", size, adapterSize);
    return adapterSize;
}

@end
