//
//  CustomSheetContentView.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/17.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickedButtonAtIndex)(NSInteger index);

@interface CustomSheetContentView : UIView
- (void)setupSheetOriention:(BOOL)isHorizontal titles:(NSArray<NSString *> *)titles images:(NSArray<NSString *> *)images cancel:(SimpleBlock)cancel click:(ClickedButtonAtIndex)click;

@end

NS_ASSUME_NONNULL_END
