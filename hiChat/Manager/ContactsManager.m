//
//  ContactsManager.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "ContactsManager.h"

@implementation ContactsManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static ContactsManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [ContactsManager new];
    });
    
    return client;
}

+ (NSArray *)colorArray {
    return @[[UIColor colorFromString:@"5ba2ee"],
             [UIColor colorFromString:@"44b0ca"],
             [UIColor colorFromString:@"12a988"],
             [UIColor colorFromString:@"e7762b"],
             [UIColor colorFromString:@"49bd70"],
             [UIColor colorFromString:@"ae5dc3"]];
}

- (void)refreshFriendsListWithCompletion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"friendship/all"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSArray *result = responseObject[@"result"];
                                                NSMutableArray *arr = [NSMutableArray new];
                                                for (NSDictionary *item in result) {
                                                    ContactData *data = [ContactData contactFromData:item];
                                                    if(data.uid.length) {
                                                        [arr addObject:data];
                                                        
                                                        // 好友信息可能有变化，我们刷新下融云本地的缓存
                                                        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:data.uid
                                                                                                             name:data.name
                                                                                                         portrait:[data.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]];
                                                        
                                                        [[UserManager manager] refreshRCUserInfoCacheWithUserid:nil
                                                                                                       userInfo:userInfo
                                                                                                     completion:nil];
                                                    }
                                                }
                                                
                                                [[ContactsDataSource sharedClient] addObjects:arr
                                                                                   entityName:[ContactEntity entityName]
                                                                                      syncAll:YES
                                                                                syncPredicate:nil];
                                                
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

- (void)requestFriendRequestListWithCompletion:(CommonBlock)completion {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"friendship/friendApplyList"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSArray *list = responseObject[@"result"];
                                                NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:list.count];
                                                for(NSDictionary *dic in list) {
                                                    FriendRequsetData *data = [FriendRequsetData friendRequsetWithDic:dic];
                                                    if (data) {
                                                        [mulArr addObject:data];
                                                    }
                                                }
                                                [[ContactsDataSource sharedClient] addObjects:mulArr
                                                                                   entityName:[FriendRequestEntity entityName]
                                                                                      syncAll:YES
                                                                                syncPredicate:nil];
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

