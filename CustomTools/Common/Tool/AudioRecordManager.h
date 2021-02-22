//
//  AudioRecordManager.h
//  CustomTools
//
//  Created by yizhi on 2021/2/22.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^GetRecordFile)(NSString *path);

@interface AudioRecordManager : NSObject
+ (instancetype)sharedManager;
- (void)startRecord;
- (void)pauseRecord;
- (void)stopRecordAndGetMp3File:(GetRecordFile)getFile;
- (void)conventFileToMp3AtPath:(NSString *)path getFile:(GetRecordFile)getFile;

- (void)startPlay;
- (void)pausePlay;
- (void)stopPlay;
@end

NS_ASSUME_NONNULL_END
