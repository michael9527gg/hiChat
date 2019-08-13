//
//  UIImage+HiChat.h
//  hiChat
//
//  Created by Polly polly on 27/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HiChat)

- (UIImage *)normalizedImage;

+ (NSData *)compressGIFWithData:(NSData *)data
                       cropSize:(CGSize)cropSize
                  maxImageCount:(NSInteger)maxImageCount
                        quality:(CGFloat)quality;

@end

NS_ASSUME_NONNULL_END
