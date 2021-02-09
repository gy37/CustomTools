//
//  UISearchBar+Custom.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/9.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UISearchBar (Custom)
- (void)setupFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor;
- (void)setupCancelButton:(NSString *)title;
- (id)getSubViewOfClass:(Class)class;
@end

NS_ASSUME_NONNULL_END
