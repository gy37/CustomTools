//
//  CustomCameraViewController.m
//  WMYLink
//
//  Created by yizhi on 2021/1/7.
//  Copyright © 2021 YiZhi. All rights reserved.
//

#import "CustomCameraViewController.h"
#import "UIButton+Custom.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomImagePreviewViewController.h"
#import "CustomVideoPlayerViewController.h"

@interface CustomCameraViewController ()<AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureDevice *imageDevice;
@property (strong, nonatomic) AVCaptureDevice *backDevice;
@property (strong, nonatomic) AVCaptureDevice *frontDevice;

@property (strong, nonatomic) AVAssetWriter *assetWriter;
@property (strong, nonatomic) AVAssetWriterInput *videoWriterInput;
@property (strong, nonatomic) AVAssetWriterInput *audioWriterInput;
@property (assign, nonatomic) BOOL startRecording;
@property (assign, nonatomic) BOOL startWriting;


@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *videoPath;
@property (strong, nonatomic) NSTimer *videoTimer;
@property (assign, nonatomic) NSTimeInterval videoTimeInterval;
@end

@implementation CustomCameraViewController
const NSTimeInterval videoTimeInterval = 0.1;
const CGFloat videoRectRatio = 16 / 9.0;

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.closeButton setupButtonWithIconName:@"\U0000e62b" iconSize:24 iconColor:[UIColor whiteColor]];
    self.titleLabel.text = @"00:00";
    [self.flashButton setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateSelected];
    
    [self.cameraButton setupButtonWithIconName:@"\U0000e61d" iconSize:24 iconColor:[UIColor whiteColor]];
    if (self.cameraType == CustomCameraTypeImage) {
        [self.photoButton setImage:[UIImage imageNamed:@"photo_button"] forState:UIControlStateNormal];
        [self.photoButton setImage:[UIImage imageNamed:@"photo_button"] forState:UIControlStateSelected];
        self.titleLabel.hidden = YES;
        [self setupImagePreviewController];
    } else {
        [self.photoButton setImage:[UIImage imageNamed:@"video_button"] forState:UIControlStateNormal];
        [self.photoButton setImage:[UIImage imageNamed:@"video_button_selected"] forState:UIControlStateSelected];
        self.titleLabel.hidden = NO;
        [self setupVideoPlayerController];
    }
    if (IS_NOTCH_SCREEN) {
        [self.photoButton updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeBottom constant:50];
        [self.closeButton updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:0];
        [self.titleLabel updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:0];
        [self.flashButton updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:0];
        [self.cameraButton updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:0];
    }
}

