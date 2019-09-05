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

- (void)kickUserssssssss {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    [params setObject:@"82694" forKey:@"groupid"];
    
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[@"30198",@"32446",@"39951",@"42919",@"53229",@"53424",@"59574",@"68387",@"72436",@"121625",@"139513",@"147884",@"147886",@"147888",@"172052",@"172219",@"177802",@"181043",@"181345",@"181358",@"181382",@"181402",@"181412",@"181413",@"181422",@"181442",@"181445",@"181454",@"181455",@"181464",@"181471",@"181487",@"181490",@"181501",@"181504",@"181507",@"181508",@"181519",@"181541",@"181545",@"181591",@"181602",@"181604",@"181609",@"181610",@"181612",@"181614",@"181623",@"181642",@"181644",@"181648",@"181652",@"181654",@"181655",@"181661",@"181668",@"181687",@"181704",@"181710",@"181727",@"181736",@"181737",@"181747",@"181769",@"181774",@"181840",@"181861",@"181928",@"181941",@"181957",@"181959",@"181961",@"182010",@"182027",@"182030",@"182037",@"182039",@"182061",@"182068",@"182117",@"182148",@"182160",@"182161",@"182163",@"182170",@"182189",@"182193",@"182199",@"182204",@"182205",@"182211",@"182214",@"182217",@"182221",@"182222",@"182226",@"182227",@"182230",@"182234",@"182238",@"182244",@"182248",@"182249",@"182252",@"182254",@"182255",@"182274",@"182276",@"182294",@"182307",@"182315",@"182327",@"182337",@"182340",@"182492",@"182508",@"182516",@"182530",@"182533",@"182548",@"182612",@"182613",@"182622",@"182642",@"182650",@"182669",@"182705",@"182713",@"182729",@"182736",@"182738",@"182744",@"182746",@"182753",@"182759",@"182767",@"182771",@"182774",@"182775",@"182780",@"182781",@"182782",@"182784",@"182787",@"182790",@"182794",@"182800",@"182802",@"182805",@"182806",@"182811",@"182816",@"182817",@"182818",@"182821",@"182823",@"182824",@"182825",@"182831",@"182841",@"182844",@"182873",@"182875",@"182895",@"182907",@"182910",@"182911",@"182913",@"182930",@"182934",@"182940",@"182944",@"182947",@"182957",@"182961",@"182962",@"182964",@"182967",@"182968",@"182970",@"182971",@"182977",@"182979",@"182980",@"182984",@"182986",@"182988",@"182989",@"182993",@"182994",@"182999",@"183000",@"183002",@"183004",@"183005",@"183008",@"183012",@"183013",@"183015",@"183017",@"183019",@"183024",@"183026",@"183027",@"183028",@"183031",@"183032",@"183034",@"183037",@"183042",@"183044",@"183045",@"183046",@"183048",@"183049",@"183056",@"183068",@"183075",@"183078",@"183084",@"183085",@"183107",@"183119",@"183137",@"183161",@"183202",@"183207",@"183208",@"183217",@"183224",@"183264",@"183287",@"183329",@"183343",@"183381",@"183389",@"183452",@"183457",@"183467",@"183469",@"183473",@"183476",@"183487",@"183492",@"183497",@"183499",@"183506",@"183511",@"183514",@"183521",@"183524",@"183527",@"183531",@"183536",@"183537",@"183543",@"183545",@"183547",@"183557",@"183558",@"183559",@"183565",@"183566",@"183568",@"183580",@"183596",@"183602",@"183607",@"183614",@"183642",@"183645",@"183646",@"183653",@"183656",@"183661",@"183664",@"183679",@"183680",@"183681",@"183688",@"183690",@"183693",@"183697",@"183698",@"183699",@"183701",@"183706",@"183709",@"183712",@"183714",@"183716",@"183717",@"183722",@"183723",@"183729",@"183730",@"183731",@"183734",@"183737",@"183742",@"183743",@"183748",@"183751",@"183753",@"183754",@"183755",@"183756",@"183758",@"183759",@"183762",@"183767",@"183769",@"183771",@"183773",@"183774",@"183776",@"183781",@"183782",@"183787",@"183788",@"183789",@"183793",@"183795",@"183798",@"183801",@"183807",@"183809",@"183823",@"183827",@"183864",@"183866",@"183870",@"183880",@"183894",@"183928",@"183937",@"183943",@"183966",@"183975",@"183992",@"183994",@"184010",@"184017",@"184019",@"184020",@"184025",@"184033",@"184039",@"184048",@"184050",@"184054",@"184057",@"184066",@"184069",@"184070",@"184078",@"184082",@"184083",@"184117",@"184173",@"184198",@"184218",@"184295",@"184324",@"184381",@"184388",@"184443",@"184462",@"184465",@"184467",@"184494"]
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
                                            
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                                           
                                        }];
}

@end
