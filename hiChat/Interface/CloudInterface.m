//
//  CloudInterface.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "CloudInterface.h"
#import "AFPlainTextResponseSerializer.h"

@implementation NSDictionary (response)

- (NSInteger)code {
    NSNumber *code = YUCLOUD_VALIDATE_NUMBER(self[@"code"]);
    return code.integerValue;
}

- (BOOL)success {
    return self.code == 200;
}

- (NSString *)msg {
    return YUCLOUD_VALIDATE_STRING(self[@"msg"]);
}

@end

@implementation CloudInterface

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    static CloudInterface *client = nil;
    dispatch_once(&onceToken, ^{
        NSString *baseUrl = @"https://api.kaixinliao.com";
#if ENV_DEV
        baseUrl = @"http://10.10.10.33:80/index.php";
#endif
        client = [[CloudInterface alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        client.requestSerializer.timeoutInterval = 30;
        client.responseSerializer = [AFPlainTextResponseSerializer serializer];
    });

    return client;
}

- (NSURLSessionTask *)doWithMethod:(HttpMethod)method
                         urlString:(NSString *)urlString
                           headers:(NSDictionary *)headers
                        parameters:(id)parameters
         constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))constructingBlock
                          progress:(void (^)(NSProgress *))progress
                           success:(void (^)(NSURLSessionDataTask *, NSDictionary * _Nullable))success
                           failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError *))failure {
    NSMutableDictionary *dic = @{@"version": [[NSBundle mainBundle] bundleShortVersion],
                                 @"device_id": [UIDevice deviceID]}.mutableCopy;
    
    if (headers) {
        [dic addEntriesFromDictionary:headers];
    }
    
    return [super doWithMethod:method
                     urlString:urlString
                       headers:dic
                    parameters:parameters
     constructingBodyWithBlock:constructingBlock
                      progress:progress
                       success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                           // 拦截登录失效
                           if([responseObject code] == 1004) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                                                       withResult:NO
                                                        labelText:[responseObject msg]
                                                        delayHide:YES
                                                       completion:^{
                                                           [[AccountManager manager] processInvalidToken];
                                                           [[AppDelegate appDelegate] showLoginScreen:NO];
                                                       }];
                               });
                               NSLog(@"login token invalid ！！！");
                           }
                           else {
                               success(task, responseObject);
                           }
                       }
                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                           failure(task, error);
                       }];
}

@end
