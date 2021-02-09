//
//  LiveManager.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/11.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "LiveManager.h"
//#import <PLMediaStreamingKit/PLMediaStreamingKit.h>
#import <AliLiveSdk/AliLiveSdk.h>
//#import <PLVLiveKit/LFLiveKit.h>

@interface LiveManager()<AliLiveVidePreProcessDelegate, AliLiveDataStatsDelegate, AliLiveRtsDelegate, AliLivePushInfoStatusDelegate>
//<LFLiveSessionDelegate>

//@property (strong, nonatomic) PLMediaStreamingSession *session;

@property (strong, nonatomic) AliLiveEngine *engine;
@property (copy, nonatomic) SimpleBlock startStreamBlock;

//@property (strong, nonatomic) LFLiveSession *liveSession;
@property (assign, nonatomic) BOOL showLog;
@end
@implementation LiveManager
static LiveManager *manager;

+ (instancetype)sharedManager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[LiveManager alloc] init];
    });
    return manager;
}

- (void)setupLiveEnvironmentWithLog:(BOOL)showLog {
#if TARGET_IPHONE_SIMULATOR
#else
//    [PLStreamingEnv initEnv];
//    [PLStreamingEnv setLogLevel:showLog ? LogLevelDebug];
    self.showLog = showLog;
#endif
}

- (void)setupMediaStreamingSession {
#if TARGET_IPHONE_SIMULATOR
#else
//    PLVideoCaptureConfiguration *videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
//    PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
//    PLVideoStreamingConfiguration *videoStreamingConfiguration = [PLVideoStreamingConfiguration defaultConfiguration];
//    PLAudioStreamingConfiguration *audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
//    PLMediaStreamingSession *session = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:nil];
//
//    [session setBeautifyModeOn:YES];
//    session.autoReconnectEnable = YES;
//    self.session = session;
    
    AliLiveConfig *myConfig = [[AliLiveConfig alloc] init];
    myConfig.videoProfile = AliLiveVideoProfile_540P;
    myConfig.videoFPS = 20;
//    myConfig.pauseImage = [UIImage imageNamed:@"background"];
    myConfig.accountID = @"";
    AliLiveEngine *engine = [[AliLiveEngine alloc] initWithConfig:myConfig];
    [engine setAudioSessionOperationRestriction:AliLiveAudioSessionOperationRestrictionDeactivateSession];
    [engine setRtsDelegate:self];
    [engine setStatusDelegate:self];
//    [self.engine setNetworkDelegate:self];
    [engine setVidePreProcessDelegate:self];
    [engine setDataStatsDelegate:self];
    [engine setLogLevel:self.showLog ? AliLiveLogLevelDebug : AliLiveLogLevelNone];
    self.engine = engine;
    
//    LFLiveAudioConfiguration *audioConfig = [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_Medium];
//    LFLiveVideoConfiguration *videoConfig = [[LFLiveVideoConfiguration alloc] init];
//    videoConfig.autorotate = YES;
//    videoConfig.videoSize = CGSizeMake(COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT);
//    videoConfig.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
//    videoConfig.videoFrameRate = 25;
//    videoConfig.videoMaxKeyframeInterval = 50;
//    videoConfig.videoBitRate = 1000 * 1000;  // 1Mkps
//    videoConfig.videoMinBitRate = 900 * 1000;
//    videoConfig.videoMaxBitRate = 1100 * 1000;
//    videoConfig.sessionPreset = LFCaptureSessionPreset540x960;
//
//    LFLiveSession *liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfig videoConfiguration:videoConfig captureType:LFLiveCaptureDefaultMask];
//    liveSession.captureDevicePosition = AVCaptureDevicePositionFront;   // 开启后置摄像头(默认前置)
//    liveSession.delegate = self;
//    liveSession.showDebugInfo = self.showLog;
//    liveSession.reconnectCount = 3;
//    liveSession.reconnectInterval = 3;
//    liveSession.beautyFace = YES;
//    self.liveSession = liveSession;
#endif
}

