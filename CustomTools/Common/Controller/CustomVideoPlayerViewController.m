//
//  CustomVideoPlayerViewController.m
//  WMYLink
//
//  Created by yuyuyu on 2021/1/4.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "CustomVideoPlayerViewController.h"
#import "UIButton+Custom.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomActionSheet.h"

@interface CustomVideoPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;


@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) id playerTimeObserveToken;

@property (copy, nonatomic) SimpleBlock closeBlock;
@property (copy, nonatomic) SimpleBlock nextBlock;
@property (copy, nonatomic) SimpleBlock retakeBlock;
@end

@implementation CustomVideoPlayerViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupValue];
}

- (void)setupUI {
    self.view.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    [self.closeButton setupButtonWithIconName:@"\U0000e62b" iconSize:24 iconColor:[UIColor whiteColor]];

    self.sliderView.value = 0.0;
    [self.sliderView setThumbImage:[UIImage imageWithColor:[UIColor whiteColor] width:12] forState:UIControlStateNormal];
    [self.sliderView addTarget:self action:@selector(changeSliderValue:) forControlEvents:UIControlEventValueChanged];
    
    self.totalTimeLabel.text = @"00:00";
    self.playTimeLabel.text = @"00:00";
    [self.playButton setupButtonWithIconNames:@[@"\U0000e628", @"\U0000e626"] iconSize:32 iconColor:[UIColor whiteColor]];
    
    [self.nextButton setCornerRadiusHalfHeight];
    [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    self.nextButton.backgroundColor = THEME_COLOR;
    
    [self.retakeButton setupButtonWithTitle:@"重拍" titleSize:14 iconNames:@[@"\U0000e627"] iconSize:14 iconColor:[UIColor whiteColor]];
    [self.retakeButton setupButtonToTopBottomPosition];
    
    [self setupSubviewsForPreview:NO];
    
    if (IS_NOTCH_SCREEN) {
        [self.bottomView updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeBottom constant:50];
        [self.closeButton updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:0];
        [self.titleLabel updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:0];
        [self.nextButton updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:0];
    }
}

- (void)setupValue {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)dealloc {
    NSLog(@"dealloc");
    if (self.playerTimeObserveToken) {
        [self.player removeTimeObserver:self.playerTimeObserveToken];
        self.playerTimeObserveToken = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public

- (void)setVideoPath:(NSString *)videoPath {
    _videoPath = videoPath;
    NSURL *fileUrl;
    if ([videoPath hasPrefix:@"file://"]) {
        fileUrl = [NSURL URLWithString:_videoPath];
    } else {
        fileUrl = [NSURL fileURLWithPath:_videoPath];
    }
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:fileUrl];
    if (self.player.currentItem) {
        [self.player replaceCurrentItemWithPlayerItem:item];
    } else {
        self.player = [AVPlayer playerWithPlayerItem:item];
    }
    [self setupPlayer];
    self.view.hidden = NO;
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
    [self setupSubviewsForPreview:YES];
}

#pragma mark - private

- (void)setupPlayer {
    if (self.player) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        CGRect frame = CGRectMake(0, 0, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT);
        if (IS_NOTCH_SCREEN) {
            frame = CGRectMake(0, VIDEO_RECT_TOP, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT - VIDEO_RECT_TOP - VIDEO_RECT_BOTTOM);
        }
        self.playerLayer.frame = frame;
        [self.view.layer insertSublayer:self.playerLayer atIndex:0];
        
        [self addPlayerTimeObserver];
        
        //currentItem.duration获取不到时长，改用currentItem.asset.duration
        NSTimeInterval total = CMTimeGetSeconds(self.player.currentItem.asset.duration);
        NSString *totalString = [NSString getTimeIntervalString:total];
        self.totalTimeLabel.text = totalString;
        self.titleLabel.text = totalString;
    }
}

- (void)setupSubviewsForPreview:(BOOL)isPreview {
    if (isPreview) {
        self.titleLabel.hidden = NO;
        self.nextButton.hidden = NO;
        self.retakeButton.hidden = NO;
        
        self.playTimeLabel.hidden = YES;
        self.totalTimeLabel.hidden = YES;
    } else {
        self.titleLabel.hidden = YES;
        self.nextButton.hidden = YES;
        self.retakeButton.hidden = YES;
        
        self.playTimeLabel.hidden = NO;
        self.totalTimeLabel.hidden = NO;
    }
}

- (void)addPlayerTimeObserver {
    @weakify(self);
    self.playerTimeObserveToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.01, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self);
        NSTimeInterval total = CMTimeGetSeconds(self.player.currentItem.duration);
        NSTimeInterval current = CMTimeGetSeconds(self.player.currentItem.currentTime);
        self.playTimeLabel.text = [NSString getTimeIntervalString:current];
        self.titleLabel.text = [NSString getTimeIntervalString:total - current];
        float progress = current / total;
        [self.sliderView setValue:progress animated:progress != 0];
    }];
}

- (void)pausePlay {
    self.playButton.selected = NO;
    [self.player pause];
}

- (void)stopPlay {
    [self pausePlay];
    [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
}

- (void)changeSliderValue:(UISlider *)slider {
    AVPlayerItem *item = self.player.currentItem;
    NSTimeInterval time = slider.value * CMTimeGetSeconds(item.asset.duration);
    [item seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

#pragma mark - selector

- (IBAction)closePlayer:(UIButton *)sender {
    if (self.closeBlock) {
        [self pausePlay];
        [CustomActionSheet showActionSheet:CustomActionSheetTypeVertical titles:@[@"退出"] clickedAt:^(NSInteger index) {
            if (index == 0) {
                self.closeBlock();
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        }];
    } else {
        [self stopPlay];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)toNextStep:(UIButton *)sender {
    [self stopPlay];
    if (self.nextBlock) {
        self.nextBlock();
    }
}

- (IBAction)retakeVideo:(UIButton *)sender {
    self.view.hidden = YES;
    [self stopPlay];
    if (self.retakeBlock) {
        self.retakeBlock();
    }
}

- (IBAction)playVideo:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player play];
    } else {
        [self.player pause];
    }
}

@end
