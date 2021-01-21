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

@interface CustomCameraViewController ()<AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate>
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
@property (strong, nonatomic) AVCaptureDevice *audioDevice;

@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *videoPath;
@property (strong, nonatomic) NSTimer *videoTimer;
@property (assign, nonatomic) NSTimeInterval videoTimeInterval;
@end

@implementation CustomCameraViewController
const NSTimeInterval videoTimeInterval = 0.1;

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = YES;
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
}

- (void)setupValue {
    [self.session beginConfiguration];
    AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.session canAddOutput:photoOutput]) {
        [self.session addOutput:photoOutput];
    }
    [self setCameraFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    
    if (self.cameraType == CustomCameraTypeVideo) {
        NSError *error;
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice error:&error];
        if (error) {
            NSLog(@"create audioInput error: %@", error);
        } else {
            if ([self.session canAddInput:audioInput]) {
                [self.session addInput:audioInput];
            }
        }
        AVCaptureMovieFileOutput *videoOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([self.session canAddOutput:videoOutput]) {
            [self.session addOutput:videoOutput];
        }
    }
    [self.session commitConfiguration];
    self.imageDevice = self.backDevice;
    
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
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.view.bounds;
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
    if (self.session.inputs.count > 0) {
        [self.session removeInput:self.session.inputs.lastObject];
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

- (AVCaptureDevice *)audioDevice {
    if (!_audioDevice) {
        _audioDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInMicrophone mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
    }
    return _audioDevice;
}

- (NSString *)videoPath {
    if (!_videoPath) {
        NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSString getCurrentMillisecond]];
        NSString *tempDirctory = NSTemporaryDirectory();
        NSString *path = [tempDirctory stringByAppendingPathComponent:videoName];
        NSLog(@"videoPath: %@", path);
        _videoPath = path;
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
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{
        AVVideoCodecKey: AVVideoCodecJPEG,
    }];
    if (self.cameraType == CustomCameraTypeImage) {
        settings.flashMode = self.flashButton.isSelected ? AVCaptureFlashModeOn : AVCaptureFlashModeOff;
        for (AVCaptureOutput *output in self.session.outputs) {
            if ([output isKindOfClass:[AVCapturePhotoOutput class]]) {
                AVCapturePhotoOutput *photoOutput = (AVCapturePhotoOutput *)output;
                [photoOutput capturePhotoWithSettings:settings delegate:self];
                break;
            }
        }
    } else if (self.cameraType == CustomCameraTypeVideo) {
        for (AVCaptureOutput *output in self.session.outputs) {
            if ([output isKindOfClass:[AVCaptureMovieFileOutput class]]) {
                AVCaptureMovieFileOutput *videoOutput = (AVCaptureMovieFileOutput *)output;
                if (sender.isSelected) {
                    self.videoPath = nil;
                    [videoOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:self.videoPath] recordingDelegate:self];
                    [self.videoTimer setFireDate:[NSDate date]];
                } else {
                    [videoOutput stopRecording];
                    [self.videoTimer setFireDate:[NSDate distantFuture]];
                    self.videoTimeInterval = 0;
                }
                break;
            }
        }
    }
}

#pragma mark - private

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
        self.image = image;
        if ([self.childViewControllers.firstObject isKindOfClass:[CustomImagePreviewViewController class]]) {
            CustomImagePreviewViewController *imagePreviewController = (CustomImagePreviewViewController *)self.childViewControllers.firstObject;
            imagePreviewController.previewImage = image;
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

@end
