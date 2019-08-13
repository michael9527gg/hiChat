//
//  QiniuManager.h
//  Dreamedu
//
//  Created by zhangliyong on 2017/2/21.
//  Copyright © 2017年 南京远御网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliOssManager : NSObject

+ (instancetype)manager;

- (void)requestOssInfoWithCompletion:(nullable CommonBlock)completion;

@end

@interface UploadManager : NSObject

+ (instancetype)manager;

- (void)uploadFile:(NSString *)filePath
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void(^)(NSUInteger, NSUInteger))progressBlock
        completion:(nullable CommonBlock)completion;

- (void)uploadData:(NSData *)data
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void(^)(NSUInteger completedBytes, NSUInteger totalBytes))progressBlock
        completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
