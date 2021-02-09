//
//  UILabel+Custom.m
//  WMYLink
//
//  Created by yuyuyu on 2021/1/4.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "UILabel+Custom.h"

@implementation UILabel (Custom)

#pragma mark - method swizzle

+ (void)load {
    static dispatch_once_t fontToken;
    dispatch_once(&fontToken, ^{
        [self exchangeInstanceMethod:@selector(awakeFromNib) withMethod:@selector(awakeFromNibAndSetFont)];
    });
}

- (void)awakeFromNibAndSetFont {
    CGFloat adapterSize = [UIFont getAdapterFontSize:self.font.pointSize];
    self.font = [UIFont fontWithDescriptor:self.font.fontDescriptor size:adapterSize];
    [self awakeFromNibAndSetFont];
}


@end
