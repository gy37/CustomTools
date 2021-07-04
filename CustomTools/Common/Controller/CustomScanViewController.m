//
//  WMYNewScanViewController.m
//  weimuyunpro
//
//  Created by yuyuyu on 2021/3/18.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "CustomScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface CustomScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) ScanBackgroundView *backgroundView;
@property (strong, nonatomic) UIImageView *scanRectView;
@property (strong, nonatomic) UIImageView *lineView;
@property (strong, nonatomic) UILabel *tipLabel;
@property (assign, nonatomic) CGRect centerRect;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) CIDetector *detector;
@property (strong, nonatomic) UIBarButtonItem *rightItem;
@end

@implementation CustomScanViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = self.rightItem;//图库按钮
    
    [self setupUI];
    [self setupCaptureSession];
    [self startScan];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [self.videoPreviewLayer removeFromSuperlayer];
    self.videoPreviewLayer = nil;
    [self stopScan];
}

- (void)setupUI {
    CGFloat width = COMMON_SCREEN_WIDTH * 2 / 3;
    CGFloat paddingLeft = (COMMON_SCREEN_WIDTH - width) / 2.0;
    CGFloat paddingTop = (COMMON_SCREEN_HEIGHT - COMMON_NAVIGATION_BAR_HEIGHT - width) / 2.0;
    CGRect scanRect = CGRectMake(paddingLeft, paddingTop, width, width);
    
    self.centerRect = scanRect;

    [self.view.layer addSublayer:self.videoPreviewLayer];
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.scanRectView];
    [self.view addSubview:self.tipLabel];
    self.tipLabel.frame = CGRectMake(20, CGRectGetMaxY(_scanRectView.frame) + 20, CGRectGetWidth(self.view.frame) - 40, 100);
    [self.scanRectView addSubview:self.lineView];
}

- (void)setupCaptureSession {
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:&error];
    if ([self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
    }
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([self.captureSession canAddOutput:captureMetadataOutput]) {
        [self.captureSession addOutput:captureMetadataOutput];
    }
    dispatch_queue_t queue = dispatch_queue_create("com.kmelearning.SCAN_QRCODE_QUEUE", DISPATCH_QUEUE_SERIAL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:queue];
    //设置条码类型:包含 AVMetadataObjectTypeQRCode
    //需要放在addOutput之后，否则availableMetadataObjectTypes为空
    if ([captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        [captureMetadataOutput setMetadataObjectTypes:captureMetadataOutput.availableMetadataObjectTypes];
    }
    //扫描区域
    captureMetadataOutput.rectOfInterest = CGRectMake(CGRectGetMinY(self.centerRect)/CGRectGetHeight(self.view.frame), 1 - CGRectGetMaxX(self.centerRect)/CGRectGetWidth(self.view.frame), CGRectGetHeight(self.centerRect)/CGRectGetHeight(self.view.frame), CGRectGetWidth(self.centerRect)/CGRectGetWidth(self.view.frame));//设置扫描区域。。默认是手机头向左的横屏坐标系（逆时针旋转90度）

}


#pragma mark - lazy loading

- (CIDetector *)detector {
    if (!_detector) {
        _detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    }
    return _detector;
}

- (UIBarButtonItem *)rightItem {//图片名称后加@2x解决iOS导航栏图片变形的问题
    if (!_rightItem) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 38.0, 38.0);
        [button setImage:[UIImage imageNamed:@"scan_photo_pressed"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
        _rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _rightItem;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    if (!_videoPreviewLayer) {
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:self.view.bounds];
    }
    return _videoPreviewLayer;
}

- (AVCaptureDevice *)captureDevice {
    if (!_captureDevice) {
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _captureDevice;
}

- (ScanBackgroundView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[ScanBackgroundView alloc] initWithFrame:self.view.bounds];
        _backgroundView.centerRect = self.centerRect;
    }
    return _backgroundView;
}

- (UIImageView *)scanRectView {
    if (!_scanRectView) {
        _scanRectView = [[UIImageView alloc] initWithFrame:self.centerRect];
        _scanRectView.image = [[UIImage imageNamed:@"scan_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];//该参数的意思是被保护的区域到原始图像外轮廓的上部,左部,底部,右部的直线距离http://www.jianshu.com/p/a577023677c1
        _scanRectView.clipsToBounds = YES;
    }
    return _scanRectView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont boldSystemFontOfSize:16];
        _tipLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = @"请将取景框对准二维码进行扫描";
    }
    return _tipLabel;
}