- (void)searchFriendWithName:(NSString *)name completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"name"] = name;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Friendship/findFriend"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSArray *array = [responseObject valueForKey:@"result"];
                                                NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
                                                
                                                for(NSDictionary *dic in array) {
                                                    UserData *user = [UserData userWithDic:dic];
                                                    [mulArr addObject:user];
                                                }
                                                if (completion) {
                                                    completion(YES, @{@"data" : mulArr});
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

- (void)searchUserWithPhone:(NSString *)phone completion:(CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"friendship/queryFriendship"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:@{@"phone":phone}
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSDictionary *dic = [responseObject valueForKey:@"result"];
                                                UserData *user = [UserData userWithDic:dic];
                                                
                                                if (completion) {
                                                    completion(YES, @{@"data" : user});
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

- (void)addFriendByUserid:(NSString *)userid
               completion:(CommonBlock)completion {
    NSString *message = [NSString stringWithFormat:@"我是%@", YUCLOUD_ACCOUNT_NAME];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"friendid"] = userid;
    params[@"message"] = message;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"friendship/addFriendship"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSDictionary *dic = [responseObject valueForKey:@"result"];
                                                
                                                //Added 添加好友成功   Node 好友申请
                                                NSString *action = YUCLOUD_VALIDATE_STRING(dic[@"action"]);
                                                NSString *message = nil;
                                                if ([action isEqualToString:@"Added"]) {
                                                    message = @"好友已添加成功";
                                                    [[ContactsManager manager] refreshFriendsListWithCompletion:nil];
                                                    if (completion) {
                                                        completion(YES, @{@"msg" : message});
                                                    }
                                                } else if ([action isEqualToString:@"Node"]) {
                                                    message = @"好友请求已发送，等待对方确认";
                                                    if (completion) {
                                                        completion(YES, @{@"msg" : message});
                                                    }
                                                } else {
                                                    if (completion) {
                                                        completion(NO, nil);
                                                    }
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

- (void)processFriendRequestWithUserid:(NSString *)userid
                                accept:(BOOL)accept
                            completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"friendid"] = userid;
    params[@"status"] = accept?@"1":@"3";
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"friendship/toExamineFriend"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
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

- (void)updateFriendDisplayNameByUserid:(NSString *)userid
                            displayName:(NSString *)displayName
                             completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"friendid"] = userid;
    params[@"displayname"] = displayName;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Friendship/updatedisplayName"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
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

- (void)deleteFriendWithUserid:(NSString *)userid completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"friendid"] = userid;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"friendship/removeFriend"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
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

- (void)checkFriendRelationBetweenUser:(NSString *)userid
                            completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"friendid"] = userid;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"friendship/confirmFriend"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            NSNumber *code = [responseObject valueForKey:@"code"];
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, nil);
                                                }
                                            }
                                            else if([code isEqual:@1019]) {
                                                if (completion) {
                                                    completion(NO, @{@"msg": [responseObject msg],
                                                                     @"reason" : @"onlyYouRelation"});
                                                }
                                            }
                                            else {
                                                if (completion) {
                                                    completion(NO, @{@"msg": [responseObject msg],
                                                                     @"reason" : @"noRelation"});
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)requestFriendBlackListWithCompletion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"users/blacklist"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSArray *array = [responseObject valueForKey:@"result"];
                                                NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
                                                for(NSDictionary *dic in array) {
                                                    FriendBlackData *data = [FriendBlackData friendBlackWithDic:dic];
                                                    [mulArr addObject:data];
                                                }
                                                [[ContactsDataSource sharedClient] addObjects:mulArr
                                                                                   entityName:[FriendBlackEntity entityName]
                                                                                      syncAll:YES
                                                                                syncPredicate:nil];
                                                if (completion) {
                                                    completion(YES, nil);
                                                }
                                            }
                                            else {
                                                if (completion) {
                                                    completion(NO, nil);
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)addBlackListWithFriendid:(NSString *)friendID completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"blackUserid"] = friendID;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"users/addblacklist"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
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
                                                    completion(NO, @{@"msg" : [responseObject msg]});
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)deleteBlackListWithFriendid:(NSString *)friendID
                         completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"blackUserid"] = friendID;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"users/removeblacklist"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
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
                                                    completion(NO, @{@"msg" : [responseObject msg]});
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)checkMessageAbilityForConversation:(RCConversationType)type
                                    target:(NSString *)targetid
                                completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"toformid"] = targetid;
    
    if(type == ConversationType_PRIVATE) {
        params[@"status"] = @1;
    } else if(type == ConversationType_GROUP) {
        params[@"status"] = @2;
    }
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Messages/checkMessage"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            NSNumber *code = YUCLOUD_VALIDATE_NUMBER(responseObject[@"code"]);
                                            
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, nil);
                                                }
                                            }
                                            else {
                                                if (completion) {
                                                    completion(NO, @{@"code" : code,
                                                                     @"msg" : [responseObject msg]});
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)increaseUnreadFriendRequstMessageCount {
    NSLog(@"increaseUnreadFriendRequstMessageCount");
    NSUInteger unreadCount = [NSUserDefaults unreadFriendRequstMessageCount];
    [NSUserDefaults saveUnreadFriendRequstMessageCount:++unreadCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_UNREAD_FRIENDREQUEST_NOTIFICATION
                                                        object:nil
                                                      userInfo:nil];
}

- (NSUInteger)unreadFriendRequstMessageCount {
    return [NSUserDefaults unreadFriendRequstMessageCount];
}

- (void)clearUnreadFriendRequstMessageCount {
    NSLog(@"clearUnreadFriendRequstMessageCount");
    [NSUserDefaults saveUnreadFriendRequstMessageCount:0];
}

@end
