//
//  NSString+Custom.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/1.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "NSString+Custom.h"
#import <CommonCrypto/CommonCrypto.h>
#import "StorageTool.h"
//#import <GMObjC.h>

@implementation NSString (Custom)
NSString *const HomeCancelLink = @"CancelApply://";
NSString *const HomeApplyLink = @"Apply://";

#pragma mark - special

- (NSAttributedString *)getAttributeString {
    if (!self.length) { return nil; }
    NSRange range = NSMakeRange(0, self.length);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    [attributeString addAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:16],
        NSForegroundColorAttributeName: UIColorFromRGB(0x999999),
        NSParagraphStyleAttributeName: paragraphStyle
    } range:range];
    
    NSString *link = @"";
    NSRange linkRange = NSMakeRange(0, self.length);
    if ([self containsString:@"取消"]) {
        link = HomeCancelLink;
        linkRange = [self rangeOfString:@"取消申请   >"];
    } else {
        link = HomeApplyLink;
        linkRange = [self rangeOfString:@"去申请   >"];
    }
    [attributeString addAttributes:@{
        NSLinkAttributeName: link,
        NSForegroundColorAttributeName: THEME_COLOR
    } range:linkRange];
    return attributeString;
}

- (NSString *)insertSpaceToJustify {
    NSString *newString = self;
    if (self.length == 3) {
        NSString *spaces = @"   ";
        NSString *firstCharacter = [self substringToIndex:1];
        newString = [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%@%@", firstCharacter, spaces]];
    }
    return newString;
}

+ (NSString *)getCountString:(NSInteger)count {
    if (count >= 10000) {
        return [NSString stringWithFormat:@"%.1f万", count / 10000.f];
    } else {
        return [@(count) stringValue];
    }
}

+ (NSString *)getTimeIntervalString:(NSTimeInterval)duration {
    int oneHour = 60 * 60;
    long hour, seconds;
    if (duration >= oneHour) {
        hour = duration / oneHour;
        seconds = (long)duration % oneHour;
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour, seconds / 60, seconds % 60];
    } else {
        seconds = duration;
        return [NSString stringWithFormat:@"%02ld:%02ld", seconds / 60, seconds % 60];
    }
}

#pragma mark - date string

- (NSDate *)dateTimeStringToDate {
    NSDateFormatter *dateFormatter = [NSString getDateFormatter];
    NSDate *date = [dateFormatter dateFromString:self];
    return date;
}

- (NSDate *)endDateTimeStringToDate {
    NSDateFormatter *dateFormatter = [NSString getEndDateFormatter];
    NSDate *date = [dateFormatter dateFromString:self];
    return date;
}

+ (NSString *)getDateString:(NSDate *)date {
    NSString *dateTimeString = [self getDateTimeString:date];
    return [dateTimeString componentsSeparatedByString:@" "].firstObject;
}

+ (NSString *)getTimeString:(NSDate *)date {
    NSString *dateTimeString = [self getDateTimeString:date];
    return [dateTimeString componentsSeparatedByString:@" "].lastObject;
}

+ (NSString *)getTimeStringWithoutSeconds:(NSDate *)date {
    NSString *dateTimeString = [self getDateTimeString:date];
    NSString *timeString = [dateTimeString componentsSeparatedByString:@" "].lastObject;
    NSArray *times = [timeString componentsSeparatedByString:@":"];
    return [NSString stringWithFormat:@"%@:%@", times[0], times[1]];
}

+ (NSString *)getDateTimeString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [self getDateFormatter];
    NSString *string = [dateFormatter stringFromDate:date];
    return string;
}

+ (NSString *)getCurrentMillisecond {
    return [self getMillisecondOfDate:[NSDate date]];
}