- (void)setupValue {
    [self.session beginConfiguration];
    [self setCameraFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    if (self.cameraType == CustomCameraTypeImage) {
        self.imageDevice = self.backDevice;

        AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
        if ([self.session canAddOutput:photoOutput]) {
            [self.session addOutput:photoOutput];
        }
    } else if (self.cameraType == CustomCameraTypeVideo) {
        self.imageDevice = self.backDevice;
        
        NSError *error;
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        if (error) {
            NSLog(@"create audioInput error: %@", error);
        } else {
            if ([self.session canAddInput:audioInput]) {
                [self.session addInput:audioInput];
            }
        }
//        AVCaptureMovieFileOutput *videoOutput = [[AVCaptureMovieFileOutput alloc] init];

        dispatch_queue_t audioQueue = dispatch_queue_create("com.kmelearning.audioDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        if ([self.session canAddOutput:audioOutput]) {
            [self.session addOutput:audioOutput];
        }
        [audioOutput setSampleBufferDelegate:self queue:audioQueue];
        
        dispatch_queue_t videoQueue = dispatch_queue_create("com.kmelearning.videoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        if ([self.session canAddOutput:videoOutput]) {
            [self.session addOutput:videoOutput];
        }
        [videoOutput setSampleBufferDelegate:self queue:videoQueue];
    }
    [self.session commitConfiguration];
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    [self.session startRunning];
}

- (void)dealloc {
    NSLog(@"dealloc");
    for (AVCaptureInput *input in self.session.inputs) {
        [self.session removeInput:input];
    }
    for (AVCaptureOutput *output in self.session.outputs) {
        [self.session removeOutput:output];
    }
    [self.session stopRunning];
    self.session = nil;
    
    if (_videoTimer) {
        [self.videoTimer invalidate];
        self.videoTimer = nil;
    }
    
    if (_assetWriter.status == AVAssetWriterStatusWriting) {
        for (AVAssetWriterInput *writerIntput in _assetWriter.inputs) {
            [writerIntput markAsFinished];
        }
        [_assetWriter finishWritingWithCompletionHandler:^{}];
    }

    [self.previewLayer removeFromSuperlayer];
    for (UIViewController *controller in self.childViewControllers) {
        [controller removeFromParentViewController];
        [controller.view removeFromSuperview];
    }
}

#pragma mark - set get

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]){
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        } else if ([_session canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720]) {
            _session.sessionPreset = AVCaptureSessionPresetiFrame1280x720;
        }
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//AVLayerVideoGravityResize;
        CGRect frame = CGRectMake(0, VIDEO_RECT_TOP, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT - VIDEO_RECT_TOP - VIDEO_RECT_BOTTOM);
        if (IS_NOTCH_SCREEN) {
            if (self.cameraType == CustomCameraTypeImage) {
                frame = CGRectMake(0, NOTCH_SCREEN_VIDEO_RECT_TOP, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT - NOTCH_SCREEN_VIDEO_RECT_TOP - NOTCH_SCREEN_VIDEO_RECT_BOTTOM);
            } else if (self.cameraType == CustomCameraTypeVideo) {
            }
        } else {
            if (self.cameraType == CustomCameraTypeImage) {
            } else if (self.cameraType == CustomCameraTypeVideo) {
                frame = CGRectMake(0, 0, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT);
            }
        }
        
        _previewLayer.frame = frame;
    }
    return _previewLayer;
}

- (AVCaptureDevice *)backDevice {
    if (!_backDevice) {
        _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    return _backDevice;
}

- (AVCaptureDevice *)frontDevice {
    if (!_frontDevice) {
        _frontDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    }
    return _frontDevice;
}

- (void)setImageDevice:(AVCaptureDevice *)imageDevice {
    _imageDevice = imageDevice;
    
    [self.session beginConfiguration];
    for (AVCaptureDeviceInput *input in self.session.inputs) {
        if (input.device.deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera) {
            [self.session removeInput:input];
        }
    }
    NSError *error;
    AVCaptureDeviceInput *imageInput = [AVCaptureDeviceInput deviceInputWithDevice:_imageDevice error:&error];
    if (error) {
        NSLog(@"photoInput init error: %@", error);
    } else {
        if ([self.session canAddInput:imageInput]) {
            [self.session addInput:imageInput];
        }
    }
    [self.session commitConfiguration];
}

- (AVAssetWriter *)assetWriter {
    if (!_assetWriter) {
        NSError *error;
        _assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.videoPath] fileType:AVFileTypeMPEG4 error:&error];
        if (error) {
            NSLog(@"create assetWriter error: %@", error);
            return nil;
        } else {
            //写入视频大小
            NSInteger numPixels = COMMON_SCREEN_WIDTH * COMMON_SCREEN_HEIGHT;

            //每像素比特
            CGFloat bitsPerPixel = 12.0;
            NSInteger bitsPerSecond = numPixels * bitsPerPixel;

            // 码率和帧率设置
            NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                                     AVVideoExpectedSourceFrameRateKey : @(15),
                                                     AVVideoMaxKeyFrameIntervalKey : @(15),
                                                     AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
            CGFloat width = COMMON_SCREEN_HEIGHT;
            CGFloat height = COMMON_SCREEN_WIDTH;
            if (IS_NOTCH_SCREEN) {
                width = COMMON_SCREEN_HEIGHT - VIDEO_RECT_TOP - VIDEO_RECT_BOTTOM;
                height = COMMON_SCREEN_WIDTH;
            }
            //视频属性
            NSDictionary *videoSetting = @{ AVVideoCodecKey : AVVideoCodecH264,
                                               AVVideoWidthKey : @(width * 2),
                                               AVVideoHeightKey : @(height * 2),
                                               AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                               AVVideoCompressionPropertiesKey : compressionProperties };
            NSDictionary *audioSetting = @{ AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                            AVEncoderBitRatePerChannelKey : @(28000),
                                            AVNumberOfChannelsKey : @(1),
                                            AVSampleRateKey : @(22050) };
            self.audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSetting];
            self.audioWriterInput.expectsMediaDataInRealTime = YES;
            if ([_assetWriter canAddInput:self.audioWriterInput]) {
                [_assetWriter addInput:self.audioWriterInput];
            }

            self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSetting];
            self.videoWriterInput.expectsMediaDataInRealTime = YES;
            self.videoWriterInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
            if ([_assetWriter canAddInput:self.videoWriterInput]) {
                [_assetWriter addInput:self.videoWriterInput];
            }
        }
    }
    return _assetWriter;
}

