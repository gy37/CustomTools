//
//  CustomGuideView.h
//  WMYLink
//
//  Created by yizhi on 2021/1/20.
//  Copyright © 2021 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomGuideView : UIView
- (void)setupWithImages:(NSArray<NSString *> *)images;

@end

typedef void(^ClickedAtIndex)(NSInteger index);
typedef void(^ClickedFinish)(void);

@interface CustomPageControl : UIControl
@property (assign, nonatomic) NSInteger numberOfPages;
@property (assign, nonatomic) NSInteger currentPage;
@property (strong, nonatomic) UIColor *pageIndicatorTintColor;
@property (strong, nonatomic) UIColor *currentPageIndicatorTintColor;
@property (assign, nonatomic) CGFloat pageIndicatorWidth;
@property (assign, nonatomic) CGFloat currentPageIndicatorWidth;
@property (assign, nonatomic) CGFloat pageIndicatorSpace;
@property (copy, nonatomic) ClickedAtIndex clickedAtIndex;

@property (assign, nonatomic) UIButton *finishButton;
@property (copy, nonatomic) ClickedFinish clickedFinish;

@end

NS_ASSUME_NONNULL_END
