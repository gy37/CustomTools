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

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *mainCollectionView;
@property (strong, nonatomic) NSDictionary *projects;
@end

@implementation ViewController

#pragma mark - set get

- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 8;
        flowLayout.minimumInteritemSpacing = 8;
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
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
    [self.view addSubview:self.mainCollectionView];
}

- (void)setupValues {
    self.projects = @{
        @"WMYLINK": @[
                @"选择图片（基于TZImagePickerController，实现自定义选择页面，拍照，视频拍摄页面）",
                @"选择视频（基于TZImagePickerController，实现自定义选择页面，拍照，视频拍摄页面）",
                @"开始直播（使用AliLiveSDK_iOS实现推流）",
                @"观看直播（使用AliPlayer_iOS实现直播播放）"
            ]
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

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.projects.allKeys.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.projects.allValues[section] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(COMMON_SCREEN_WIDTH, 44.0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([CustomCollectionReusableView class]) forIndexPath:indexPath];
    view.contentLabel.text = self.projects.allKeys[indexPath.section];
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.item == 0 || indexPath.item == 1) {
            return CGSizeMake(COMMON_SCREEN_WIDTH - 8 * 2, 100);
        }
    }
    return CGSizeMake((COMMON_SCREEN_WIDTH - 8 * 3) / 2.0, 100);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CustomCollectionViewCell class]) forIndexPath:indexPath];
    cell.contentLabel.text = self.projects.allValues[indexPath.section][indexPath.row];
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
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}




@end