- (void)startStreamingInController:(UIViewController *)controller toPath:(NSString *)path success:(SimpleBlock)block {
#if TARGET_IPHONE_SIMULATOR
#else
//    if (!self.session) {
//        [self setupMediaStreamingSession];
//    }
//    [controller.view insertSubview:self.session.previewView atIndex:0];
//
//    NSURL *pushUrl = [NSURL URLWithString:path];
//    [self.session startStreamingWithPushURL:pushUrl feedback:^(PLStreamStartStateFeedback feedback) {
//        if (feedback == PLStreamStartStateSuccess) {
//            NSLog(@"Streaming started.");
//            if (block) {
//                block();
//            }
//        } else {
//            NSLog(@"Oops.");
//        }
//     }];

    self.startStreamBlock = block;
    if (!self.engine) {
        [self setupMediaStreamingSession];
    }
    AliLiveRenderView *renderView = [[AliLiveRenderView alloc] init];
    renderView.frame = controller.view.bounds;
    [controller.view insertSubview:renderView atIndex:0];
    [self.engine startPreview:renderView];
    [self.engine setDeviceOrientationMode:AliLiveOrientationModePortrait];
    [self.engine startPushWithURL:path];
    
//    LFLiveStreamInfo *streamInfo = [[LFLiveStreamInfo alloc] init];
//    streamInfo.appVersionInfo = APP_VERSION;
//    [streamInfo setUrl:path];
//    self.liveSession.preView = controller.view;
//    self.liveSession.running = YES;
//    [self.liveSession startLive:streamInfo];
#endif
}

- (void)stopStreaming {
    // 销毁 PLMediaStreamingSession
//    [self.session stopStreaming];
//    self.session.delegate = nil;
//    self.session = nil;
    
    if (self.engine.isPublishing) {
        [self.engine stopPush];
    }
    if (self.engine.isCameraOn) {
        [self.engine stopPreview];
    }
    [self.engine destorySdk];
    self.engine = nil;
    
//    [self.liveSession stopLive];
//    self.liveSession.running = NO;
//    self.liveSession = nil;
}

- (void)toggleCamera {
//    [self.session toggleCamera];
    
    [self.engine switchCamera];
    
}

- (void)pauseStreaming {
    [self.engine pausePush];
}

- (void)resumeStreaming {
    [self.engine resumePush];
}

- (void)stopPush {
    [self.engine stopPush];
}

- (void)startPushWithUrl:(NSString *)url {
    [self.engine startPushWithURL:url];
}

//#pragma mark - PLMediaStreamingSessionDelegate
//
//- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStateDidChange:(PLStreamState)state {
//    NSLog(@"%lu", (unsigned long)state);
//}
//
//- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status {
//    NSLog(@"%@", status);
//}
//
//- (void)mediaStreamingSession:(PLMediaStreamingSession *)session didDisconnectWithError:(NSError *)error {
//    NSLog(@"%@", error);
//}
//
//- (CVPixelBufferRef)mediaStreamingSession:(PLMediaStreamingSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer timingInfo:(CMSampleTimingInfo)timingInfo {
////    NSLog(@"%@", pixelBuffer);
//    return pixelBuffer;
//}
//
//- (AudioBuffer *)mediaStreamingSession:(PLMediaStreamingSession *)session microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer {
////    NSLog(@"%@", audioBuffer);
//    return audioBuffer;
//}


#pragma mark - AliLivePushInfoStatusDelegate

- (void)onLiveSdkWarning:(AliLiveEngine *)publisher warning:(int)warn {

}

/**
 * @brief 如果engine出现error，通过这个回调通知app
 * @param publisher 推流实例对象
 * @param error  Error type
 */
- (void)onLiveSdkError:(AliLiveEngine *)publisher error:(AliLiveError *)error {
    NSLog(@"onLiveSdkError, pushUrl:%@, errorDescription:%@, code:%ld", publisher.livePushURL, error.errorDescription, (long)error.errorCode);
}

/**
 * @brief 推流成功回调，表示开始推流
 * @param publisher 推流实例对象
*/
- (void)onLivePushStarted:(AliLiveEngine *)publisher {
    NSLog(@"onLivePushStarted, pushUrl:%@", publisher.livePushURL);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.startStreamBlock) {
            self.startStreamBlock();
        }
    });
}

- (void)onLivePushStoped:(AliLiveEngine *)publisher {
    NSLog(@"onLivePushStoped");
}

- (void)onPreviewStarted:(AliLiveEngine *)publisher {
    NSLog(@"onPreviewStarted");
}


