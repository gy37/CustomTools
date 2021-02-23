//
//  AudioRecordManager.m
//  CustomTools
//
//  Created by yuyuyu on 2021/2/22.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "AudioRecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

@interface AudioRecordManager()
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioSession *audioSession;
@property (copy, nonatomic) NSString *recordFilePath;
@property (copy, nonatomic) NSString *mp3FilePath;

@end
@implementation AudioRecordManager
static AudioRecordManager *manager;

+ (instancetype)sharedManager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[AudioRecordManager alloc] init];
    });
    return manager;
}

- (AVAudioSession *)audioSession {
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
        [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    return _audioSession;
}

- (void)startRecord {
   [self.audioSession setActive:YES error:nil];//激活当前应用的音频会话,此时会阻断后台音乐的播放.

    NSDictionary *recordSettings = @{
        AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatLinearPCM],//录音格式
        AVSampleRateKey: @(11025.0),//采样率
        AVNumberOfChannelsKey: @(2),//通道数
        AVLinearPCMBitDepthKey: @(16),//线性采样位数
        AVEncoderAudioQualityKey: @(AVAudioQualityMin)//音频质量,采样质量
    };
    NSError *error = nil;
//        NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *documents = NSTemporaryDirectory();
    self.recordFilePath = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", [NSString getCurrentMillisecond]]];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordFilePath] settings:recordSettings error:&error];
    if (error) NSLog(@"error: %@", error);
    
    //启动或者恢复记录的录音文件
    [self.recorder prepareToRecord];
    [self.recorder record];
    NSLog(@"开始录音");
}

- (void)pauseRecord {
    NSLog(@"暂停录音");
    [self.recorder pause];
}

- (void)stopRecordAndGetMp3File:(GetRecordFile)getFile {
    NSLog(@"结束录音");
    [self.recorder stop];
    self.recorder = nil;
    [self conventFileToMp3AtPath:self.recordFilePath getFile:^(NSString * _Nonnull path) {
        self.mp3FilePath = path;
        if (getFile) {
            getFile(path);
        }
    }];
    [self.audioSession setActive:NO error:nil];//激活当前应用的音频会话,此时会阻断后台音乐的播放.
}

- (void)conventFileToMp3AtPath:(NSString *)path getFile:(GetRecordFile)getFile {
    //tmpUrl是caf文件的路径，并转换成字符串
    NSString *cafFilePath = path;
    //存储mp3文件的路径
    NSString *mp3FilePath = [NSString stringWithFormat:@"%@.mp3",[NSString stringWithFormat:@"%@",[cafFilePath substringToIndex:cafFilePath.length - 4]]];
    @try {
        int read, write;

        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置

        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];

        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);

        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

            fwrite(mp3_buffer, write, 1, mp3);

        } while (read != 0);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        NSLog(@"转换成功");
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        
    }
    @finally {
        if (getFile) {
            getFile(mp3FilePath);
        }
    }
}

- (void)startPlay {
    [self.audioSession setActive:YES error:nil];//激活当前应用的音频会话,此时会阻断后台音乐的播放.
    [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    NSLog(@"播放录音");
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.mp3FilePath] error:&error];
    [self.player prepareToPlay];
    [self.player play];
}

- (void)pausePlay {
    NSLog(@"暂停播放录音");
    [self.player pause];
}

- (void)stopPlay {
    NSLog(@"结束播放录音");
    [self.player stop];
    self.player = nil;
    
    [self.audioSession setActive:NO error:nil];//激活当前应用的音频会话,此时会阻断后台音乐的播放.
}
@end
