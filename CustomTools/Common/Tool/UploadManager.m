//
//  UploadManager.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/11.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "UploadManager.h"
#import "CustomProgressHUD.h"
#import "NetWorkTool.h"

#import <VODUpload/VODUploadClient.h>
#import <VODUpload/VODUploadModel.h>
#import <AliyunOSSiOS/OSSService.h>

@interface UploadManager()
@property (strong, nonatomic) VODUploadClient *uploadClient;
@property (strong, nonatomic) OSSClient *ossClient;

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

- (void)uploadAudioFile:(NSString *)filePath complete:(nonnull void (^)(NSString *url))complete {
    NSFileManager *manager = [NSFileManager defaultManager];
    long long fileSize = [[manager attributesOfItemAtPath:filePath error:nil][NSFileSize] longLongValue];
    [NetWorkTool getUrlPath:[NSString stringWithFormat:@"%@/aliyun/upload/policy", BASE_URL] parameters:@{@"t": [NSString getCurrentMillisecond]} success:^(NSDictionary * _Nonnull response) {
        NSLog(@"%@", response);
        if ([response[@"code"] integerValue] == 1000) {
            NSData *data = [[response[@"data"] stringByReplacingOccurrencesOfString:@"\\" withString:@""] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *fileName = [NSString stringWithFormat:@"%@/%@%lld.mp3", dataDict[@"dir"], [NSString getCurrentMillisecond], fileSize];
            NSLog(@"%@", fileName);
            NSDictionary *parameters = @{
                @"Filename": fileName,
                @"key": fileName,
                @"policy": dataDict[@"policy"],
                @"OSSAccessKeyId": dataDict[@"accessid"],
                @"signature": dataDict[@"signature"],
                @"success_action_status": @(200)
            };
            [NetWorkTool uploadFileToPath:dataDict[@"host"] parameters:parameters file:filePath mimeType:@"audio/mpeg3" success:^(NSDictionary * _Nonnull response) {
                NSLog(@"%@", response);
                NSString *url = [NSString stringWithFormat:@"%@/%@", dataDict[@"host"], fileName];
                NSLog(@"%@", url);
            } failed:^(NSError * _Nonnull error) {
                NSLog(@"error: %@", error);
            }];
        }
    } failed:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}


- (void)setupClient {
    NSString *endpoint = @"https://oss-cn-hangzhou.aliyuncs.com";

    // 移动端建议使用STS方式初始化OSSClient。
//    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:@"AccessKeyId" secretKeyId:@"AccessKeySecret" securityToken:@"SecurityToken"];
    id<OSSCredentialProvider> credential = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:@"https://oss-cn-hangzhou.aliyuncs.com"];
    self.ossClient = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
}

- (void)uploadFileThroughOSS:(NSString *)filePath {
    NSLog(@"上传文件");
    if (!self.ossClient) {
        [self setupClient];
    }
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = @"test";
    //objectKey等同于objectName，表示上传文件到OSS时需要指定包含文件后缀在内的完整路径，例如abc/efg/123.jpg。
    put.objectKey = filePath;
    // 直接上传NSData。
//    put.uploadingData = [NSData dataWithContentsOfFile:filePath];
    put.uploadingFileURL = [NSURL fileURLWithPath:filePath];
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    OSSTask * putTask = [self.ossClient putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
    // 等待任务完成。
     [putTask waitUntilFinished];
}

@end