- (void)onPreviewStoped:(AliLiveEngine *)publisher {
    NSLog(@"onPreviewStoped");
}

- (void)onFirstVideoFramePreviewed:(AliLiveEngine *)publisher {
    NSLog(@"onFirstVideoFramePreviewed");
}

- (void)onBGMStateChanged:(AliLiveEngine *)publisher playState:(AliLiveAudioPlayingStateCode)playState errorCode:(AliLiveAudioPlayingErrorCode)errorCode {

}

#pragma mark - AliLiveVidePreProcessDelegate
/**
 * 在OpenGL线程中回调，在这里可以进行采集图像的二次处理,  如美颜
 * @param texture    纹理ID
 * @param width      纹理的宽度
 * @param height     纹理的高度
 * @param rotate  纹理的角度
 * @return  返回给SDK的纹理
 * 说明：SDK回调出来的纹理类型是GL_TEXTURE_2D，接口返回给SDK的纹理类型也必须是GL_TEXTURE_2D; 该回调在SDK美颜之后. 纹理格式为GL_RGBA
 */
- (int)onTexture:(int)texture width:(int)width height:(int)height rotate:(int)rotate{
    NSLog(@"AliLiveVidePreProcessDelegate -> onTexture");
    return texture;
}

/**
 * 在OpenGL线程中回调，可以在这里释放创建的OpenGL资源
 */
- (void)onTextureDestoryed{
    NSLog(@"AliLiveVidePreProcessDelegate -> onTextureDestoryed");
}

/**
 * 视频采集对象回调，进行采集图像的二次处理
 * @param pixelBuffer 采集图像
 * @return 返回给SDK的处理的图像
 * @note 若实现了该回调请回调有效的图像，若回调图像为nil，sdk会直接显示原采集图像
 */
- (CVPixelBufferRef)onVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer{
    NSLog(@"AliLiveVidePreProcessDelegate -> onVideoPixelBuffer");
    return pixelBuffer;
}


#pragma mark AliLiveDataStatsDelegate 回调
/**
 * @brief 实时数据回调(2s触发一次)
 * @param stats stats
 */
- (void)onLiveTotalStats:(AliLiveEngine *)publisher stats:(AliLiveStats *)stats{
    // TODO  LATER
}

/**
 * @brief 本地视频统计信息(2s触发一次)
 * @param localVideoStats 本地视频统计信息
 * @note SDK每两秒触发一次此统计信息回调
 */
- (void)onLiveLocalVideoStats:(AliLiveEngine *)publisher stats:(AliLiveLocalVideoStats *)localVideoStats{
    NSLog(@"发送码率： %d kbps", (int)localVideoStats.sentBitrate/1000);
    NSLog(@"发送帧率：%d fps",localVideoStats.sentFps);
    NSLog(@"编码帧率：%d",localVideoStats.encodeFps);
}

/**
 * @brief 远端视频统计信息(2s触发一次)
 * @param remoteVideoStats 远端视频统计信息
 */
- (void)onLiveRemoteVideoStats:(AliLiveEngine *)publisher stats:(AliLiveRemoteVideoStats *)remoteVideoStats{
    // TODO  LATER

}

/**
 * @brief 远端音频统计信息(2s触发一次)
 * @param remoteAudioStats 远端视频统计信息
 */
- (void)onLiveRemoteAudioStats:(AliLiveEngine *)publisher stats:(AliLiveRemoteAudioStats *)remoteAudioStats{
    // TODO  LATER

}


//#pragma mark - <LFLiveSessionDelegate>
//
//- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
//    NSLog(@"liveStateDidChange: %lu", (unsigned long)state);
//    switch (state) {
//        case LFLiveStart: {
//            if (self.startStreamBlock) {
//                self.startStreamBlock();
//            }
//            break;
//        }
//        case LFLiveError: {
//            NSLog(@"直播流连接出错");
//            break;
//        }
//        default: {
//            break;
//        }
//    }
//}
//
//- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
//    CGFloat speed = debugInfo.currentBandwidth * 1000.0 / debugInfo.elapsedMilli;
//    NSLog(@"debugInfo uploadSpeed: %f", speed);
//}
//
//- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
//    NSLog(@"LFLiveSocketErrorCode: %lu", (unsigned long)errorCode);
//}

@end
