//
//  CustomImagePickerController.m
//  WMYLink
//
//  Created by 高申宇 on 2020/12/7.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "CustomImagePickerController.h"
#import "UIButton+Custom.h"
#import "CustomCameraViewController.h"

@interface CustomImagePickerController ()
@property (assign, nonatomic) CustomImagePickerType type;
@end

@implementation CustomImagePickerController
NSInteger const cameraButtonTag = 10000;

- (instancetype)initWithType:(CustomImagePickerType)type {
    self = [super initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    if (self) {
        self.type = type;
        [self setupTZImagePicker];
    }
    return self;
}

- (void)setupTZImagePicker {
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    // 1.设置目前已经选中的图片数组
    //imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    self.allowTakePicture = self.type != CustomImagePickerTypeVideo; // 在内部显示拍照按钮
    self.allowTakeVideo = self.type == CustomImagePickerTypeVideo;   // 在内部显示拍视频按
//    self.videoMaximumDuration = 10; // 视频最大拍摄时间
    [self setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    // imagePickerVc.autoSelectCurrentWhenDone = NO;
    
    // imagePickerVc.photoWidth = 1600;
    // imagePickerVc.photoPreviewMaxWidth = 1600;
    
    // 2. 在这里设置imagePickerVc的外观
    [self setupNavigationBar];
    self.iconThemeColor = THEME_COLOR;
    self.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    self.oKButtonTitleColorNormal = THEME_COLOR;
    self.showPhotoCannotSelectLayer = YES;
    self.cannotSelectLayerColor = HALF_WHITE_COLOR;
    @weakify(self);
    __block UICollectionView *photoSelectCollectionView;
    [self setAlbumPickerPageUIConfigBlock:^(UITableView *tableView) {
        tableView.hidden = YES;
    }];
    [self setPhotoPickerPageDidLayoutSubviewsBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        @strongify(self);
        bottomToolBar.hidden = YES;
        [self showCustomLeftBarButtonItem];
        [self showCustomRightBarButtonItem];
        collectionView.frame = self.viewControllers.lastObject.view.bounds;
        collectionView.contentSize = CGSizeMake(collectionView.contentSize.width, collectionView.contentSize.height + bottomToolBar.height);
        photoSelectCollectionView = collectionView;
    }];
    [self setPhotoPreviewPageDidLayoutSubviewsBlock:^(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel) {
        @strongify(self);
        [UIApplication sharedApplication].statusBarHidden = NO;
        //toolBar.hidden = YES;//无效，点击就会显示出来
        toolBar.frame = CGRectMake(0, COMMON_SCREEN_HEIGHT, 0, 0);
        backButton.hidden = YES;
        selectButton.frame = CGRectMake(COMMON_SCREEN_WIDTH, 0, 0, 0);;
        
        //自定义导航栏
        NSString *title = self.type == CustomImagePickerTypeVideo ? @"" : @"裁剪封面";
        [self setupCustomNavigationBar:naviBar withTitle:title];
    }];
    [self setAssetCellDidLayoutSubviewsBlock:^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) {
        @strongify(self);
        UIView *controllerView = self.viewControllers.lastObject.view;
        UICollectionView *collectionView;
        for (UIView *view in controllerView.subviews) {
            if ([view isKindOfClass:[UICollectionView class]]) {
                collectionView = (UICollectionView *)view;
                break;
            }
        }
        UIView *cameraCell;
        for (UIView *cell in collectionView.subviews) {
            if ([cell isKindOfClass:NSClassFromString(@"TZAssetCameraCell")]) {
                cameraCell = cell;
                break;
            }
        }
        if (collectionView && cameraCell) {
            UIButton *cameraButton = [cameraCell viewWithTag:cameraButtonTag];
            if (cameraButton) {
            } else {
                cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
                cameraButton.frame = cameraCell.bounds;
                [cameraButton setupButtonWithIconName:@"\U0000e60f" iconSize:36 iconColor:UIColorFromRGB(0x666666)];
                cameraButton.backgroundColor = UIColorFromRGB(0xd1d1d1);
                [cameraButton addTarget:self action:@selector(toCameraController) forControlEvents:UIControlEventTouchUpInside];
                cameraButton.tag = cameraButtonTag;
                [cameraCell addSubview:cameraButton];
            }
        }
    }];
     
    
    // 3. 设置是否可以选择视频/图片/原图
    self.allowPickingVideo = self.type == CustomImagePickerTypeVideo;
    self.allowPickingImage = self.type != CustomImagePickerTypeVideo;
    self.allowPickingOriginalPhoto = YES;
    self.allowPickingGif = NO;
    self.allowPickingMultipleVideo = YES; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    self.sortAscendingByModificationDate = NO;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    // 5. 单选模式,maxImagesCount为1时才生效
    self.showSelectBtn = YES;
    self.allowCrop = YES;
    self.needCircleCrop = NO;
    // 设置竖屏下的裁剪尺寸
    NSInteger width = self.view.width;
    NSInteger height = self.view.height / 2;
    if (self.type == CustomImagePickerTypeLiveCoverImage) {
        height = self.view.width * 3 / 5.0;
    } else if (self.type == CustomImagePickerTypeVideoCoverImage) {
        height = self.view.width * 3 / 5.0;
    }
    NSInteger top = (self.view.height - height) / 2;
    self.cropRect = CGRectMake(0, top, width, height);
    self.scaleAspectFillCrop = YES;
    // 设置横屏下的裁剪尺寸
    // imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    
     [self setCropViewSettingBlock:^(UIView *cropView) {
         cropView.layer.borderColor = [UIColor whiteColor].CGColor;
         cropView.layer.borderWidth = 2.0;
     }];
    
    // imagePickerVc.allowPreview = NO;
    // 自定义导航栏上的返回按钮
    [self setNavLeftBarButtonSettingBlock:^(UIButton *leftButton){
        [leftButton setImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [leftButton setTitle:@"" forState:UIControlStateNormal];
    }];
    // imagePickerVc.delegate = self;
    
    
    // Deprecated, Use statusBarStyle
    // imagePickerVc.isStatusBarDefault = NO;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置是否显示图片序号
    self.showSelectedIndex = NO;
    
    // 设置拍照时是否需要定位，仅对选择器内部拍照有效，外部拍照的，请拷贝demo时手动把pushImagePickerController里定位方法的调用删掉
     self.allowCameraLocation = NO;
    
    // 设置首选语言 / Set preferred language
     self.preferredLanguage = @"zh-Hans";
    
#pragma mark - 到这里为止
    self.photoDefImage = [UIImage imageWithColor:UIColorFromRGB(0xd8d8d8) width:20 andBorderColor:[UIColor whiteColor] borderWidth:2];
    self.photoSelImage = [UIImage imageWithColor:THEME_COLOR width:20 andBorderColor:[UIColor whiteColor] borderWidth:2];
    self.cancelBtnTitleStr = @"";
    self.naviTitleColor = [UIColor clearColor];
    [self setPhotoPickerPageDidRefreshStateBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        @strongify(self);
        [self showCustomRightBarButtonItem];
    }];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark - private

- (void)toCameraController {
    UIStoryboard * mainStoryBoard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomCameraViewController *controller = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CustomCameraViewController"];
    controller.cameraType = self.type == CustomImagePickerTypeVideo ? CustomCameraTypeVideo : CustomCameraTypeImage;
    controller.nextBlock = ^(PHAsset * _Nonnull asset) {
        SEL addSelector = NSSelectorFromString(@"addPHAsset:");
#warning 通过performSelector调用TZPhotoPickerController里面的方法
        if ([self.viewControllers.lastObject respondsToSelector:addSelector]) {
            [self.viewControllers.lastObject performSelector:addSelector withObject:asset];
        }
    };
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - navigation bar

- (void)setupNavigationBar {
    self.navigationBar.barTintColor = THEME_COLOR;
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"picker_bg1"] forBarMetrics:UIBarMetricsDefault];
}

