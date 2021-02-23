//
//  ViewController.m
//  CustomTools
//
//  Created by yuyuyu on 2021/1/21.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "ViewController.h"
#import "CustomCollectionViewCell.h"
#import "CustomCollectionReusableView.h"
#import "LiveStreamViewController.h"
#import "LivePlayerViewController.h"
#import "AudioViewController.h"
#import "CustomGuideView.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *mainCollectionView;
@property (strong, nonatomic) NSDictionary *projects;
@property (strong, nonatomic) NSArray *projectNames;

@end

@implementation ViewController

#pragma mark - set get

- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 8;
        flowLayout.minimumInteritemSpacing = 8;
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, COMMON_NAVIGATION_BAR_HEIGHT, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT - COMMON_NAVIGATION_BAR_HEIGHT) collectionViewLayout:flowLayout];
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        _mainCollectionView.alwaysBounceVertical = YES;
        [_mainCollectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CustomCollectionViewCell class])];
        [_mainCollectionView registerClass:[CustomCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([CustomCollectionReusableView class])];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
    }
    return _mainCollectionView;
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupValues];
}

- (void)setupUI {
    self.navigationItem.title = @"CustomTools ";
    [self.view addSubview:self.mainCollectionView];
}

- (void)setupValues {
    self.projectNames = @[@"WMYLINK", @"WMYCLOUD", @"BTCARD", @"LECAI", @"HYC"];
    self.projects = @{
        @"WMYLINK": @[
                @"选择图片（基于TZImagePickerController，实现自定义选择页面，拍照，视频拍摄页面）",
                @"选择视频（基于TZImagePickerController，实现自定义选择页面，拍照，视频拍摄页面）",
                @"开始直播（使用AliLiveSDK_iOS实现推流）",
                @"观看直播（使用AliPlayer_iOS实现直播播放）"
            ],
        @"WMYCLOUD": @[
                @"录音，音频格式转换，上传到服务器",
                @"WKWebView与原生页面交互",
                @"引导页，滑动切换引导页，点击立即体验进入App"
            ],
        @"BTCARD": @[
            ],
        @"LECAI": @[
            ],
        @"HYC": @[
            ],
    };
}

#pragma mark - private

- (void)selectImage {
    [self showImagePickerType:CustomImagePickerTypeLiveCoverImage andPickImage:^(UIImage * _Nonnull image, NSString * _Nonnull url) {
            
    }];
}

- (void)selectVideo {
    [self showImagePickerAndPickVideo:^(UIImage * _Nonnull cover, NSString * _Nonnull coverPath, NSString * _Nonnull videoPath, NSTimeInterval duration) {
        
    } cancel:^{

    }];
}

- (void)startLive {
    LiveModel *model = [[LiveModel alloc] init];
    model.ID = 1;
    model.accountId = 111;
    model.pushUrl = @"rtmp://anchor.kmelearning.com/app/1356861531207602176?auth_key=1612357572-0-0-178e4bd5bdef179e33e499b602862492";
    LiveStreamViewController *controller = (LiveStreamViewController *)ViewControllerInStoryboard(NSStringFromClass([LiveStreamViewController class]));
    controller.liveModel = model;
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)watchLive {
    LivePlayerViewController *player = [[LivePlayerViewController alloc] init];
    [self presentViewController:player animated:YES completion:NULL];
}

- (void)recordAudio {
    [self performSegueWithIdentifier:@"toAudioRecord" sender:self.view];
}

- (void)handleJavascript {
    [self performSegueWithIdentifier:@"toWebView" sender:self.view];
}

- (void)setupGuideView {
    NSString *appVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:appVersion]) {
        NSString *path1 = @"guide_01.jpg";
        NSString *path2 = @"guide_02.jpg";
        NSString *path3 = @"guide_03.jpg";
        NSString *path4 = @"guide_04.jpg";
        
        CustomGuideView *guideView = [[CustomGuideView alloc] initWithFrame:CGRectMake(0, 0, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT)];
        [guideView setupWithImages:@[path1, path2, path3, path4]];
        [[UIApplication sharedApplication].windows.firstObject addSubview:guideView];
        //使用时去掉下面两行注释
//        [userDefaults setBool:YES forKey:appVersion];
//        [userDefaults synchronize];
    }
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.projectNames.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.projects[self.projectNames[section]] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(COMMON_SCREEN_WIDTH, 44.0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([CustomCollectionReusableView class]) forIndexPath:indexPath];
    view.contentLabel.text = self.projectNames[indexPath.section];
    if (indexPath.section == 0) {
        view.contentLabel.textColor = [UIColor whiteColor];
        view.backgroundColor = THEME_COLOR;
    } else if (indexPath.section == 1) {
        view.contentLabel.textColor = [UIColor blackColor];
        view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    } else {
        view.contentLabel.textColor = [UIColor whiteColor];
        view.backgroundColor = [UIColor purpleColor];
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            return CGSizeMake(COMMON_SCREEN_WIDTH - 8 * 2, 100);
        } else if (indexPath.item == 1) {
            return CGSizeMake(COMMON_SCREEN_WIDTH - 8 * 2 - 40, 100);
        }
    }
    if (indexPath.section == 1 && indexPath.item == 2) {
        return CGSizeMake(COMMON_SCREEN_WIDTH - 8 * 2 - 60, 100);
    }
    return CGSizeMake((COMMON_SCREEN_WIDTH - 8 * 3) / 2.0, 100);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CustomCollectionViewCell class]) forIndexPath:indexPath];
    cell.contentLabel.text = self.projects[self.projectNames[indexPath.section]][indexPath.row];
    if (indexPath.section == 0) {
        cell.contentLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = THEME_COLOR;
    } else if (indexPath.section == 1) {
        cell.contentLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    } else {
        cell.contentLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor purpleColor];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            [self selectImage];
        } else if (indexPath.item == 1) {
            [self selectVideo];
        } else if (indexPath.item == 2) {
            [self startLive];
        } else if (indexPath.item == 3) {
            [self watchLive];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.item == 0) {
            [self recordAudio];
        } else if (indexPath.item == 1) {
            [self handleJavascript];
        } else if (indexPath.item == 2) {
            [self setupGuideView];
        }
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
