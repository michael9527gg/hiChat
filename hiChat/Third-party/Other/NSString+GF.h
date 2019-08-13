//
//  NSString+GF.h
//  GFCocoaTools
//
//  Created by zhangliyong on 2017/3/14.
//  Copyright © 2017年 zhangliyong@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GF)

- (NSString *)stringByLeftTrimmingCharactersInSet:(NSCharacterSet *)set;

- (NSString *)stringByRightTrimmingCharactersInSet:(NSCharacterSet *)set;

- (NSString *)phoneNumberStyledString;

- (NSString *)MD5;

- (NSString *)MD5InShort;

- (NSString *)sha1;

- (NSString *)hmacWithKey:(NSString *)key;

- (BOOL)isValidPhoneNumber;

- (BOOL)isValidMobileNumber;

- (BOOL)isValidIdNumber;

- (NSString *)pinyin;

- (NSInteger)pinyinDiffWithString:(NSString *)string;

- (NSArray *)wordComponentsWithLimit:(NSInteger)limit;

- (UIImage *)qrImage;

@end

@interface NSString (oss)

- (NSString *)ossUrlStringResized:(CGSize)size;

- (NSString *)ossUrlStringResized:(CGSize)size mode:(UIViewContentMode)mode;

- (NSString *)ossUrlStringRound;

- (NSString *)ossUrlStringJpegFormatted;

- (NSString *)ossUrlStringPngFormatted;

- (NSString *)ossUrlStringRoundWithSize:(CGSize)size;

@end

