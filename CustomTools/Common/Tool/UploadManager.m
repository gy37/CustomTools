//
//  UploadManager.m
//  WMYLink
//
//  Created by yizhi on 2020/12/11.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "UploadManager.h"
#import "CustomProgressHUD.h"
#import "NetWorkTool.h"

#import <VODUpload/VODUploadClient.h>
#import <VODUpload/VODUploadModel.h>

@interface UploadManager()
@property (strong, nonatomic) VODUploadClient *uploadClient;

@end
@implementation UploadManager
static UploadManager *manager;

+ (instancetype)sharedManager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[UploadManager alloc] init];
    });
    return manager;
}

- (void)setupUploaderWithAddress:(NSString *)address auth:(NSString *)auth videoId:(NSString *)videoId completion:(SimpleBlock)completion {
    VODUploadClient *client = [[VODUploadClient alloc] init];
    
    OnUploadFinishedListener FinishCallbackFunc = ^(UploadFileInfo* fileInfo, VodUploadResult* result){
        NSLog(@"upload finished callback videoid:%@, imageurl:%@", result.videoId, result.imageUrl);
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomProgressHUD hideHUDForView:KEY_WINDOW];
            if (completion) {
                completion();
            }
        });
    };
    OnUploadFailedListener FailedCallbackFunc = ^(UploadFileInfo* fileInfo, NSString *code, NSString* message){
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomProgressHUD hideHUDForView:KEY_WINDOW];
        });
        NSLog(@"upload failed callback code = %@, error message = %@", code, message);
    };
    OnUploadProgressListener ProgressCallbackFunc = ^(UploadFileInfo* fileInfo, long uploadedSize, long totalSize) {
        NSLog(@"upload progress callback uploadedSize : %li, totalSize : %li", uploadedSize, totalSize);
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomProgressHUD updateProgress:(float)uploadedSize/totalSize inView:KEY_WINDOW];
        });
    };
    OnUploadTokenExpiredListener TokenExpiredCallbackFunc = ^{
        NSLog(@"upload token expired callback.");
        [NetWorkTool postUrlPath:VIDEO_AUTH_REFRESH parameters:@{@"videoId": videoId} success:^(NSDictionary * _Nonnull response) {
            if ([response[@"code"] integerValue] == 1000) {
                //token过期，设置新的上传凭证，继续上传
                [client resumeWithAuth:response[@"data"][@"uploadAuth"]];
            }
        } failed:^(NSError * _Nonnull error) {
        }];
    };
    OnUploadRertyListener RetryCallbackFunc = ^{
        NSLog(@"upload retry begin callback.");
    };
    OnUploadRertyResumeListener RetryResumeCallbackFunc = ^{
        NSLog(@"upload retry end callback.");
    };
    OnUploadStartedListener UploadStartedCallbackFunc = ^(UploadFileInfo* fileInfo) {
        NSLog(@"upload upload started callback.");
        //设置上传地址和上传凭证
        [client setUploadAuthAndAddress:fileInfo uploadAuth:auth uploadAddress:address];
    };
    
    VODUploadListener *listener = [[VODUploadListener alloc] init];
    listener.finish = FinishCallbackFunc;
    listener.failure = FailedCallbackFunc;
    listener.progress = ProgressCallbackFunc;
    listener.expire = TokenExpiredCallbackFunc;
    listener.retry = RetryCallbackFunc;
    listener.retryResume = RetryResumeCallbackFunc;
    listener.started = UploadStartedCallbackFunc;
    [client setListener:listener];
    
    self.uploadClient = client;
}

- (void)uploadVideo:(VideoInfo *)video withAddress:(NSString *)address andAuth:(NSString *)auth completion:(SimpleBlock)block {
    [self setupUploaderWithAddress:address auth:auth videoId:video.ID completion:block];
    VodInfo *vodInfo = [[VodInfo alloc] init];
    vodInfo.title = video.title;
    vodInfo.desc = video.desc;
    vodInfo.cateId = @(0);
    vodInfo.tags = [[video.channels valueForKey:@"title"] componentsJoinedByString:@" "];
    [self.uploadClient addFile:video.path vodInfo:vodInfo];
    [self.uploadClient start];
    dispatch_async(dispatch_get_main_queue(), ^{
        [CustomProgressHUD showProgressHUDToView:KEY_WINDOW];
    });
}

- (void)uploadImage:(NSString *)imagePath withAddress:(NSString *)address andAuth:(NSString *)auth completion:(SimpleBlock)block {
    [self setupUploaderWithAddress:address auth:auth videoId:nil completion:block];
    VodInfo *vodInfo = [[VodInfo alloc] init];
    vodInfo.title = @"title";
    vodInfo.desc =@"desc";
    vodInfo.cateId = @(0);
    vodInfo.tags = @"tags";
    [self.uploadClient addFile:imagePath vodInfo:vodInfo];
    [self.uploadClient start];
    dispatch_async(dispatch_get_main_queue(), ^{
        [CustomProgressHUD showProgressHUDToView:KEY_WINDOW];
    });
}



@end
