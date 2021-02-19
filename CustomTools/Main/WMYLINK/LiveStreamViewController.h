//
//  LiveStreamViewController.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/10.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveStreamViewController : BaseViewController
@property (strong, nonatomic) LiveModel *liveModel;
@end

NS_ASSUME_NONNULL_END
