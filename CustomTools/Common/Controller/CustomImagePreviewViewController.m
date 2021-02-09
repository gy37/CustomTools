//
//  CustomImagePreviewViewController.m
//  WMYLink
//
//  Created by yuyuyu on 2021/1/7.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "CustomImagePreviewViewController.h"
#import "UIButton+Custom.h"
#import "CustomActionSheet.h"

@interface CustomImagePreviewViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;

@property (copy, nonatomic) SimpleBlock closeBlock;
@property (copy, nonatomic) SimpleBlock nextBlock;
@property (copy, nonatomic) SimpleBlock retakeBlock;
@end

@implementation CustomImagePreviewViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)setupUI {
    self.view.hidden = YES;
    self.centerImageView.userInteractionEnabled = YES;
    CGFloat top = 0;
    if (IS_NOTCH_SCREEN) {
        top = NOTCH_SCREEN_VIDEO_RECT_TOP - NOTCH_SCREEN_VIDEO_RECT_BOTTOM;
    } else {
//        top = COMMON_SCREEN_WIDTH - (COMMON_SCREEN_WIDTH - VIDEO_RECT_TOP - VIDEO_RECT_BOTTOM) - VIDEO_RECT_BOTTOM * 2;
        top = VIDEO_RECT_TOP - VIDEO_RECT_BOTTOM;
    }
    [self.centerImageView updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:top];
    
    [self.closeButton setupButtonWithIconName:@"\U0000e62b" iconSize:24 iconColor:[UIColor whiteColor]];
    [self.nextButton setCornerRadiusHalfHeight];
    [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    self.nextButton.backgroundColor = THEME_COLOR;
    
    UIImage *image = [UIImage iconWithFontSize:16 text:@"\U0000e627"];
    [self.retakeButton setupButtonWithTopImage:image bottomTitle:@"重拍"];
}

- (void)setupValue {
    
}

- (void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark - public

- (void)setPreviewImage:(UIImage *)previewImage {
    _previewImage = previewImage;
    if (self.previewImage) {
        self.centerImageView.image = self.previewImage;
        self.view.hidden = NO;
    }
}

- (void)setupCloseBlock:(SimpleBlock)close next:(SimpleBlock)next retake:(SimpleBlock)retake {
    if (close) {
        self.closeBlock = close;
    }
    if (next) {
        self.nextBlock = next;
    }
    if (retake) {
        self.retakeBlock = retake;
    }
}

#pragma mark - selectors

- (IBAction)closeController:(UIButton *)sender {
    if (self.closeBlock) {
        [CustomActionSheet showActionSheet:CustomActionSheetTypeVertical titles:@[@"退出"] clickedAt:^(NSInteger index) {
            if (index == 0) {
                self.closeBlock();
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)nextStep:(UIButton *)sender {
    if (self.nextBlock) {
        self.nextBlock();
    }
}

- (IBAction)retakePhoto:(UIButton *)sender {
    self.view.hidden = YES;
    if (self.retakeBlock) {
        self.retakeBlock();
    }
}

@end