+ (NSString *)getMillisecondOfDate:(NSDate *)date {
    double currentTime =  [date timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%.0f", currentTime * 1000];
    return strTime;
}

- (NSDate *)millisecondStringToDate {
    return [NSDate dateWithTimeIntervalSince1970:[self doubleValue] / 1000];
}

#pragma mark - text

- (CGFloat)getTextHeightWithWidth:(CGFloat)width fontSize:(CGFloat)fontSize  {
    return [self getTextHeightWithWidth:width fontSize:fontSize isBold:NO];
}

- (CGFloat)getTextHeightWithWidth:(CGFloat)width fontSize:(CGFloat)fontSize isBold:(BOOL)isBold {
    return [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize weight:isBold ? UIFontWeightMedium : UIFontWeightRegular]} context:nil].size.height;
}

- (CGFloat)getTextWidthWithHeight:(CGFloat)height fontSize:(CGFloat)fontSize {
    return [self getTextWidthWithHeight:height fontSize:fontSize isBold:NO];
}

- (CGFloat)getTextWidthWithHeight:(CGFloat)height fontSize:(CGFloat)fontSize isBold:(BOOL)isBold {
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize weight:isBold ? UIFontWeightMedium : UIFontWeightRegular]} context:nil].size.width;
}

- (BOOL)checkIsSingleLine:(CGFloat)width fontSize:(CGFloat)fontSize {
    return [self checkIsSingleLine:width fontSize:fontSize isBold:NO];
}

- (BOOL)checkIsSingleLine:(CGFloat)width fontSize:(CGFloat)fontSize isBold:(BOOL)isBold {
    CGFloat singleLineHeight = fontSize + 4;
    BOOL isSignleLine = [self getTextHeightWithWidth:width fontSize:fontSize isBold:isBold] <= singleLineHeight;
    return isSignleLine;
}

#pragma mark - login

- (NSString *)getMD5EncryptionString {
    if (!self) return nil;
    const char *cStr = self.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    NSLog(@"md5Str%@", md5Str);
    return md5Str;
}

+ (NSString *)generateCharacterWithLength:(NSInteger)length {
    NSString *letters = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (NSInteger i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((int)letters.length)]];
    }
    NSLog(@"randomString=%@", randomString);
    return randomString;
}

- (NSString *)encryptStringWithSalt:(NSString *)salt {
//    NSString *newString = [NSString stringWithFormat:@"%@%@", self, salt];
//    NSString *security = [GMSm2Utils encryptText:newString publicKey:PUBLIC_KEY];
//    NSString *decode = [GMSm2Utils asn1DecodeToC1C3C2:security];
//    NSString *encrypt = [NSString stringWithFormat:@"%@%@", @"04", decode];
//    return encrypt;
    return @"";
}

+ (NSString *)generateParameterString:(NSDictionary *)params {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:params];
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in param.keyEnumerator) {
        NSString *value = [NSString stringWithFormat:@"%@",[param objectForKey:key]];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    NSString *query = [pairs componentsJoinedByString:@"&"];
    return [NSString stringWithFormat:@"?%@", query];
}

+ (NSString *)getTokenString {
    NSDictionary *tokenInfo = [StorageTool getLocalTokenInfo];
    
    if (tokenInfo) {
        return [NSString stringWithFormat:@"%@ %@", tokenInfo[@"token_type"], tokenInfo[@"access_token"]];
    } else {
        return DEFAULT_TOKEN;
    }
}

+ (NSString *)getAccessTokenString {
    NSString *access_token = [[self getTokenString] componentsSeparatedByString:@" "].lastObject;
    return access_token;
}

#pragma mark - dictionary jsonstring

+ (NSString *)getJsonStringOfDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"getJsonStringOfDictionary error: %@", error);
    }
    return jsonString;
}

+ (NSDictionary *)getDictionaryFromJsonString:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"getDictionaryFromJsonString error: %@", error);
    }
    return dictionary;
}

#pragma mark - private

static NSDateFormatter *dateFormatter;
+ (NSDateFormatter *)getDateFormatter {
    if (!dateFormatter) {//NSDateFormatter内存优化
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    }
    return dateFormatter;
}

static NSDateFormatter *endDateFormatter;
+ (NSDateFormatter *)getEndDateFormatter {
    if (!endDateFormatter) {//NSDateFormatter内存优化
        endDateFormatter = [[NSDateFormatter alloc] init];
        [endDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSzzz"];
    }
    return endDateFormatter;
}

@end