- (NSString *)videoPath {
    if (!_videoPath) {
        _videoPath = [self createVideoFilePath];
    }
    return _videoPath;
}

- (NSTimer *)videoTimer {
    if (!_videoTimer) {
        @weakify(self);
        _videoTimer = [NSTimer timerWithTimeInterval:videoTimeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
            @strongify(self);
            self.videoTimeInterval += videoTimeInterval;
        }];
        [[NSRunLoop currentRunLoop] addTimer:_videoTimer forMode:NSRunLoopCommonModes];
    }
    return _videoTimer;
}

- (void)setVideoTimeInterval:(NSTimeInterval)videoTimeInterval {
    _videoTimeInterval = videoTimeInterval;
    self.titleLabel.text = [NSString getTimeIntervalString:_videoTimeInterval];
}

#pragma mark - selectors

- (IBAction)closeCamera:(UIButton *)sender {

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)switchFlash:(UIButton *)sender {
    sender.selected = !sender.selected;

    if (self.cameraType == CustomCameraTypeImage) {
    } else if (self.cameraType == CustomCameraTypeVideo) {
        [self setCameraTorchMode:sender.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
    }
}

- (IBAction)switchCamera:(UIButton *)sender {
    [self.session stopRunning];

    CATransitionSubtype subtype;
    if (self.imageDevice.position == AVCaptureDevicePositionBack) {
        self.imageDevice = self.frontDevice;
        subtype = kCATransitionFromLeft;
    } else {
        self.imageDevice = self.backDevice;
        subtype = kCATransitionFromRight;
    }

    //模糊效果
    [self.view addBlurEffectTransitionAnimationWithSubtype:subtype];
    
    [self.session startRunning];
}

- (IBAction)takePhoto:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.cameraType == CustomCameraTypeImage) {
        AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{
            AVVideoCodecKey: AVVideoCodecJPEG,
        }];
        settings.flashMode = self.flashButton.isSelected ? AVCaptureFlashModeOn : AVCaptureFlashModeOff;
        for (AVCaptureOutput *output in self.session.outputs) {
            if ([output isKindOfClass:[AVCapturePhotoOutput class]]) {
                AVCapturePhotoOutput *photoOutput = (AVCapturePhotoOutput *)output;
                [photoOutput capturePhotoWithSettings:settings delegate:self];
                break;
            }
        }
    } else if (self.cameraType == CustomCameraTypeVideo) {
        if (sender.isSelected) {
            self.videoPath = nil;
            self.assetWriter = nil;
            [self assetWriter];
            [self.videoTimer setFireDate:[NSDate date]];
            self.startRecording = YES;
        } else {
            if (self.assetWriter.status == AVAssetWriterStatusWriting) {
                [self.session stopRunning];

                for (AVAssetWriterInput *writerIntput in self.assetWriter.inputs) {
                    [writerIntput markAsFinished];
                }
                [self.assetWriter finishWritingWithCompletionHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.childViewControllers.firstObject isKindOfClass:[CustomVideoPlayerViewController class]]) {
                            CustomVideoPlayerViewController *videoPlayerController = (CustomVideoPlayerViewController *)self.childViewControllers.firstObject;
                            videoPlayerController.videoPath = self.videoPath;
                        }
                    });
                }];
                
                [self.videoTimer setFireDate:[NSDate distantFuture]];
                self.videoTimeInterval = 0;
                self.startRecording = NO;
                self.startWriting = NO;
            } else {
                NSLog(@"录制失败，请重试");
            }
        }
