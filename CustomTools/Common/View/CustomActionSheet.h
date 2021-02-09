//
//  CustomActionSheet.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/5.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, CustomActionSheetType) {
    CustomActionSheetTypeDateSelect,
    CustomActionSheetTypeTimeSelect,
    CustomActionSheetTypeVertical,
    CustomActionSheetTypeHorizontal,
};
typedef void(^ConfirmSelectBlock)(NSString *string);
typedef void(^ClickedButtonAtIndex)(NSInteger index);


@interface CustomActionSheet : UIView
+ (void)showActionSheet:(CustomActionSheetType)type confirmBlock:(ConfirmSelectBlock)confirm;
//水平按钮个数最多四个
+ (void)showActionSheet:(CustomActionSheetType)type titles:(NSArray<NSString *> *)titles clickedAt:(ClickedButtonAtIndex)clicked;
+ (void)showActionSheet:(CustomActionSheetType)type images:(NSArray<NSString *> *)images titles:(NSArray<NSString *> *)titles clickedAt:(ClickedButtonAtIndex)clicked;
@end

NS_ASSUME_NONNULL_END
