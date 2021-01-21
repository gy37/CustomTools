//
//  CustomGuideView.m
//  WMYLink
//
//  Created by yizhi on 2021/1/20.
//  Copyright © 2021 YiZhi. All rights reserved.
//

#import "CustomGuideView.h"
@interface CustomGuideView()<UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *backgroundScrollView;
@property (strong, nonatomic) CustomPageControl *topPageControl;

@end
@implementation CustomGuideView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)setupWithImages:(NSArray<NSString *> *)images {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.backgroundScrollView.frame = CGRectMake(0, 0, width, height);
    self.backgroundScrollView.contentSize = CGSizeMake(width * images.count, height);
    [self addSubview:self.backgroundScrollView];
    [self setupScrollViewWithImages:images];
    
    CGFloat x = 0;
    CGFloat y = height - 80;
    self.topPageControl.frame = CGRectMake(x, y, width, 40);
    self.topPageControl.numberOfPages = images.count;
    [self addSubview:self.topPageControl];
    self.topPageControl.currentPage = 0;
    __weak typeof(self) weakSelf = self;
    self.topPageControl.clickedAtIndex = ^(NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        CGPoint contentOffset = CGPointMake(index * strongSelf.backgroundScrollView.frame.size.width, 0);
        [strongSelf.backgroundScrollView setContentOffset:contentOffset animated:YES];
    };
    self.topPageControl.clickedFinish = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf removeFromSuperview];
    };
}

#pragma mark - set get

- (UIScrollView *)backgroundScrollView {
    if (!_backgroundScrollView) {
        _backgroundScrollView = [[UIScrollView alloc] init];
        _backgroundScrollView.delegate = self;
        _backgroundScrollView.pagingEnabled = YES;
        _backgroundScrollView.bouncesZoom = NO;
        _backgroundScrollView.bounces = NO;
        _backgroundScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _backgroundScrollView;
}

- (CustomPageControl *)topPageControl {
    if (!_topPageControl) {
        _topPageControl = [[CustomPageControl alloc] init];
        _topPageControl.currentPageIndicatorWidth = 16;
        _topPageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _topPageControl.pageIndicatorWidth = 8;
        _topPageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.55];
        _topPageControl.pageIndicatorSpace = 12;
    }
    return _topPageControl;
}

#pragma mark - private

- (void)setupScrollViewWithImages:(NSArray<NSString *> *)images {
    for (NSInteger i = 0; i < images.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        CGFloat width = self.backgroundScrollView.frame.size.width;
        CGFloat height = self.backgroundScrollView.frame.size.height;
        CGFloat x = i * self.backgroundScrollView.frame.size.width;
        imageView.frame = CGRectMake(x, 0, width, height);
        imageView.image = [UIImage imageWithContentsOfFile:images[i]];
        [self.backgroundScrollView addSubview:imageView];
    }
}

#pragma mark - uiscrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%@", scrollView);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"%@", scrollView);
    self.topPageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}


@end

@implementation CustomPageControl

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentPage = -1;
    }
    return self;
}

#pragma mark - set get

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    for (NSInteger i = 0; i < numberOfPages; i ++) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake([self calculateOriginX:i], 0, self.pageIndicatorWidth, self.pageIndicatorWidth);
        view.backgroundColor = self.pageIndicatorTintColor;
        view.layer.cornerRadius = view.frame.size.height / 2.0;
        view.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self   action:@selector(clickPageIndicator:)];
        [view addGestureRecognizer:tap];
        [self addSubview:view];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage != -1 && currentPage == _currentPage) {
        return;
    }
    _currentPage = currentPage;
    for (NSInteger i = 0; i < self.numberOfPages; i ++) {
        UIView *subview = [self.subviews objectAtIndex:i];
        if (i == currentPage) {
            CGRect frame = subview.frame;
            frame.origin.x = frame.origin.x - frame.size.width / 2;
            frame.size.width = self.currentPageIndicatorWidth;
            subview.frame = frame;
            subview.backgroundColor = self.currentPageIndicatorTintColor;
        } else {
            CGRect frame = subview.frame;
            frame.origin.x = [self calculateOriginX:i];
            frame.size.width = self.pageIndicatorWidth;
            subview.frame = frame;
            subview.backgroundColor = self.pageIndicatorTintColor;
        }
        if (currentPage == self.numberOfPages - 1) {
            subview.hidden = YES;
        } else {
            subview.hidden = NO;
        }
    }
    
    if (!self.finishButton) {
        self.finishButton = [self createFinishButton];
    }
    self.finishButton.hidden = currentPage != self.numberOfPages - 1;
}

#pragma mark - private

- (CGFloat)calculateOriginX:(NSInteger)index {
    CGFloat left = (self.frame.size.width - (self.pageIndicatorWidth + self.pageIndicatorSpace) * (self.numberOfPages - 1) - self.pageIndicatorWidth) / 2;
    CGFloat originX = left + index * (self.pageIndicatorWidth + self.pageIndicatorSpace);
    return originX;
}

- (UIButton *)createFinishButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.frame.size.width - 160) / 2, 0, 160, 40);
    button.layer.cornerRadius = button.frame.size.height / 2;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.5;
    [button setTitle:@"立即体验" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    [button addTarget:self action:@selector(clickFinish) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)clickPageIndicator:(UITapGestureRecognizer *)tap {
    self.currentPage = [self.subviews indexOfObject:tap.view];
    if (self.clickedAtIndex) {
        self.clickedAtIndex(self.currentPage);
    }
}

- (void)clickFinish {
    if (self.clickedFinish) {
        self.clickedFinish();
    }
}

@end
