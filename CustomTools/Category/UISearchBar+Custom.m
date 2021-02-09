//
//  UISearchBar+Custom.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/9.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "UISearchBar+Custom.h"

@implementation UISearchBar (Custom)

- (void)setupFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor {
    self.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
    UITextField *searchTextField;
    if (@available(iOS 13.0, *)) {
        self.searchBarStyle = UISearchBarStyleProminent;
        searchTextField = self.searchTextField;
    } else {
        self.searchBarStyle = UISearchBarStyleMinimal;
        searchTextField = [self getSubViewOfClass:[UITextField class]];
    }
    searchTextField.font = [UIFont systemFontOfSize:fontSize];
    CGFloat cornerRadius = (self.height - 10 * 2) / 2.0 + (searchTextField.font.pointSize - fontSize) * 2;//字体变大后，textfield的大小也变了
    searchTextField.layer.cornerRadius = cornerRadius;
    searchTextField.layer.masksToBounds = YES;
    searchTextField.textColor = textColor;
    
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage iconWithFontSize:18 text:@"\U0000e64f" color:UIColorFromRGB(0x999999)]];
    CGFloat width = IS_NOTCH_SCREEN ? 24 + COMMON_INNER_SPACE : 18 + COMMON_INNER_SPACE;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 18)];
    [leftView addSubview:leftImageView];
    leftImageView.center = leftView.center;
    searchTextField.leftView = leftView;
}

- (void)setupCancelButton:(NSString *)title {
    UIButton *cancelButton = [self getSubViewOfClass:[UIButton class]];
    if (cancelButton) {
        [cancelButton setTitle:title forState:UIControlStateNormal];
    }
}

- (id)getSubViewOfClass:(Class)class {
    id obj = nil;
    for (UIView* subview  in self.subviews.firstObject.subviews) {
        if ([subview isKindOfClass:class]) {
            obj = subview;
            break;
        }
        if ([NSStringFromClass(subview.class) containsString:@"UISearchBarSearchContainerView"]) {
            for (UIView* nextsub  in subview.subviews) {
                if ([nextsub isKindOfClass:class]) {
                    obj = nextsub;
                    break;
                }
            }
        }
    }
    return obj;
}
@end
