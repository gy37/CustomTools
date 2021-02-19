//
//  LivePlayerViewController.m
//  CustomTools
//
//  Created by yuyuyu on 2021/2/19.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "LivePlayerViewController.h"
#import <AliyunPlayer/AliyunPlayer.h>

@interface LivePlayerViewController ()<AVPDelegate>
@property (strong, nonatomic) AliPlayer *player;
@end

@implementation LivePlayerViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPlayer];
}

- (void)setupPlayer {
    UIView *view = [[UIView alloc] init];
    view.frame = self.view.bounds;
    view.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePlayer)];
    [view addGestureRecognizer:tap];
    [self.view addSubview:view];
    
    self.player = [[AliPlayer alloc] init];
    self.player.playerView = view;
    self.player.delegate = self;
    
    AVPUrlSource *source = [[AVPUrlSource alloc] init];
    //https://media.w3.org/2010/05/sintel/trailer.mp4
    source.playerUrl = [NSURL URLWithString:@"http://qt1.alivecdn.com/timeline/testshift.m3u8?auth_key=1594730859-0-0-b71fd57c57a62a3c2b014f24ca2b9da3"];
    [self.player setUrlSource:source];
    [self.player prepare];
}

- (void)dealloc {
    [self.player destroy];
    self.player = nil;
}

#pragma mark - private

- (void)closePlayer {
    [self.player reset];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - avpdelegate

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"onError, errorModel: %@", errorModel.message);
}

- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    NSLog(@"onPlayerEvent, eventType: %lu", (unsigned long)eventType);
    switch (eventType) {
            case AVPEventPrepareDone: {
                // 准备完成
                [self.player start];
            }
                break;
            case AVPEventAutoPlayStart:
                // 自动播放开始事件
                break;
            case AVPEventFirstRenderedStart:
                // 首帧显示
                break;
            case AVPEventCompletion:
                // 播放完成
                break;
            case AVPEventLoadingStart:
                // 缓冲开始
                break;
            case AVPEventLoadingEnd:
                // 缓冲完成
                break;
            case AVPEventSeekEnd:
                // 跳转完成
                break;
            case AVPEventLoopingStart:
                // 循环播放开始
                break;
            default:
                break;
        }
}

- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
//    NSLog(@"onCurrentPositionUpdate, position: %lld", position);
}

- (void)onBufferedPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    NSLog(@"onBufferedPositionUpdate, position: %lld", position);
}

- (void)onTrackReady:(AliPlayer *)player info:(NSArray<AVPTrackInfo *> *)info {
    NSLog(@"onTrackReady, info: %@", info);
}

- (void)onSubtitleShow:(AliPlayer *)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID subtitle:(NSString *)subtitle {
    NSLog(@"onSubtitleShow, subtitle: %@", subtitle);
}



@end
