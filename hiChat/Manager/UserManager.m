//
//  UserManager.m
//  hiChat
//
//  Created by Polly polly on 16/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "UserManager.h"
#import "UserDataSource.h"

@implementation UserManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static UserManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [UserManager new];
    });
    
    return client;
}

- (void)refreshCurrentUserInfo {
    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:YUCLOUD_ACCOUNT_USERID
                                                         name:YUCLOUD_ACCOUNT_NAME
                                                     portrait:[YUCLOUD_ACCOUNT_PORTRAIT ossUrlStringRoundWithSize:LIST_ICON_SIZE]];
    [[RCIM sharedRCIM] setCurrentUserInfo:userInfo];
}

- (void)requesUserInfoWithUserid:(NSString *)userid
                      completion:(nullable CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpGet
                                      urlString:[NSString stringWithFormat:@"users/index/%@", userid]
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:nil
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if (completion) {
                                                if ([responseObject success]) {
                                                    NSDictionary *result = [responseObject valueForKey:@"result"];
                                                    
                                                    UserData *user = [UserData userWithDic:result];
                                                    // 这里涉及到好友备注的问题
                                                    ContactData *contact = [[ContactsDataSource sharedInstance] contactWithUserid:user.uid];
                                                    if(contact) {
                                                        user.displayName = contact.displayName;
                                                    }
                                                    completion(YES, @{@"data" : user});
                                                }
                                                else {
                                                    NSDictionary *result = responseObject;
                                                    completion(NO, @{@"msg": [responseObject msg],
                                                                     @"code" : @([result code])});
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)refreshRCUserInfoCacheWithUserid:(NSString *)userid
                                userInfo:(RCUserInfo *)userInfo
                              completion:(CommonBlock)completion {
    if(userInfo) {
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userid];
        if(completion) {
            completion(YES, @{@"data" : userInfo});
        }
    } else {
        [self requesUserInfoWithUserid:userid
                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                if(success) {
                                    UserData *user = [info valueForKey:@"data"];
                                    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userid
                                                                                         name:user.name
                                                                                     portrait:[user.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]];
                                    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userid];
                                    
                                    if(completion) {
                                        completion(YES, @{@"data" : user});
                                    }
                                }
                                else if([info code] == 1000) {
                                    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userid
                                                                                         name:@"用户已注销"
                                                                                     portrait:nil];
                                    
                                    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userid];
                                    
                                    if(completion) {
                                        completion(NO, nil);
                                    }
                                }
                                else {
                                    if(completion) {
                                        completion(NO, nil);
                                    }
                                }
                            }];
    }
}

@end
