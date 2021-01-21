//
//  CustomCameraViewController.h
//  WMYLink
//
//  Created by yizhi on 2021/1/7.
//  Copyright © 2021 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CustomCameraType) {
    CustomCameraTypeImage,
    CustomCameraTypeVideo
};
typedef void(^NextStepAction)(PHAsset *asset);

@interface CustomCameraViewController : UIViewController
@property (copy, nonatomic) NextStepAction nextBlock;
@property (assign, nonatomic) CustomCameraType cameraType;
@end

NS_ASSUME_NONNULL_END
