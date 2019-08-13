//
//  NSBundle+GF.h
//  GFCocoaTools
//
//  Created by zhangliyong on 2017/3/14.
//  Copyright © 2017年 zhangliyong@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Bundle)

+ (UIImage *)bundleImageNamed:(NSString *)name;

@end

@interface NSBundle (GF)

+ (instancetype)cocoaToolsBundle;

- (NSString *)cocoaToolsStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;

- (NSString *)bundleName;

- (NSString *)bundleId;

- (NSString *)bundleShortVersion;

- (NSString *)bundleVersion;

@end

#define GFLocalizedString(key, comment) \
    [[NSBundle cocoaToolsBundle] cocoaToolsStringForKey:(key) value:(key) table:@"Localizable"]
