//
//  CustomScanViewController.h
//  weimuyunpro
//
//  Created by yuyuyu on 2021/3/18.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomScanViewController : UIViewController

@property (copy, nonatomic) void(^scanResultBlock)(NSString *resultStr);

@end

@interface ScanBackgroundView : UIView
@property (assign, nonatomic) CGRect centerRect;
@end


NS_ASSUME_NONNULL_END
