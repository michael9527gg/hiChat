//
//  GroupManager.m
//  hiChat
//
//  Created by Polly polly on 14/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupManager.h"

@implementation GroupManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static GroupManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [GroupManager new];
    });
    
    return client;
}

- (void)refreshRCGroupInfoCacheWithGroupid:(NSString *)groupid {
    [self requesGroupInfoWithGroupId:groupid
                          completion:^(BOOL success, NSDictionary * _Nullable info) {
                              if(success) {
                                  GroupData *data = [info valueForKey:@"data"];
                                  RCGroup *groupInfo = [[RCGroup alloc] initWithGroupId:groupid
                                                                              groupName:data.name
                                                                            portraitUri:[data.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]];
                                  
                                  [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo
                                                               withGroupId:groupid];
                              }
                          }];
}

- (void)requestAllGroupCategoriesWithCompletion:(CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpGet
                                      urlString:@"groups/categories"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:nil
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSArray *result = responseObject[@"result"];
                                                // 分类信息只有管理员相关的个别群，不同步数据库
                                                if (completion) {
                                                    completion(YES, @{@"result" : result});
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

- (void)createGroupWithName:(NSString *)groupName
                   portrait:(NSString *)portrait
                 completion:(CommonBlock)completion {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    [params setObject:groupName forKey:@"groupName"];
    if(portrait) {
        [params setObject:portrait forKey:@"portraitUri"];
    }
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"groups/create"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSDictionary *result = responseObject[@"result"];
                                                NSNumber *groupId = result[@"groupId"];
                                                NSLog(@"Create group success with groupid : %@", groupId);
                                                
                                                [[GroupManager manager] requestAllGroupsWithCompletion:nil];
                                                
                                                if (completion) {
                                                    completion(YES, @{@"groupid" : groupId ,
                                                                      @"msg" : [responseObject msg]});
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

- (void)joinGroupWithGroupId:(NSString *)groupID
             groupMemberList:(NSArray *)groupMemberList
                  completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    [params setObject:groupID forKey:@"groupid"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:groupMemberList?:@[]
                                                       options:0
                                                         error:&error];
    
    [params setObject:[[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding]
               forKey:@"usersid"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"groups/join"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, @{@"msg": [responseObject msg]});
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

- (void)kickUsersByGroupId:(NSString *)groupID
                   usersId:(NSArray *)usersId
                completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    [params setObject:groupID forKey:@"groupid"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:usersId?:@[]
                                                       options:0
                                                         error:&error];
    
    [params setObject:[[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding]
               forKey:@"usersid"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"groups/regusers"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, @{@"msg": [responseObject msg]});
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

- (void)requesGroupMembersWithGroupId:(NSString *)groupId
                           completion:(nullable CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpGet
                                      urlString:[NSString stringWithFormat:@"groups/members/%@", groupId]
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:nil
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSArray *members = responseObject[@"result"];
                                                NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:members.count];
                                                for(NSDictionary *dic in members) {
                                                    GroupMemberData *groupMember = [GroupMemberData groupMemberWithGroupid:groupId
                                                                                                                       dic:dic];
                                                    [mulArr addObject:groupMember];
                                                    ContactData *contact = [[ContactsDataSource sharedInstance] contactWithUserid:groupMember.userid];
                                                    
                                                    // 强刷融云用户信息缓存
                                                    RCUserInfo *userInfo = [[RCUserInfo alloc] init];
                                                    userInfo.userId = groupMember.userid;
                                                    userInfo.name = contact.displayName.length?contact.displayName:groupMember.nickname;
                                                    userInfo.portraitUri = [groupMember.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE];
                                                    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo
                                                                                 withUserId:groupMember.userid];
                                                }
                                                
                                                [[GroupDataSource sharedInstance] addObjects:mulArr
                                                                               syncPredicate:[NSPredicate predicateWithFormat:@"groupid == %@", groupId]];
                                                
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

- (void)requesGroupInfoWithGroupId:(NSString *)groupId
                        completion:(nullable CommonBlock)completion {
    [[CloudInterface sharedClient] doWithMethod:HttpGet
                                      urlString:[NSString stringWithFormat:@"groups/groupInfo/%@", groupId]
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:nil
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSDictionary *dic = responseObject[@"result"];
                                                
                                                GroupData *group = [GroupData groupWithDic:dic];
                                                GroupData *oldData = [[GroupDataSource sharedInstance] groupWithGroupid:groupId];
                                                if(oldData) {
                                                    group.sortIndex = oldData.sortIndex;
                                                }
                                                
                                                [[GroupDataSource sharedInstance] addObject:group];
                                                
                                                if (completion) {
                                                    completion(YES, @{@"data" : group});
                                                }
                                            }
                                            else {
                                                if (completion) {
                                                    completion(NO, @{@"msg": [responseObject msg],
                                                                     @"reason" : @"notExist"});
                                                }
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                            if (completion) {
                                                completion(NO, @{@"msg": [error localizedDescription]?:@""});
                                            }
                                        }];
}

- (void)requestAllGroupsWithCompletion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"users/groups"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSArray *groups = responseObject[@"result"];
                                                NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:groups.count];
                                                for(NSDictionary *dic in groups) {
                                                    GroupData *data = [GroupData groupWithDic:dic];
                                                    data.sortIndex = [groups indexOfObject:dic];
                                                    [mulArr addObject:data];
                                                }
                                                
                                                [[GroupDataSource sharedInstance] addObjects:mulArr
                                                                               syncPredicate:nil];
                                                
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

- (void)editGroupInfoWithGroupid:(NSString *)groupid
                            name:(NSString *)name
                        portrait:(NSString *)portrait
                    announcement:(NSString *)announcement
                      completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"groupid"];
    if(name) [params setObject:name forKey:@"groupname"];
    if(announcement) [params setObject:announcement forKey:@"bulletin"];
    if(portrait) [params setObject:portrait forKey:@"portraitUri"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"groups/refresh"
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

- (void)editGroupAdminRoleWithGroupid:(NSString *)groupid
                              userids:(NSArray *)userids
                                 role:(NSNumber *)role
                           completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    [params setObject:groupid forKey:@"groupid"];
    [params setObject:role forKey:@"role"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userids?:@[]
                                                       options:0
                                                         error:&error];
    
    [params setObject:[[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding]
               forKey:@"usersid"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Groups/setGroupRole"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, @{@"msg": [responseObject msg]});
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

- (void)dismissGroupWithGroupid:(NSString *)groupid
                     completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"groupid"] = groupid;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"groups/dismiss"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, @{@"msg": [responseObject msg]});
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

- (void)quitGroupWithGroupid:(NSString *)groupid
                  completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"groupid"] = groupid;
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"groups/quit"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, @{@"msg": [responseObject msg]});
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

- (void)addGagForGroup:(NSString *)groupid
               userids:(NSArray *)userids
                minute:(NSInteger)minute
            completion:(CommonBlock)completion {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"groupid"] = groupid;
    [params setObject:@(minute) forKey:@"minute"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userids?:@[]
                                                       options:0
                                                         error:&error];
    
    [params setObject:[[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding]
               forKey:@"usersid"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Groups/addGagUser"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, @{@"msg": [responseObject msg]});
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

- (void)removeGagFromGroup:(NSString *)groupid
                   userids:(NSArray *)userids
                completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    params[@"groupid"] = groupid;
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userids?:@[]
                                                       options:0
                                                         error:&error];
    
    [params setObject:[[NSString alloc] initWithData:jsonData
                                            encoding:NSUTF8StringEncoding]
               forKey:@"usersid"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Groups/rollBackGagUser"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, @{@"msg": [responseObject msg]});
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

- (void)banGroupWithGroupid:(NSString *)groupid
                        ban:(NSString *)ban
                 completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = YUCLOUD_ACCOUNT_USERID;
    params[@"groupId"] = groupid;
    [params setObject:ban forKey:@"stat"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"groupban/setban"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                if (completion) {
                                                    completion(YES, responseObject);
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

@end
