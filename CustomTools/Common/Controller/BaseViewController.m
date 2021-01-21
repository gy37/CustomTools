//
//  BaseViewController.m
//  WMYLink
//
//  Created by yizhi on 2020/11/30.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "BaseViewController.h"
#import "UIButton+Custom.h"
#import "CustomAlertView.h"
#import "StorageTool.h"
#import "LoginViewController.h"
#import "VideoViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
const NSInteger itemButtonTag = 10000;

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_COLOR;
    
    if (self.navigationController && self.navigationController.viewControllers.count >= 2) {
        [self setupLeftBarButtonItem];
    }
    [self setClearNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginController) name:UNAUTHORIZED_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isLogin) {
        [self showLoginController];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - event

- (void)logout {
    [CustomAlertView showConfirm:@"确定退出登录吗？" confirmBlock:^{
        [StorageTool clearLocalTokenInfo];
        [self showLoginController];
    }];
}

- (void)leftBarButtonItemClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showLoginController {
    if (![self isKindOfClass:[LoginViewController class]]) {
        UIViewController *loginController = ViewControllerInStoryboard(NSStringFromClass([LoginViewController class]));
        [self presentViewController:loginController animated:YES completion:NULL];
    }
}


#pragma mark - image picker

- (void)showImagePickerType:(CustomImagePickerType)pickerType andPickImage:(ImagePickerCompletion)pickImage {
    CustomImagePickerController *imagePickerController = [[CustomImagePickerController alloc] initWithType:pickerType];
    [imagePickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {//带info 的方法偶尔会返回不包含PHImageFileURLKey
        //使用系统方法，根据asset获取图片信息
        [[PHImageManager defaultManager] requestImageDataForAsset:assets.firstObject options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSLog(@"%@", info);
            
            UIImage *clipedImage = [UIImage clipImage:photos.firstObject];
            NSString *path = [StorageTool saveImageToLocal:clipedImage withFormat:[[info[@"PHImageFileURLKey"] path] componentsSeparatedByString:@"."].lastObject];
            if (pickImage) {
                pickImage(clipedImage, path);
            }
        }];
    }];
    [imagePickerController setImagePickerControllerDidCancelHandle:^{
            
    }];
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)showImagePickerAndPickVideo:(VideoPickerCompletion)pickVideo cancel:(SimpleBlock)cancel {
    CustomImagePickerController *imagePickerController = [[CustomImagePickerController alloc] initWithType:CustomImagePickerTypeVideo];
    imagePickerController.cancelSelect = cancel;
    [imagePickerController setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        [CustomProgressHUD showHUDToView:self.view];
        [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetHighestQuality success:^(NSString *outputPath) {
            [CustomProgressHUD hideHUDForView:self.view];
            NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
            UIImage *clipedImage = [UIImage clipImage:coverImage];
            NSString *path = [StorageTool saveImageToLocal:clipedImage withFormat:@"jpg"];
            NSLog(@"视频封面导出到本地完成,沙盒路径为:%@",path);
            if (pickVideo) {
                pickVideo(clipedImage, path, outputPath, asset.duration);
            }
        } failure:^(NSString *errorMessage, NSError *error) {
            NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
        }];
    }];
    [self presentViewController:imagePickerController animated:NO completion:nil];
}

#pragma mark - navigation bar

- (void)setClearNavigationBar {
    UIImage *placeholderImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:placeholderImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = placeholderImage;
}

- (void)setNormalNavigationBar {
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"picker_bg1"] forBarMetrics:UIBarMetricsDefault];
}

- (void)setupLeftBarButtonItem {
    [self setupLeftBarButtonItemWithTitle:@"返回" iconName:@"\U0000e613"];
}

- (void)setupLeftBarButtonItemWithTitle:(NSString *)title iconName:(NSString *)iconName {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 60, 20);
    button.center = view.center;
    [button setupButtonWithTitle:title titleSize:14 iconName:iconName];
    [button addTarget:self action:@selector(leftBarButtonItemClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)showLogoutBarButtonItem {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 44)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 90, 20);
    button.center = view.center;
    [button setupButtonWithTitle:@"退出登录" titleSize:14 iconName:@"\U0000e617"];
    [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)showCustomRightBarButtonItem:(NSString *)title titleColor:(UIColor *)color {
    if (self.navigationItem.rightBarButtonItem) {
        UIView *view = (UIView *)self.navigationItem.rightBarButtonItem.customView;
        if (view) {
            UIButton *button = [view viewWithTag:itemButtonTag];
            if (button) [button setTitleColor:color forState:UIControlStateNormal];
        }
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 62, 44)];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake(0, 0, 62, 26);
        button.center = view.center;
        [button setupButtonWithTitle:title titleSize:14 titleColor:color];
        [button setCornerRadiusHalfHeight];
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(rightBarButtonItemClicked) forControlEvents:UIControlEventTouchUpInside];
        button.tag = itemButtonTag;
        
        [view addSubview:button];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:view];
        self.navigationItem.rightBarButtonItem = item;
    }
}

#pragma mark - override

- (BOOL)isLogin {
    return [StorageTool getLocalTokenInfo];
}

- (void)rightBarButtonItemClicked {
    //
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    //iOS13 之后手动设置弹出页面全屏
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    if (flag) {//有动画效果时，控制是否是透明导航栏
        if ([self isKindOfClass:[VideoViewController class]]) {
            self.keepNormalNavigationBar = YES;
        }
    }
    
    [super presentViewController:viewControllerToPresent animated:flag completion:^{
        self.keepNormalNavigationBar = NO;
        if (completion) completion();
    }];
}


@end
