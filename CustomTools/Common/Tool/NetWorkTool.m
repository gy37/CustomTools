//
//  NetWorkTool.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/10.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "NetWorkTool.h"
#import <AFNetworking.h>
#import "StorageTool.h"

@implementation NetWorkTool
NSString *errorKey = @"com.alamofire.serialization.response.error.data";

+ (void)getUrlPath:(NSString *)path parameters:(NSDictionary *)parameters success:(RequestSuccess)success failed:(RequestFailed)failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *token = [NSString getTokenString];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    NSLog(@"path: %@, parameters: %@, header: %@", path, parameters, token);
    [manager GET:path parameters:parameters headers:NULL progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"response: %@", responseObject);
            if (success) {
                success(responseObject);
            }
            if (responseObject[@"data"] && [responseObject[@"code"] integerValue] != 1000) {
                if (responseObject[@"subMsg"] && [responseObject[@"subMsg"] length] > 0 ) {
                    [CustomProgressHUD showTextHUD:responseObject[@"subMsg"]];
                } else {
                    [CustomProgressHUD showTextHUD:@"发生错误"];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error: %@", error);
            if (failed) {
                failed(error);
            }
            if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                if (response.statusCode == 401) {
                    [StorageTool clearLocalTokenInfo];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UNAUTHORIZED_NOTIFICATION object:nil];
                } else {//500错误的错误信息
                    NSString *hudString = @"发生错误";
                    if ([error.userInfo.allKeys containsObject:errorKey] && error.userInfo[errorKey]) {
                        NSData *errorData = error.userInfo[errorKey];
                        NSDictionary *errorDictionary = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
                        if (errorDictionary && [errorDictionary.allKeys containsObject:@"subMsg"] && [errorDictionary[@"subMsg"] length] > 0) {
                            hudString = errorDictionary[@"subMsg"];
                        } else if (errorDictionary && [errorDictionary.allKeys containsObject:@"error"] && [errorDictionary[@"error"] length] > 0) {
                            hudString = errorDictionary[@"error"];
                        } else {
                            
                        }
                    } else {
                        
                    }
                    [CustomProgressHUD showTextHUD:hudString];
                }
            } else {//NSLocalizedDescription
                NSString *hudString = @"发生错误";
                if (error.userInfo && error.userInfo[@"NSLocalizedDescription"]) {
                    hudString = error.userInfo[@"NSLocalizedDescription"];
                } else {
                    
                }
                [CustomProgressHUD showTextHUD:hudString];
            }
        }];
}

+ (void)postUrlPath:(NSString *)path parameters:(NSDictionary *)parameters success:(RequestSuccess)success failed:(RequestFailed)failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *token = [NSString getTokenString];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    if ([path isEqualToString:USER_LOGIN]) {
        path = [path stringByAppendingString:[NSString generateParameterString:parameters]];
        parameters = @{};
    }
    NSLog(@"path: %@, parameters: %@, header: %@", path, parameters, token);
    [manager POST:path parameters:parameters headers:NULL progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"response: %@", responseObject);
            if (success) {
                success(responseObject);
            }
            if (responseObject[@"data"] && [responseObject[@"code"] integerValue] != 1000) {
                if (responseObject[@"subMsg"] && [responseObject[@"subMsg"] length] > 0 ) {
                    [CustomProgressHUD showTextHUD:responseObject[@"subMsg"]];
                } else {
                    [CustomProgressHUD showTextHUD:@"发生错误"];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error: %@", error);
            if (failed) {
                failed(error);
            }
            if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                if (response.statusCode == 401) {
                    [StorageTool clearLocalTokenInfo];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UNAUTHORIZED_NOTIFICATION object:nil];
                } else {//500错误的错误信息
                    NSString *hudString = @"发生错误";
                    if ([error.userInfo.allKeys containsObject:errorKey] && error.userInfo[errorKey]) {
                        NSData *errorData = error.userInfo[errorKey];
                        NSDictionary *errorDictionary = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
                        if (errorDictionary && [errorDictionary.allKeys containsObject:@"subMsg"] && [errorDictionary[@"subMsg"] length] > 0) {
                            hudString = errorDictionary[@"subMsg"];
                        } else if (errorDictionary && [errorDictionary.allKeys containsObject:@"error"] && [errorDictionary[@"error"] length] > 0) {
                            hudString = errorDictionary[@"error"];
                        } else {
                            
                        }
                    } else {
                        
                    }
                    [CustomProgressHUD showTextHUD:hudString];
                }
            } else {//NSLocalizedDescription
                NSString *hudString = @"发生错误";
                if (error.userInfo && error.userInfo[@"NSLocalizedDescription"]) {
                    hudString = error.userInfo[@"NSLocalizedDescription"];
                } else {
                    
                }
                [CustomProgressHUD showTextHUD:hudString];
            }
        }];
}

+ (void)uploadImage:(NSString *)path parameters:(NSDictionary *)parameters image:(UIImage *)image success:(RequestSuccess)success failed:(RequestFailed)failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *token = [NSString getTokenString];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    NSLog(@"path: %@, parameters: %@, header: %@", path, parameters, token);
    [manager POST:path parameters:parameters headers:NULL constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
            NSString *name = @"image";
            NSString *mime = @"image/jpeg";
            NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [NSString getCurrentMillisecond]];
            [formData appendPartWithFileData:imageData name:name fileName:imageName mimeType:mime];
        } progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"response: %@", responseObject);
            if (success) {
                success(responseObject);
            }
            if (responseObject[@"data"] && [responseObject[@"code"] integerValue] != 1000) {
                if (responseObject[@"subMsg"] && [responseObject[@"subMsg"] length] > 0 ) {
                    [CustomProgressHUD showTextHUD:responseObject[@"subMsg"]];
                } else {
                    [CustomProgressHUD showTextHUD:@"发生错误"];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error: %@", error);
            if (failed) {
                failed(error);
            }
            if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                if (response.statusCode == 401) {
                    [StorageTool clearLocalTokenInfo];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UNAUTHORIZED_NOTIFICATION object:nil];
                } else {//500错误的错误信息
                    NSString *hudString = @"发生错误";
                    if ([error.userInfo.allKeys containsObject:errorKey] && error.userInfo[errorKey]) {
                        NSData *errorData = error.userInfo[errorKey];
                        NSDictionary *errorDictionary = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
                        if (errorDictionary && [errorDictionary.allKeys containsObject:@"subMsg"] && [errorDictionary[@"subMsg"] length] > 0) {
                            hudString = errorDictionary[@"subMsg"];
                        } else if (errorDictionary && [errorDictionary.allKeys containsObject:@"error"] && [errorDictionary[@"error"] length] > 0) {
                            hudString = errorDictionary[@"error"];
                        } else {
                            
                        }
                    } else {
                        
                    }
                    [CustomProgressHUD showTextHUD:hudString];
                }
            } else {//NSLocalizedDescription
                NSString *hudString = @"发生错误";
                if (error.userInfo && error.userInfo[@"NSLocalizedDescription"]) {
                    hudString = error.userInfo[@"NSLocalizedDescription"];
                } else {
                    
                }
                [CustomProgressHUD showTextHUD:hudString];
            }
        }];
}

@end
