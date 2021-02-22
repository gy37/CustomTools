//
//  AudioViewController.m
//  CustomTools
//
//  Created by yizhi on 2021/2/22.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioRecordManager.h"
#import "UploadManager.h"
#import <AVKit/AVKit.h>

@interface AudioViewController ()

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)handleRecord:(UIButton *)sender {
    [self startRecord:sender.tag];
}

- (void)startRecord:(NSInteger)type {
    if (type == 1) {//开始录音
        [[AudioRecordManager sharedManager] startRecord];
    } else if (type == 2) {//结束录音
        [[AudioRecordManager sharedManager] stopRecordAndGetMp3File:^(NSString * _Nonnull path) {
            AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
            double duration = CMTimeGetSeconds(audioAsset.duration) * 1000;
            NSLog(@"path: %@, duration: %f", path, duration);
//            [[UploadManager sharedManager] uploadAudioFile:path complete:^(NSString * _Nonnull url) {
//                NSString *jsMethod = [NSString stringWithFormat:@"iosAndroiduploadFile('%.f', '%@')", duration, url];
//                [self.webView evaluateJavaScript:jsMethod completionHandler:^(id _Nullable item, NSError * _Nullable error) {
//                    NSLog(@"%@, %@", item, error);
//                }];
//            }];
        }];
    } else if (type == 3) {//播放录音
        [[AudioRecordManager sharedManager] startPlay];
    } else if (type == 4) {//停止播放录音
        [[AudioRecordManager sharedManager] stopPlay];
    }
}

@end
