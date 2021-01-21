//
//  CustomImagePickerController.h
//  WMYLink
//
//  Created by 高申宇 on 2020/12/7.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TZImagePickerController.h>

typedef NS_ENUM(NSInteger, CustomImagePickerType) {
    CustomImagePickerTypeLiveCoverImage,
    CustomImagePickerTypeVideoCoverImage,
    CustomImagePickerTypeVideo
};

NS_ASSUME_NONNULL_BEGIN

//UIImagePickerController系统默认图片选择器，样式不能修改，使用TZImagePickerController
//需要使用controller对象，不适合用单例的方式封装
@interface CustomImagePickerController : TZImagePickerController
- (instancetype)initWithType:(CustomImagePickerType)type;
@property (copy, nonatomic) SimpleBlock cancelSelect;
@end

NS_ASSUME_NONNULL_END
