//
//  UIImage+HiChat.m
//  hiChat
//
//  Created by Polly polly on 27/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "UIImage+HiChat.h"
#import <UIImage+GIF.h>

@implementation UIImage (HiChat)

// 相机拍照的坐标系统和我们实际需要不一致，需要我们在画布上做下调整
- (UIImage *)normalizedImage {
    if(self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

// 压缩GIF图片，cropSize：裁剪后的大小，maxImageCount：GIF最多能容纳多少帧，quality：每张图片的质量系数
// 时间这里我没做处理，如果生产base64的缩略图仍然超过128kb，可以考虑下
// 不能将maxImageCount设置过小，展示的时候失真太严重
+ (NSData *)compressGIFWithData:(NSData *)data
                       cropSize:(CGSize)cropSize
                  maxImageCount:(NSInteger)maxImageCount
                        quality:(CGFloat)quality {
    if (!data) return nil;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    
    // 本地生成零时文件
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingString:@"kxlTemp.gif"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:tempFile]) {
        [manager removeItemAtPath:tempFile error:nil];
    }
    NSURL *fileUrl = [NSURL fileURLWithPath:tempFile];
    
    // 先计算从n张图片中均匀的选择m张图片
    NSInteger maxCount = MIN(count, maxImageCount);
    NSMutableArray *desArray = [NSMutableArray arrayWithCapacity:maxCount];
    NSInteger n = count;
    NSInteger m = maxCount;
    for(NSInteger i = 0; i < n; i++) {
        if(rand()%(n-i) < m) {
            [desArray addObject:@(i)];
            m--;
        }
    }
    
    // 设置GIF循环次数
    // 这里在iOS上显示没问题，但是实际在测试时浏览器展示会有问题，iOS 10之后需要提前设置GIF的loop属性
    // 参考：https://stackoverflow.com/questions/40310243/gif-image-generated-on-ios10-no-longer-loops-forever-on-browser
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileUrl, kUTTypeGIF , maxCount, NULL);
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                                 forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    
    NSTimeInterval duration = 0.0;
    // 循环遍历处理每一帧
    for (size_t i = 0; i < count; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        // 处理单张图片
        UIImage *compressedImage = [image compressImageCropSize:cropSize
                                                        quality:quality];
        NSTimeInterval delayTime = [self frameDurationAtIndex:i source:source];
        // 设置图片延时为原来的，不做修改
        NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:delayTime]
                                                                                                       forKey:(NSString *)kCGImagePropertyGIFDelayTime]
                                                                    forKey:(NSString *)kCGImagePropertyGIFDictionary];
        // 只取我们需要的帧
        if([desArray containsObject:@(i)]) {
            duration += delayTime;
            CGImageDestinationAddImage(destination, compressedImage.CGImage, (CFDictionaryRef)frameProperties);
        }
        
        CGImageRelease(imageRef);
    }
    
    // 最后校验下是否压缩成功
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"GIF压缩失败!!!");
        if (destination != nil) {
            CFRelease(destination);
        }
        return nil;
    }
    
    CFRelease(destination);
    CFRelease(source);
    
    return [NSData dataWithContentsOfFile:tempFile];
}

- (UIImage *)compressImageCropSize:(CGSize)cropSize
                           quality:(CGFloat)quality {
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = cropSize.width;
    CGFloat scaledHeight = cropSize.height;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (!CGSizeEqualToSize(self.size, cropSize)) {
        CGFloat widthFactor = scaledWidth / width;
        CGFloat heightFactor = scaledHeight / height;
        
        scaleFactor = MAX(widthFactor, heightFactor);
        
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (cropSize.height - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (cropSize.width - scaledWidth) * 0.5;
        }
    }
    CGRect rect;
    rect.origin = thumbnailPoint;
    rect.size = CGSizeMake(scaledWidth, scaledHeight);
    
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:UIImageJPEGRepresentation(image, quality)];
}

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    CGFloat frameDuration = 0.1;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // 给个最小时间吧，不然显示起来不好看
    if (frameDuration < 0.01) {
        frameDuration = 0.1;
    }
    
    CFRelease(cfFrameProperties);
    frameDuration += 0.1;
    
    return frameDuration;
}

@end
