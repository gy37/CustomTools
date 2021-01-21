//
//  NSObject+Custom.m
//  WMYLink
//
//  Created by 高申宇 on 2020/12/6.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "NSObject+Custom.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (Custom)

/**
 [参考链接](https://www.cnblogs.com/iosliu/p/4589315.html)
 注意事项
 Swizzling被普遍认为是一种巫术，容易导致不可预料的行为和结果。尽管不是最安全的，但是如果你采取下面这些措施，method swizzling还是很安全的。
  
 1.始终调用方法的原始实现（除非你有足够的理由不这么做）： API为输入和输出提供规约，但它里面具体的实现其实是个黑匣子，在Method Swizzling过程中不调用它原始的实现可能会破坏一些私有状态，甚至是程序的其他部分。
  
 2.避免冲突：给分类方法加前缀，一定要确保不要让你代码库中其他代码（或是依赖库）在做与你相同的事。
  
 3.理解：只是简单的复制粘贴swizzling代码而不去理解它是怎么运行的，这不仅非常危险，而且还浪费了学习Objective-C运行时的机会。阅读 Objective-C Runtime Reference 和 <objc/rumtime.h> 去理解代码是怎样和为什么这样执行的，努力的用你的理解来消灭你的疑惑。
 */
+ (void)exchangeInstanceMethod:(SEL)originSelector withMethod:(SEL)newSelector {
    Class class = self;
    Method originMethod = class_getInstanceMethod(class, originSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);

    //@return YES if the method was added successfully, otherwise NO
    //*  (for example, the class already contains a method implementation with that name).
    BOOL addSuccess = class_addMethod(class, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (addSuccess) {//如果已经添加了新方法(originSEL + overrideIMP)，就替换overrideSEL的IMP为originIMP
        //* @note This function behaves in two different ways:
        //*  - If the method identified by \e name does not yet exist, it is added as if \c class_addMethod were called.
        //*    The type encoding specified by \e types is used as given.
        //*  - If the method identified by \e name does exist, its \c IMP is replaced as if \c method_setImplementation were called.
        //*    The type encoding specified by \e types is ignored.
        class_replaceMethod(class, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {//交换两个方法的IMP
        //* @note This is an atomic version of the following:
        //*  \code
        //*  IMP imp1 = method_getImplementation(m1);
        //*  IMP imp2 = method_getImplementation(m2);
        //*  method_setImplementation(m1, imp2);
        //*  method_setImplementation(m2, imp1);
        //*  \endcode
        method_exchangeImplementations(originMethod, newMethod);
    }
}

+ (void)exchangeClassMethod:(SEL)originSelector withMethod:(SEL)newSelector {
    Class class = self;
    Method originMethod = class_getClassMethod(class, originSelector);
    Method newMethod = class_getClassMethod(class, newSelector);

    //类方法需要添加到类对象的父类-元类上
    BOOL addSuccess = class_addMethod(object_getClass(class), originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (addSuccess) {
        class_replaceMethod(class, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, newMethod);
    }
}

//* @note To get the class methods of a class, use \c class_copyMethodList(object_getClass(cls), &count).
//* @note To get the implementations of methods that may be implemented by superclasses,
//*  use \c class_getInstanceMethod or \c class_getClassMethod.
+ (void)printAllMethodsOfClass {
    NSLog(@"%@", self);
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    for (int i = 0; i < count; i ++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        const char *selectorName_char = sel_getName(selector);
        NSString *selectorName = [NSString stringWithUTF8String:selectorName_char];
        NSLog(@"method %d: %@", i, selectorName);
    }
    free(methods);
}

- (void)printAllPropertiesOfObject {
    NSLog(@"%@", self);
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i ++) {
        const char *propertyName_char = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:propertyName_char];
        id propertyValue = [self valueForKey:(NSString*)propertyName];
        NSLog(@"property %d: %@---%@", i, propertyName, propertyValue);
    }
    free(properties);
}

- (void)performSelectorInSuper:(SEL)selector withObject:(id)object {
    //objc_msgSendSuper直接发送消息不行，需要设置superReceiver
//    ((void(*)(id, SEL, id))objc_msgSendSuper)(self, selector, object);
    if ([[self superclass] instancesRespondToSelector:selector]) {
        struct objc_super superReceiver = {
            self,
            [self superclass]
        };
        ((void(*)(id, SEL, id))objc_msgSendSuper)((__bridge id)(&superReceiver), selector, object);
    }
}

@end
