//
//  AccountManager.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "AccountManager.h"
#import "UniManager.h"
#import "CloudInterface.h"
#import <WXApi.h>

typedef NS_ENUM(NSUInteger, YuAccountStatus)
{
    YuAccountStatusLogout               = 0,
    YuAccountStatusLocalSignin          = 1 << 0,
    YuAccountStatusSigninSuccess        = 1 << 2,
    
    //add new items before this line
};

@implementation NSString (User)

- (BOOL)isSpecialUser {
    return [self isEqualToString:@"2"];
}

@end

@implementation UIImage (avatar)

+ (NSString *)defaultAvatarUrl {
    return @"https://kaixinliao-pic.oss-cn-beijing.aliyuncs.com/5bcdad5949c4c.jpg";
}

+ (UIImage *)defaultAvatar {
    static UIImage *sAvatar = nil;
    if (sAvatar) {
        return sAvatar;
    }
    
    NSString *url = [[self defaultAvatarUrl] ossUrlStringRoundWithSize:LIST_ICON_SIZE];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:url];
    if (image) {
        sAvatar = image;
    }
    else {
        image = [UIImage imageNamed:@"ic_me_avatar"];
    }
    
    return image;
}

@end

@implementation AccountInfo

+ (instancetype)infoFromData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [self init]) {
        self.loginid = data[@"id"];
        self.appKey = data[@"appkey"];
        self.sign = data[@"sign"];
        self.rcKey = data[@"appkey"];
        self.rcToken = data[@"token"];
        self.role = YUCLOUD_VALIDATE_STRING_WITH_DEFAULT(data[@"role"], @"1");
        self.invitationCode = YUCLOUD_VALIDATE_STRING(data[@"invitecode"]);
        self.phone = YUCLOUD_VALIDATE_STRING(data[@"phone"]);
        
        NSString *isStaff = YUCLOUD_VALIDATE_STRING([data valueForKey:@"is_staff"]);
        self.isStaff = isStaff.boolValue;
        
        NSString *string = YUCLOUD_VALIDATE_STRING(data[@"platform_url"]);
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (string.length > 0) {
            if (![string containsString:@"http://"] && ![string containsString:@"https://"]) {
                string = [@"http://" stringByAppendingString:string];
            }
            
            self.platformUrl = [NSURL URLWithString:string];
        }
        
        self.platformName = YUCLOUD_VALIDATE_STRING([data valueForKey:@"platform_name"]);
    }
    
    return self;
}

@end

@interface AccountManager ()

@property (nonatomic, assign) NSUInteger            accountStatus;
@property (nonatomic, strong) AccountInfo           *accountInfo;

@property (nonatomic, copy, nullable)   NSString    *loginid;
@property (nonatomic, copy, nullable)   NSString    *token;

@property (nonatomic, copy)   NSString              *iCloudTokenKey;
@property (nonatomic, copy)   NSString              *iCloudTokenDateKey;

@property (nonatomic, copy) CommonBlock wechatCompletion;

@end

@implementation AccountManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static AccountManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [AccountManager new];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        [WXApi registerApp:WECHAT_APP_ID];
        
#if ENV_DEV
        self.iCloudTokenKey = @"iCloudTokenDevKey";
        self.iCloudTokenDateKey = @"iCloudTokenDateDevKey";
#else
        self.iCloudTokenKey = @"iCloudTokenKey";
        self.iCloudTokenDateKey = @"iCloudTokenDateKey";
#endif //UNILIFE_DEV_MODE
        
        [self readTokenFromiCloud];
    }
    
    return self;
}

- (void)readTokenFromiCloud {
    NSString *iCloudToken = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:self.iCloudTokenKey];
    NSDate *iCloudTokenDate = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:self.iCloudTokenDateKey];
    
    NSString *token = [NSUserDefaults token];
    NSDate *tokenDate = [NSUserDefaults tokenDate];
    
    if ([token length] == 0 || (iCloudTokenDate && [iCloudTokenDate compare:tokenDate] == NSOrderedDescending)) {
        NSLog(@"use iCloudToken: %@", iCloudToken);
        [NSUserDefaults saveToken:iCloudToken];
    }
}

