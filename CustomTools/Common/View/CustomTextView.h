//
//  CustomTextView.h
//  WMYLink
//
//  Created by yizhi on 2020/12/2.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomLinkTextView : UITextView

@end

typedef void(^TextViewDidChange)(NSString *newValue);

@interface CustomCountTextView : UITextView
@property (copy, nonatomic) NSString *placeholder;
@property (assign, nonatomic) NSInteger maxLength;
@property (copy, nonatomic) TextViewDidChange changeBlock;

@end

NS_ASSUME_NONNULL_END