- (UIImageView *)lineView {
    if (!_lineView) {
        UIImage *lineImage = [UIImage imageNamed:@"scan_line"];
        CGFloat lineHeight = 2;
        CGFloat lineWidth = CGRectGetWidth(_scanRectView.frame);
        _lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -lineHeight, lineWidth, lineHeight)];
        _lineView.contentMode = UIViewContentModeScaleToFill;
        _lineView.image = lineImage;
    }
    return _lineView;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {//判断是否有数据，是否是二维码数据
        __block AVMetadataMachineReadableCodeObject *result = nil;
        [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataMachineReadableCodeObject *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
                result = obj;
                *stop = YES;
            }
        }];
        if (!result) result = [metadataObjects firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![result isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
                return;
            }
            NSString *resultStr = result.stringValue;
            [self stopScan];//停止扫描
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//震动反馈
            if (self.scanResultBlock) {
                [self.navigationController popViewControllerAnimated:YES];
                self.scanResultBlock(resultStr);
            }
        });
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    __block NSString *resultStr = nil;
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    [features enumerateObjectsUsingBlock:^(CIQRCodeFeature *obj, NSUInteger idx, BOOL *stop) {
        if (obj.messageString.length > 0) {
            resultStr = obj.messageString;
            *stop = YES;
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self stopScan];//停止扫描
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//震动反馈
        if (self.scanResultBlock) {
            [self.navigationController popViewControllerAnimated:YES];
            self.scanResultBlock(resultStr);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - private

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isScaning {
    return _videoPreviewLayer.session.isRunning;
}
- (void)startScan {
    if (![self checkCameraAuthorizationStatus]) return;
    [self.captureSession startRunning];
    [self startScanLineAnimation];
}
- (void)stopScan {
    [self.captureSession stopRunning];
    [self stopScanLineAnimation];
}

- (BOOL)checkPhotoLibraryAuthorizationStatus {
    if ([PHPhotoLibrary respondsToSelector:@selector(authorizationStatus)]) {
        if (PHAuthorizationStatusDenied == [PHPhotoLibrary authorizationStatus]) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
            }];
            return NO;
        }
    }
    return YES;
}

- (BOOL)checkCameraAuthorizationStatus {
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        if (AVAuthorizationStatusDenied == [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            
            }];
            return NO;
        }
    }
    
    return YES;
}

-(void)clickRightBarButton:(id)item {
    if (![self checkPhotoLibraryAuthorizationStatus]) {
        return;
    }
    [self stopScan];//停止扫描
    
    UIImagePickerController *picker = [UIImagePickerController new];//UIImagePickerController : UINavigationController
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [picker.navigationBar setShadowImage:nil];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)changeTorchState:(BOOL)isOn {
    if ([self.captureDevice hasTorch]){
        [self.captureDevice lockForConfiguration:nil];
        if (isOn) {
            [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
        } else {
            [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
        }
        [self.captureDevice unlockForConfiguration];
    }
}

- (void)startScanLineAnimation {
    [self stopScanLineAnimation];
    
    CABasicAnimation *scanAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    scanAnimation.fromValue = @(-CGRectGetHeight(_lineView.frame));
    scanAnimation.toValue = @(CGRectGetHeight(_lineView.frame) + CGRectGetHeight(_scanRectView.frame));
    
    scanAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scanAnimation.repeatCount = CGFLOAT_MAX;
    scanAnimation.duration = 2.0;
    [self.lineView.layer addAnimation:scanAnimation forKey:@"basic"];
}

- (void)stopScanLineAnimation {
    [self.lineView.layer removeAllAnimations];
}

@end

@implementation ScanBackgroundView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO; // 设置为透明的
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor colorWithWhite:0 alpha:0.5] setFill]; // 设置颜色为黑色
    // 半透明区域
    UIRectFill(rect);
    // 透明区域
    CGRect clearRect = self.centerRect;
    // 两个视图相交的区域
    CGRect clearIntersection = CGRectIntersection(clearRect, rect);
    // 相交的区域设置为透明
    [[UIColor clearColor] setFill];
    // 把透明视图填充在图片上
    UIRectFill(clearIntersection);
}

@end