- (void)setupCustomNavigationBar:(UIView *)naviBar withTitle:(NSString *)title {
    CGSize buttonSize = CGSizeMake(62, 26);
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.frame = naviBar.bounds;
    bgImageView.image = [UIImage imageNamed:@"picker_bg1"];
    [naviBar insertSubview:bgImageView atIndex:0];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(10, COMMON_STATUS_BAR_HEIGHT + 10, buttonSize.width, buttonSize.height);
    [leftButton setupButtonWithTitle:@"取消" titleSize:14 iconName:@""];
    [leftButton addTarget:self action:@selector(backToSelect) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(naviBar.width - buttonSize.width - 15, COMMON_STATUS_BAR_HEIGHT + 10, buttonSize.width, buttonSize.height);
    [rightButton setupButtonWithTitle:@"完成" titleSize:14 titleColor:LIGHT_THEME_COLOR];
    [rightButton setCornerRadiusHalfHeight];
    rightButton.backgroundColor = [UIColor whiteColor];
    [rightButton addTarget:self action:@selector(finishSelect) forControlEvents:UIControlEventTouchUpInside];
    [naviBar addSubview:rightButton];
    
    UILabel *centerLabel = [[UILabel alloc] init];
    centerLabel.size = CGSizeMake(buttonSize.width + 20, buttonSize.height);
    centerLabel.center = CGPointMake(naviBar.center.x, rightButton.center.y);
    centerLabel.font = [UIFont systemFontOfSize:14];
    centerLabel.textColor = [UIColor whiteColor];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.text = title;
    [naviBar addSubview:centerLabel];
}

- (void)showCustomLeftBarButtonItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setupButtonWithTitle:@"取消" titleSize:14 iconName:@""];
    [button addTarget:self action:@selector(leftCancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.viewControllers.lastObject.navigationItem.leftBarButtonItem = item;
}

- (void)showCustomRightBarButtonItem {
    UIColor *color = self.selectedModels.count > 0 ? LIGHT_THEME_COLOR : [[UIColor blackColor] colorWithAlphaComponent:0.25];
    
    UIView *view = (UIView *)self.navigationItem.rightBarButtonItem.customView;
    if (view && [view viewWithTag:10000]) {
        UIButton *button = [view viewWithTag:10000];
        if (button) [button setTitleColor:color forState:UIControlStateNormal];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 62, 44)];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake(0, 0, 62, 26);
        button.center = view.center;
        [button setupButtonWithTitle:@"下一步" titleSize:12 titleColor:color];
        [button setCornerRadiusHalfHeight];
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(toPreview) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10000;
        
        [view addSubview:button];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:view];
        self.viewControllers.lastObject.navigationItem.rightBarButtonItem = item;
    }
    self.viewControllers.lastObject.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = self.selectedModels.count > 0;
}

- (void)leftCancel {//左侧按钮改成取消
    if (self.cancelSelect) {
        self.cancelSelect();
    }
    [super cancelButtonClick];
}

- (void)toPreview {//右侧按钮改成下一步
    SEL selector = self.type == CustomImagePickerTypeVideo ? NSSelectorFromString(@"doneButtonClick") : NSSelectorFromString(@"previewButtonClick");
#warning 通过performSelector调用TZPhotoPickerController里面的方法
    if ([self.viewControllers.lastObject respondsToSelector:selector]) {
        [self.viewControllers.lastObject performSelector:selector];
    }
}

- (void)backToSelect {
    [self popViewControllerAnimated:YES];
}

- (void)finishSelect {
    SEL doneSelector = NSSelectorFromString(@"doneButtonClick");
#warning 通过performSelector调用TZPhotoPickerController里面的方法
    if ([self.viewControllers.lastObject respondsToSelector:doneSelector]) {
        [self.viewControllers.lastObject performSelector:doneSelector];
    }
}

@end