//        for (AVCaptureOutput *output in self.session.outputs) {
//            if ([output isKindOfClass:[AVCaptureMovieFileOutput class]]) {
//                AVCaptureMovieFileOutput *videoOutput = (AVCaptureMovieFileOutput *)output;
//                AVCaptureConnection *captureConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
//                if (captureConnection.isVideoStabilizationSupported) {
//                    captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
//                }
//                if (captureConnection.isVideoOrientationSupported) {
//                    captureConnection.videoOrientation = self.previewLayer.connection.videoOrientation;
//                }
//
//                if (sender.isSelected) {
//                    self.videoPath = nil;
//                    [videoOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:self.videoPath] recordingDelegate:self];
//                    [self.videoTimer setFireDate:[NSDate date]];
//                } else {
//                    [videoOutput stopRecording];
//                    [self.videoTimer setFireDate:[NSDate distantFuture]];
//                    self.videoTimeInterval = 0;
//                }
//                break;
//            }
//        }
    }
}

#pragma mark - private

- (NSString *)createVideoFilePath {
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSString getCurrentMillisecond]];
    NSString *recordDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"record/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:recordDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:recordDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [recordDirectory stringByAppendingPathComponent:videoName];
    NSLog(@"videoPath: %@", path);
    return path;
}

- (void)setCameraTorchMode:(AVCaptureTorchMode)torchMode {
    if ([self.imageDevice lockForConfiguration:nil]) {
        if ([self.imageDevice isTorchModeSupported:torchMode]) {
            self.imageDevice.torchMode = torchMode;
        }
        [self.imageDevice unlockForConfiguration];
    }
}

- (void)setCameraFocusMode:(AVCaptureFocusMode)focusMode {
    if ([self.imageDevice lockForConfiguration:nil]) {
        if ([self.imageDevice isFocusModeSupported:focusMode]) {
            [self.imageDevice setFocusMode:focusMode];
        }
        [self.imageDevice unlockForConfiguration];
    }
}

- (void)setupImagePreviewController {
    CustomImagePreviewViewController *imagePreviewController = ViewControllerInStoryboard(NSStringFromClass([CustomImagePreviewViewController class]));
    imagePreviewController.view.frame = self.view.bounds;
    [self addChildViewController:imagePreviewController];
    [self.view addSubview:imagePreviewController.view];
    
    @weakify(self);
    [imagePreviewController setupCloseBlock:^{
    } next:^{
        @strongify(self);
        __block NSString *assetId;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:self.image];
            assetId = changeRequest.placeholderForCreatedAsset.localIdentifier;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                NSLog(@"save asset error: %@", error);
            } else {
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:NULL];
                    if (self.nextBlock && asset) {
                        self.nextBlock(asset);
                    }
                });
            }
        }];
    } retake:^{
        @strongify(self);
        //有删除提示框，不好; 改成拍摄完成不保存，下一步时存
//        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//            [PHAssetChangeRequest deleteAssets:@[self.asset]];
//        } completionHandler:^(BOOL success, NSError * _Nullable error) {
//            if (success) {
//            } else {
//                NSLog(@"delete asset error: %@", error);
//            }
//        }];
        [self.session startRunning];
    }];
}

- (void)setupVideoPlayerController {
    CustomVideoPlayerViewController *videoPlayerController = ViewControllerInStoryboard(NSStringFromClass([CustomVideoPlayerViewController class]));
    videoPlayerController.view.frame = self.view.bounds;
    [self addChildViewController:videoPlayerController];
    [self.view addSubview:videoPlayerController.view];
    
    @weakify(self);
    [videoPlayerController setupCloseBlock:^{
    } next:^{
        @strongify(self);
        __block NSString *assetId;
        [CustomProgressHUD showHUDToView:self.view];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:self.videoPath]];
            assetId = changeRequest.placeholderForCreatedAsset.localIdentifier;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CustomProgressHUD hideHUDForView:self.view];
                if (error) {
                    NSLog(@"save asset error: %@", error);
                    [CustomProgressHUD showTextHUD:@"保存视频文件失败"];
                } else {
                    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                    [self dismissViewControllerAnimated:YES completion:NULL];
                    if (self.nextBlock && asset) {
                        self.nextBlock(asset);
                    }
                }
            });
        }];
    } retake:^{
        @strongify(self);
        [self.session startRunning];
    }];
}