- (void)saveTokenToiCloud {
    [[NSUbiquitousKeyValueStore defaultStore] setObject:YUCLOUD_ACCOUNT_TOKEN forKey:self.iCloudTokenKey];
    [[NSUbiquitousKeyValueStore defaultStore] setObject:[NSDate date] forKey:self.iCloudTokenDateKey];
    
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

- (BOOL)isSignin {
    return (self.accountStatus & (YuAccountStatusLocalSignin | YuAccountStatusSigninSuccess)) != 0;
}

- (BOOL)isLocalSignin {
    return (self.accountStatus & YuAccountStatusLocalSignin) != 0;
}

- (BOOL)isServerSignin {
    return (self.accountStatus & YuAccountStatusSigninSuccess) != 0;
}

- (BOOL)isStaff {
    if ([self isServerSignin]) {
        return self.accountInfo.isStaff;
    }
    
    return NO;
}

- (BOOL)isSpecialUser {
    if ([self isServerSignin]) {
        return [self.accountInfo.role isSpecialUser];
    }
    
    return NO;
}

- (BOOL)isSpecialOrStaff {
    if ([self isSpecialUser] || [self isStaff]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)loginid {
    if ([self isServerSignin]) {
        return self.accountInfo.loginid;
    }
    
    return nil;
}

- (NSString *)token {
    if ([self isServerSignin]) {
        return self.accountInfo.sign;
    }
    
    return nil;
}

- (NSString *)rcKey {
    if ([self isServerSignin]) {
        return self.accountInfo.rcKey;
    }
    
    return nil;
}

- (NSString *)rcToken {
    if ([self isServerSignin]) {
        return self.accountInfo.rcToken;
    }
    
    return nil;
}

- (void)startAutoLoginWithCompletion:(CommonBlock)completion {
    NSString *token = [NSUserDefaults token];
    
    if (token.length && ![self isSignin]) {
        self.accountStatus = YuAccountStatusLocalSignin;
        [self loginWithPhone:nil
                        pass:nil
                       token:token
                        code:nil
                  completion:completion];
    }
    else if (completion) {
        self.accountStatus = YuAccountStatusLogout;
        completion(NO, nil);
    }
}

- (void)requestSmsWithPhone:(NSString *)phone
                     reason:(nonnull NSString *)reason
                 completion:(CommonBlock)completion {
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"login/send_code_sms"
                                        headers:nil
                                     parameters:@{@"phone": phone,
                                                  @"region": @"86",
                                                  @"reason": reason?:@""}
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if (completion) {
                                                completion([responseObject success], responseObject);
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)registerWithName:(NSString *)name
                   phone:(NSString *)phone
                    pass:(NSString *)pass
                 smsCode:(NSString *)smsCode
          invitationCode:(NSString *)invitationCode
              completion:(CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"login/new_register"
                                        headers:nil
                                     parameters:@{@"nickname": name,
                                                  @"phone": phone,
                                                  @"region": @"86",
                                                  @"password": pass,
                                                  @"code": smsCode,
                                                  @"invitecode": invitationCode}
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if (completion) {
                                                completion([responseObject success], @{@"msg": [responseObject msg]});
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
    
}

- (void)afterLoginWithResult:(NSDictionary *)result {
    self.accountInfo = [AccountInfo infoFromData:result];
    self.accountStatus = YuAccountStatusSigninSuccess;
    
    [NSUserDefaults savePhone:self.accountInfo.phone];
    [NSUserDefaults saveToken:self.accountInfo.sign];
    
    [self requestMeInfoWithAction:YuCloudDataList
                             user:self.accountInfo.loginid
                             info:nil
                       completion:^(BOOL success, NSDictionary * _Nullable info) {
                           if(success) {
                               // 刷新融云个人信息
                               if(![RCIM sharedRCIM].currentUserInfo) {
                                   RCUserInfo *curUser = [[RCUserInfo alloc] initWithUserId:YUCLOUD_ACCOUNT_USERID
                                                                                       name:YUCLOUD_ACCOUNT_NAME
                                                                                   portrait:YUCLOUD_ACCOUNT_PORTRAIT];
                                   [[RCIM sharedRCIM] setCurrentUserInfo:curUser];
                               }
                           }
                       }];
    
    [[AliOssManager manager] requestOssInfoWithCompletion:nil];
}

- (void)loginWithPhone:(NSString *)phone
                  pass:(NSString *)pass
                 token:(NSString *)token
                  code:(NSString *)code
            completion:(nullable CommonBlock)completion {
    
    NSDictionary *params = nil;
    if(token) {
        params = @{@"sign" : token};
    }
    else {
        params = @{@"phone": phone?:@"",
                   @"password": pass?:@"",
                   @"region": @"86",
                   @"code": code?:@""};
    }
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"login/login"
                                        headers:nil
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSDictionary *result = responseObject[@"result"];
                                                [self afterLoginWithResult:result];
                                                
                                                [self saveTokenToiCloud];
                                                
                                                if (completion) {
                                                    completion(YES, nil);
                                                }
                                            }
                                            else {
                                                self.accountStatus = YuAccountStatusLogout;
                                                
                                                [NSUserDefaults saveToken:nil];
                                                
                                                if (completion) {
                                                    completion(NO, responseObject);
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            self.accountStatus = YuAccountStatusLogout;
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)twoStepVerify:(NSString *)token
                 code:(NSString *)code
           completion:(CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"login/auth2step"
                                        headers:@{}
                                     parameters:@{@"auth2stepToken": token?:@"",
                                                  @"securityCode": code?:@""}
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSDictionary *result = responseObject[@"result"];
                                                [self afterLoginWithResult:result];
                                                
                                                if (completion) {
                                                    completion(YES, nil);
                                                }
                                            }
                                            else {
                                                self.accountStatus = YuAccountStatusLogout;
                                                
                                                if (completion) {
                                                    completion(NO, responseObject);
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)logoutWithCompletion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = [AccountManager manager].loginid;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"login/logout"
                                        headers:@{@"sign": self.token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            
                                            self.accountStatus = YuAccountStatusLogout;
                                            
                                            [[RCIM sharedRCIM] logout];
                                            
                                            if (completion) {
                                                completion([responseObject success], @{@"msg": [responseObject msg]});
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)changePassword:(NSString *)newPass oldPass:(NSString *)oldPass completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = [AccountManager manager].loginid;
    params[@"password"] = newPass;
    params[@"repassword"] = newPass;
    params[@"token"] = [AccountManager manager].accountInfo.rcToken;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"users/repassword"
                                        headers:@{@"sign": self.token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if (completion) {
                                                completion([responseObject success], @{@"msg": [responseObject msg]});
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)requestMeInfoWithAction:(YuCloudDataActions)action user:(NSString *)userid info:(AccountInfo *)info completion:(CommonBlock)completion {
    HttpMethod method;
    NSString *urlString;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (action == YuCloudDataList) {
        method = HttpGet;
        urlString = [NSString stringWithFormat:@"users/index/%@", userid];
    }
    else {
        method = HttpPost;
        urlString = @"users/refresh";
        params[@"userid"] = [AccountManager manager].loginid;
        params[@"portraitUri"] = info.portraitUri;
        params[@"name"] = info.nickname;
        params[@"account"] = info.account;
    }
    
    [[CloudInterface sharedClient] doWithMethod:method
                                      urlString:urlString
                                        headers:@{@"sign": self.token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (action == YuCloudDataList) {
                                                    NSDictionary *result = responseObject[@"result"];
                                                    
                                                    AccountInfo *accountInfo = [AccountManager manager].accountInfo;
                                                    accountInfo.loginid = result[@"id"];
                                                    accountInfo.nickname = result[@"nickname"];
                                                    accountInfo.portraitUri = result[@"portraitUri"];
                                                    accountInfo.account = result[@"account"];
                                                    
                                                    [NSUserDefaults saveName:accountInfo.nickname forUser:YUCLOUD_ACCOUNT_USERID];
                                                    [NSUserDefaults savePortraitUri:accountInfo.portraitUri forUser:YUCLOUD_ACCOUNT_USERID];
                                                }
                                                else {
                                                    [AccountManager manager].accountInfo.portraitUri = info.portraitUri;
                                                    [AccountManager manager].accountInfo.nickname = info.nickname;
                                                }
                                                
                                                if (completion) {
                                                    completion(YES, nil);
                                                }
                                            }
                                            else {
                                                if (completion) {
                                                    completion(NO, @{@"msg": [responseObject msg]});
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)fillInfoWithAccessToken:(NSString *)token
                          phone:(NSString *)phone
                           code:(NSString *)code
                     inviteCode:(NSString *)inviteCode
                     completion:(CommonBlock)completion {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:token forKey:@"access_token"];
    [params setObject:phone forKey:@"phone"];
    [params setObject:code forKey:@"code"];
    [params setObject:inviteCode forKey:@"invitecode"];
    [params setObject:@"86" forKey:@"region"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"login/fill"
                                        headers:@{@"sign": self.token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, nil);
                                                }
                                            }
                                            else {
                                                if (completion) {
                                                    completion(NO, @{@"msg": [responseObject msg]});
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)showWechatAuthWithCompletion:(CommonBlock)completion {
    [WXApi registerApp:WECHAT_APP_ID];
    
    if (![WXApi isWXAppInstalled]) {
        if (completion) {
            completion(NO, nil);
        }
        
        return;
    }
    
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.openID = WECHAT_APP_ID;
    req.scope = @"snsapi_userinfo" ;
    req.state = @"currently useless state" ;
    
    self.wechatCompletion = completion;
    
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (void)processInvalidToken {
    [NSUserDefaults saveToken:nil];
    self.accountStatus = YuAccountStatusLogout;
    [[RCIM sharedRCIM] logout];
}

#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (self.wechatCompletion) {
            if (authResp.errCode == 0) {
                self.wechatCompletion(YES, @{@"code": authResp.code?:@""});
            }
            else {
                self.wechatCompletion(NO, nil);
            }
        }
    }
}

- (void)requestVersionWithCompletion:(CommonBlock)completion {
#ifdef APP_STORE
    if (completion) {
        completion(NO, nil);
    }
#else
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Versions/checkVersions"
                                        headers:nil
                                     parameters:@{@"versionsNum": [[NSBundle mainBundle] bundleShortVersion],
                                                  @"versionType": @"2"}
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            [NSUserDefaults saveCheckVersionDate:[NSDate date]];
                                            
                                            if ([responseObject success]) {
                                                NSDictionary *result = responseObject[@"result"];
                                                if (completion) {
                                                    completion(YES, result);
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
#endif
}

- (void)resetPassword:(NSString *)phone
                 pass:(NSString *)pass
                 code:(NSString *)code
           completion:(CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"login/new_reset_password"
                                        headers:nil
                                     parameters:@{@"phone": phone,
                                                  @"password": pass,
                                                  @"code": code}
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
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

- (void)requestPlatformInfoWithCompletion:(CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpGet
                                      urlString:@"users/platform"
                                        headers:@{@"sign": self.token?:@""}
                                     parameters:nil
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, responseObject[@"result"]);
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

- (void)requestCheckinWithAction:(YuCloudDataActions)action
                          taskId:(NSString *)taskId
                      completion:(CommonBlock)completion {
    HttpMethod method = HttpGet;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = nil;
    
    switch (action) {
        case YuCloudDataList: {
            method = HttpGet;
            url = @"users/getcheckin";
        }
            
            break;
        case YuCloudDataAdd: {
            method = HttpPost;
            url = @"users/checkin";
            params[@"id"] = taskId;
        }
            
            break;
            
        default:
            break;
    }
    
    [[CloudInterface sharedClient] doWithMethod:method
                                      urlString:url
                                        headers:@{@"sign": self.token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, responseObject);
                                                }
                                            }
                                            else if (completion) {
                                                completion(NO, responseObject);
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

@end
