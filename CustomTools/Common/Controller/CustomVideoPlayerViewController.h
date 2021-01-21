//
//  CustomVideoPlayerViewController.h
//  WMYLink
//
//  Created by yizhi on 2021/1/4.
//  Copyright © 2021 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomVideoPlayerViewController : UIViewController
@property (copy, nonatomic) NSString *videoPath;

- (void)setupCloseBlock:(SimpleBlock)close next:(SimpleBlock)next retake:(SimpleBlock)retake;
@end

NS_ASSUME_NONNULL_END
