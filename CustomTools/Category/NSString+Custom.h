//
//  NSString+Custom.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/1.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString *const HomeCancelLink;
extern NSString *const HomeApplyLink;

@interface NSString (Custom)
- (NSAttributedString *)getAttributeString;
- (NSString *)insertSpaceToJustify;

- (NSDate *)dateTimeStringToDate;//yyyy-MM-dd HH:mm
- (NSDate *)endDateTimeStringToDate;//yyyy-MM-dd HH:mm:ss.SSSzzz
+ (NSString *)getDateTimeString:(NSDate *)date;//yyyy-MM-dd HH:mm
+ (NSString *)getDateString:(NSDate *)date;//yyyy-MM-dd
+ (NSString *)getTimeString:(NSDate *)date;//HH:mm
+ (NSString *)getTimeStringWithoutSeconds:(NSDate *)date;//HH:mm
+ (NSString *)getMillisecondOfDate:(NSDate *)date;
+ (NSString *)getCurrentMillisecond;
- (NSDate *)millisecondStringToDate;

- (CGFloat)getTextHeightWithWidth:(CGFloat)width fontSize:(CGFloat)fontSize;
- (CGFloat)getTextHeightWithWidth:(CGFloat)width fontSize:(CGFloat)fontSize isBold:(BOOL)isBold;
- (CGFloat)getTextWidthWithHeight:(CGFloat)height fontSize:(CGFloat)fontSize;
- (CGFloat)getTextWidthWithHeight:(CGFloat)height fontSize:(CGFloat)fontSize isBold:(BOOL)isBold;
- (BOOL)checkIsSingleLine:(CGFloat)width fontSize:(CGFloat)fontSize;
- (BOOL)checkIsSingleLine:(CGFloat)width fontSize:(CGFloat)fontSize isBold:(BOOL)isBold;

+ (NSString *)getCountString:(NSInteger)count;
+ (NSString *)getTimeIntervalString:(NSTimeInterval)duration;

- (NSString *)getMD5EncryptionString;
- (NSString *)encryptStringWithSalt:(NSString *)salt;
+ (NSString *)generateCharacterWithLength:(NSInteger)length;
+ (NSString *)generateParameterString:(NSDictionary *)params;
+ (NSString *)getTokenString;
+ (NSString *)getAccessTokenString;

+ (NSDictionary *)getDictionaryFromJsonString:(NSString *)jsonString;
+ (NSString *)getJsonStringOfDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
