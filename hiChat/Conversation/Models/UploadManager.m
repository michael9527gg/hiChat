//
//  QiniuManager.m
//  Dreamedu
//
//  Created by zhangliyong on 2017/2/21.
//  Copyright © 2017年 南京远御网络科技有限公司. All rights reserved.
//

#import "UploadManager.h"
#import "AccountManager.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "CloudInterface.h"

@interface AliOssBucket : NSObject

@property (nonatomic, copy) NSString        *ak;
@property (nonatomic, copy) NSString        *sk;
@property (nonatomic, copy) NSString        *st;
@property (nonatomic, copy) NSString        *name;
@property (nonatomic, copy) NSString        *endpoint;

+ (instancetype)bucketFromData:(NSDictionary *)data;

@end

@implementation AliOssBucket

+ (instancetype)bucketFromData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.name = YUCLOUD_VALIDATE_STRING(data[@"BucketName"]);
        self.ak = YUCLOUD_VALIDATE_STRING(data[@"AccessKeyId"]);
        self.sk = YUCLOUD_VALIDATE_STRING(data[@"AccessKeySecret"]);
        self.st = YUCLOUD_VALIDATE_STRING(data[@"SecurityToken"]);
        self.endpoint = YUCLOUD_VALIDATE_STRING(data[@"EndPoint"]);
        
        self.endpoint = [self.endpoint stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }
    
    return self;
}

@end

@interface AliOssManager ()

@property (nonatomic, strong) OSSClient     *client;
@property (nonatomic, strong) AliOssBucket  *bucket;
@property (nonatomic, copy)   NSDate        *tokenDate;

@end

@implementation AliOssManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static AliOssManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[AliOssManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (void)requestOssInfoWithCompletion:(nullable CommonBlock)completion {
    if (self.bucket && self.tokenDate && [[NSDate date] timeIntervalSinceDate:self.tokenDate] < 60 * 30) {
        if (completion) {
            completion(YES, nil);
        }
        
        return;
    }
    
    [[CloudInterface sharedClient] doWithMethod:HttpGet
                                      urlString:@"messages/yuntoken"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:nil
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSDictionary *extra = responseObject[@"result"];
                                                self.bucket = [AliOssBucket bucketFromData:extra];
                                                if (completion) {
                                                    completion(YES, nil);
                                                }
                                            }
                                            else if (completion) {
                                                completion(NO, nil);
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)setBucket:(AliOssBucket *)bucket {
    _bucket = bucket;
    
    self.tokenDate = [NSDate date];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:bucket.ak
                                                                                          secretKeyId:bucket.sk
                                                                                        securityToken:bucket.st];
    
    self.client = [[OSSClient alloc] initWithEndpoint:bucket.endpoint
                                   credentialProvider:credential
                                  clientConfiguration:conf];
}

- (void)uploadData:(NSData *)data
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void(^)(NSUInteger completedBytes, NSUInteger totalBytes))progressBlock
        completion:(CommonBlock)completion {
    static NSInteger index = 0;
    [self requestOssInfoWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        if (success) {
            NSString *objectKey = [NSString stringWithFormat:@"ios/%@%ld.%@", [data MD5InShort], (long)index++, fileExt];
            OSSPutObjectRequest * put = [OSSPutObjectRequest new];
            put.bucketName = self.bucket.name;
            put.objectKey = objectKey;
            put.uploadingData = data;
            put.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                if (progressBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBlock((NSUInteger)totalBytesSent, (NSUInteger)totalBytesExpectedToSend);
                    });
                }
            };
            
            OSSTask *task = [self.client putObject:put];
            [task continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
                NSString *url;
                if (!task.error) {
                    url = [NSString stringWithFormat:@"https://%@.%@/%@", self.bucket.name, self.bucket.endpoint, objectKey];
                    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                }
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(task.error == nil, url?@{@"url" : url,
                                                            @"size" : @(data.length)}:nil);
                    });
                }
                
                return task;
            }];
        }
        else {
            if (completion) {
                completion(NO, nil);
            }
        }
    }];
}

- (void)uploadFile:(NSString *)filePath
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void(^)(NSUInteger completedBytes, NSUInteger totalBytes))progressBlock
        completion:(CommonBlock)completion {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [self uploadData:data
             fileExt:fileExt
            progress:progressBlock
          completion:completion];
}

@end

@interface UploadManager ()

@end

@implementation UploadManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static UploadManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[UploadManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (void)uploadData:(NSData *)data
           fileExt:(nullable NSString *)fileExt
          progress:(void (^)(NSUInteger, NSUInteger))progressBlock
        completion:(CommonBlock)completion {
    AliOssManager *oss = [AliOssManager manager];
    
    [oss uploadData:data
            fileExt:fileExt
           progress:progressBlock
         completion:^(BOOL success, NSDictionary * _Nullable info) {
             if (completion) {
                 completion(success, info);
             }
             
         }];
}

- (void)uploadFile:(NSString *)filePath
           fileExt:(nullable NSString *)fileExt
          progress:(void (^)(NSUInteger, NSUInteger))progressBlock
        completion:(CommonBlock)completion {
    AliOssManager *oss = [AliOssManager manager];
    if (oss.bucket) {
        [oss uploadFile:filePath
                fileExt:fileExt
               progress:progressBlock
             completion:completion];
    }
}

@end

