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

- (void)kickUserssssssssByGroupId:(NSString *)groupID
                          usersId:(NSArray *)usersId
                       completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = YUCLOUD_ACCOUNT_USERID;
    [params setObject:@"82694" forKey:@"groupid"];
    
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[@"23923",@"103886",@"161339",@"164579",@"169419",@"171893",@"177332",@"177345",@"177372",@"177387",@"177411",@"177430",@"177449",@"177452",@"177466",@"177472",@"177492",@"177493",@"177497",@"177498",@"177499",@"177504",@"177535",@"177536",@"177562",@"177600",@"177637",@"177676",@"177678",@"177683",@"177689",@"177691",@"177695",@"177700",@"177714",@"177731",@"177734",@"177747",@"177748",@"177755",@"177772",@"177786",@"177796",@"177815",@"177860",@"177883",@"177932",@"177971",@"177979",@"177989",@"177990",@"177996",@"178000",@"178003",@"178008",@"178038",@"178045",@"178047",@"178053",@"178056",@"178061",@"178072",@"178075",@"178083",@"178085",@"178087",@"178169",@"178191",@"178203",@"178207",@"178213",@"178218",@"178220",@"178230",@"178236",@"178244",@"178257",@"178263",@"178270",@"178272",@"178280",@"178291",@"178332",@"178335",@"178366",@"178382",@"178388",@"178389",@"178394",@"178400",@"178404",@"178406",@"178413",@"178415",@"178416",@"178418",@"178422",@"178442",@"178447",@"178451",@"178464",@"178467",@"178468",@"178474",@"178480",@"178484",@"178502",@"178511",@"178516",@"178517",@"178518",@"178522",@"178524",@"178525",@"178526",@"178531",@"178534",@"178542",@"178545",@"178556",@"178603",@"178637",@"178640",@"178643",@"178650",@"178651",@"178652",@"178656",@"178657",@"178662",@"178668",@"178677",@"178697",@"178703",@"178710",@"178723",@"178728",@"178730",@"178734",@"178747",@"178751",@"178752",@"178755",@"178806",@"178810",@"178812",@"178821",@"178824",@"178833",@"178842",@"178845",@"178852",@"178880",@"178908",@"178975",@"179075",@"179076",@"179091",@"179093",@"179094",@"179099",@"179118",@"179131",@"179180",@"179224",@"179386",@"179488",@"179514",@"179516",@"179517",@"179518",@"179528",@"179538",@"179539",@"179541",@"179550",@"179552",@"179554",@"179556",@"179562",@"179563",@"179569",@"179583",@"179597",@"179637",@"179659",@"179661",@"179665",@"179675",@"179678",@"179683",@"179686",@"179692",@"179713",@"179727",@"179731",@"179735",@"179736",@"179742",@"179752",@"179771",@"179797",@"179800",@"179803",@"179813",@"179829",@"179843",@"179852",@"179853",@"179856",@"179858",@"179865",@"179879",@"179890",@"179902",@"179905",@"179922",@"179929",@"179930",@"179955",@"179962",@"179983",@"179987",@"179998",@"180011",@"180012",@"180014",@"180020",@"180026",@"180086",@"180089",@"180099",@"180101",@"180103",@"180111",@"180121",@"180123",@"180125",@"180126",@"180127",@"180129",@"180130",@"180138",@"180142",@"180150",@"180151",@"180156",@"180157",@"180169",@"180170",@"180175",@"180176",@"180180",@"180188",@"180190",@"180191",@"180193",@"180199",@"180204",@"180210",@"180214",@"180238",@"180240",@"180259",@"180263",@"180264",@"180289",@"180333",@"180336",@"180344",@"180345",@"180363",@"180371",@"180373",@"180375",@"180382",@"180389",@"180399",@"180406",@"180416",@"180417",@"180430",@"180442",@"180448",@"180454",@"180457",@"180458",@"180475",@"180498",@"180505",@"180525",@"180532",@"180537",@"180540",@"180541",@"180545",@"180552",@"180558",@"180562",@"180566",@"180592",@"180620",@"180631",@"180642",@"180673",@"180690",@"180714",@"180783",@"180863",@"180949",@"180952",@"180961",@"181018",@"181107",@"181110",@"181126",@"181151",@"181177",@"181185"]
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

@end
