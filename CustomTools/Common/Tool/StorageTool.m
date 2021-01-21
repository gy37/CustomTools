//
//  StorageTool.m
//  WMYLink
//
//  Created by 高申宇 on 2020/12/9.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "StorageTool.h"

@implementation StorageTool
NSString *const searchHistoryKey = @"searchHistory";
NSString *const userTokenKey = @"userToken";
NSString *const loginInfoKey = @"loginInfo";

#pragma mark - search

+ (void)saveSearchStringToLocal:(NSString *)string {
    if (string.length == 0) { return; }
    NSArray *localArray = [self getLocalSearchStrings];
    NSMutableArray *newArray;
    if (localArray) {
        newArray = [NSMutableArray arrayWithArray:localArray];
        if ([newArray containsObject:string]) {
            [newArray removeObject:string];
        }
        [newArray insertObject:string atIndex:0];
    } else {
        newArray = [NSMutableArray array];
        [newArray addObject:string];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:searchHistoryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)getLocalSearchStrings {
    return [[NSUserDefaults standardUserDefaults] stringArrayForKey:searchHistoryKey];;
}

+ (void)clearLocalSearchStrings {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:searchHistoryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - token

+ (void)saveTokenInfoToLocal:(NSDictionary *)tokenInfo {
    if (tokenInfo.allKeys.count == 0) { return; }
    [[NSUserDefaults standardUserDefaults] setObject:tokenInfo forKey:userTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)getLocalTokenInfo {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:userTokenKey];;
}

+ (void)clearLocalTokenInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:userTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - login info

+ (void)saveLoginInfoToLocal:(NSDictionary *)info {
    if (info.allKeys.count == 0) { return; }
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:loginInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)getLocalLoginInfo {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:loginInfoKey];;
}

+ (void)clearLocalLoginInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:loginInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - images

+ (NSString *)saveImageToLocal:(UIImage *)image withFormat:(NSString *)format {
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    NSString *dateString = [NSString getCurrentMillisecond];
    NSString *temPath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@.%@", dateString, format]];
    [data writeToFile:temPath atomically:YES];
    return temPath;
}


@end