#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error {
    if (photoSampleBuffer) {
        [self.session stopRunning];
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (IS_NOTCH_SCREEN) {
            insets = UIEdgeInsetsMake(NOTCH_SCREEN_VIDEO_RECT_TOP - VIDEO_RECT_TOP, 0, NOTCH_SCREEN_VIDEO_RECT_BOTTOM - VIDEO_RECT_BOTTOM, 0);
        } else {
            insets = UIEdgeInsetsMake(VIDEO_RECT_TOP, 0, VIDEO_RECT_BOTTOM, 0);
        }
        self.image = [UIImage clipCameraPicture:image toInsets:insets];//[UIImage clipImage:image ofRect:CGRectMake(0, videoRectTop, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT - videoRectTop - videoRectBottom)];
        if ([self.childViewControllers.firstObject isKindOfClass:[CustomImagePreviewViewController class]]) {
            CustomImagePreviewViewController *imagePreviewController = (CustomImagePreviewViewController *)self.childViewControllers.firstObject;
            imagePreviewController.previewImage = self.image;
        }
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if (error) {
        [CustomProgressHUD showTextHUD:error.userInfo[@"NSLocalizedDescription"]];
        NSLog(@"finish recording error: %@", error);
    } else {
        [self.session stopRunning];

        if ([self.childViewControllers.firstObject isKindOfClass:[CustomVideoPlayerViewController class]]) {
            CustomVideoPlayerViewController *videoPlayerController = (CustomVideoPlayerViewController *)self.childViewControllers.firstObject;
            videoPlayerController.videoPath = outputFileURL.path;
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"output: %@", output);
    if (!self.startRecording || !CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    CMFormatDescriptionRef desMedia = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(desMedia);
    NSLog(@"status: %ld, mediaType: %u", (long)_assetWriter.status, (unsigned int)mediaType);
    if (mediaType == kCMMediaType_Video) {//audio数据一直都有
        // setup the writer
        if (!self.startWriting && _assetWriter.status == AVAssetWriterStatusUnknown) {
            [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
            [_assetWriter startWriting];
            self.startWriting = YES;
            CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_assetWriter startSessionAtSourceTime:timestamp];
            NSLog(@"started writing with status (%ld)", (long)_assetWriter.status);
        }
    }
    
    // check for completion state
    if (_assetWriter.status == AVAssetWriterStatusFailed) {
        NSLog(@"writer failure, (%@)", _assetWriter.error);
        [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
        return;
    }
 
    if (_assetWriter.status == AVAssetWriterStatusCancelled) {
        NSLog(@"writer cancelled");
        return;
    }
 
    if (_assetWriter.status == AVAssetWriterStatusCompleted) {
        NSLog(@"writer finished and completed");
        return;
    }

    // perform write
    if (self.startWriting && _assetWriter.status == AVAssetWriterStatusWriting) {
        if (mediaType == kCMMediaType_Audio) {
            if (self.audioWriterInput.isReadyForMoreMediaData) {
                BOOL success = [self.audioWriterInput appendSampleBuffer:sampleBuffer];
                if (success) {
                    NSLog(@"AVCaptureAudioDataOutput appendSampleBuffer success");
                } else {
                    NSLog(@"AVCaptureAudioDataOutput appendSampleBuffer error:%@", _assetWriter.error);
                }
            }
        } else if (mediaType == kCMMediaType_Video) {
            if (self.videoWriterInput.isReadyForMoreMediaData) {
                BOOL success = [self.videoWriterInput appendSampleBuffer:sampleBuffer];
                if (success) {
//                    NSLog(@"AVCaptureVideoDataOutput appendSampleBuffer success");
                } else {
                    NSLog(@"AVCaptureVideoDataOutput appendSampleBuffer error:%@", _assetWriter.error);
                }
            }
        }
    }
}

@end
