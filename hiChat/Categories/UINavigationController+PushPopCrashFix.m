//
//  UINavigationController+PushPopCrashFix.m
//  hiChat
//
//  Created by Polly polly on 03/04/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "UINavigationController+PushPopCrashFix.h"
#import <objc/runtime.h>

@implementation UINavigationController (PushPopCrashFix)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleMethod(self, @selector(popViewControllerAnimated:), @selector(p_PopViewControllerAnimated:));
        swizzleMethod(self, @selector(pushViewController:animated:), @selector(p_PushViewController:animated:));
    });
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (BOOL)prohibitPushPop {
    return [objc_getAssociatedObject(self, @selector(prohibitPushPop)) boolValue];
}

- (void)setProhibitPushPop:(BOOL) prohibitPushPop {
    objc_setAssociatedObject(self, @selector(prohibitPushPop), @(prohibitPushPop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)p_PopViewControllerAnimated:(BOOL)animated {
    if (self.prohibitPushPop) {
        return nil;
    }
    
    self.prohibitPushPop = YES;
    UIViewController *vc = [self p_PopViewControllerAnimated:animated];
    [CATransaction setCompletionBlock:^{
        self.prohibitPushPop = NO;
    }];
    return vc;
}

- (void)p_PushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.prohibitPushPop) {
        return;
    }
    
    self.prohibitPushPop = YES;
    [self p_PushViewController:viewController animated:animated];
    [CATransaction setCompletionBlock:^{
        self.prohibitPushPop = NO;
    }];
}

@end
