//
//  NSObject+Custom.h
//  WMYLink
//
//  Created by 高申宇 on 2020/12/6.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Custom)
+ (void)exchangeInstanceMethod:(SEL)originSelector withMethod:(SEL)newSelector;
+ (void)exchangeClassMethod:(SEL)originSelector withMethod:(SEL)newSelector;

+ (void)printAllMethodsOfClass;
- (void)printAllPropertiesOfObject;

- (void)performSelectorInSuper:(SEL)selector withObject:(id)object;

- (BOOL)isNullOrNil;
- (id)getSafetyObject;
@end

NS_ASSUME_NONNULL_END
