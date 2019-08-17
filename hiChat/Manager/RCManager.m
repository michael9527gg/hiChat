//
//  RCManager.m
//  hiChat
//
//  Created by Polly polly on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "RCManager.h"
#import "ConversationSettingDataSource.h"

@interface RCManager ()

@property (nonatomic, strong) NSMutableArray                            *textHistory;
@property (nonatomic, strong) NSMutableDictionary                       *cachedIndex;

@end

@implementation RCManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static RCManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[RCManager alloc] init];
    });

    return client;
}

- (instancetype)init {
    if(self = [super init]) {
        self.cachedIndex = @{}.mutableCopy;
    }

    return self;
}

- (void)refreshDataForConversationListCompletion:(CommonBlock)completion {
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    [[ContactsManager manager] refreshFriendsListWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[GroupManager manager] requestAllGroupsWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self refreshTopAndNotificationListWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            if(completion) {
                completion(YES, nil);
            }
        }];
    });
}

// 群组和联系人信息都拿到后才能同步会话免打扰和置顶状态，否则数据库可能找不到会话目标
- (void)refreshTopAndNotificationListWithCompletion:(CommonBlock)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ConversationSettingDataSource sharedInstance] initializeSettings];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestTopOrNotificationList:ConversationSettingTypeTop
                                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            [self requestTopOrNotificationList:ConversationSettingTypeNotification
                                                                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                                        if(completion) {
                                                                            completion(YES, nil);
                                                                        }
                                                                    }];
                                        });
                                    }];
        });
    });
}

- (void)requestTopOrNotificationList:(ConversationSettingType)type
                          completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = YUCLOUD_ACCOUNT_USERID;
    params[@"type"] = @(type);

    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Notification/getNotification"
                                        headers:@{@"sign": [AccountManager manager].token?:@""}
                                     parameters:params
                      constructingBodyWithBlock:nil
                                       progress:nil
                                        success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                            if ([responseObject success]) {
                                                NSArray *results = responseObject[@"result"];
                                                NSArray *settings = [[ConversationSettingDataSource sharedInstance] allSettings];

                                                for(ConversationSettingData *data in settings) {
                                                    if(type == ConversationSettingTypeNotification) {
                                                        data.isSilent = NO;
                                                    } else if(type == ConversationSettingTypeTop) {
                                                        data.isTop = NO;
                                                    }
                                                }

                                                for(ConversationSettingData *data in settings) {
                                                    for(NSDictionary *dic in results) {
                                                        NSString *conversationType = YUCLOUD_VALIDATE_STRING(dic[@"conversationType"]);
                                                        NSString *targetid = YUCLOUD_VALIDATE_STRING(dic[@"targetId"]);
                                                        if(data.conversationType == conversationType.integerValue &&
                                                           [data.targetId isEqualToString:targetid]) {
                                                            if(type == ConversationSettingTypeNotification) {
                                                                data.isSilent = YES;
                                                            } else if(type == ConversationSettingTypeTop) {
                                                                data.isTop = YES;
                                                            }
                                                        }
                                                    }

                                                    // 只同步置顶状态，免打扰是保存在融云云端
                                                    if(type == ConversationSettingTypeTop) {
                                                        BOOL result = [[RCIMClient sharedRCIMClient] setConversationToTop:data.conversationType
                                                                                                                 targetId:data.targetId
                                                                                                                    isTop:data.isTop];
                                                        if(!result) {
                                                            NSLog(@"置顶失败!");
                                                        }
                                                    }
                                                }

                                                // 同步我们的本地数据库
                                                [[ConversationSettingDataSource sharedInstance] addObjects:settings syncPredicate:nil];

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

- (void)blockConversationNotificationWithType:(RCConversationType)conversationType
                                     targetid:(NSString *)targetid
                                        block:(BOOL)block
                                   completion:(CommonBlock)completion {
    [self setTopOrNotificationWithType:ConversationSettingTypeNotification
                      conversationType:conversationType
                              targetid:targetid
                                  open:block
                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                if(success) {
                                    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:conversationType
                                                                                            targetId:targetid
                                                                                           isBlocked:block
                                                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                                                 ConversationSettingData *data = [ConversationSettingData conversationSettingWithType:conversationType targetId:targetid];
                                                                                                 data.isSilent = block;
                                                                                                 
                                                                                                 [[ConversationSettingDataSource sharedInstance] addObject:data];

                                                                                                 if (completion) {
                                                                                                     completion(YES, info);
                                                                                                 }
                                                                                             }
                                                                                               error:^(RCErrorCode status){
                                                                                                   if (completion) {
                                                                                                       completion(NO, info);
                                                                                                   }
                                                                                               }];
                                } else {
                                    if (completion) {
                                        completion(NO, nil);
                                    }
                                }
                            }];
}

- (void)topConversationNotificationWithType:(RCConversationType)conversationType
                                   targetid:(NSString *)targetid
                                        top:(BOOL)top
                                 completion:(CommonBlock)completion {
    [self setTopOrNotificationWithType:ConversationSettingTypeTop
                      conversationType:conversationType
                              targetid:targetid
                                  open:top
                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                if(success) {
                                    [[RCIMClient sharedRCIMClient] setConversationToTop:conversationType
                                                                               targetId:targetid
                                                                                  isTop:top];

                                    ConversationSettingData *data = [ConversationSettingData conversationSettingWithType:conversationType
                                                                                                                targetId:targetid];
                                    data.isTop = top;
                                    [[ConversationSettingDataSource sharedInstance] addObject:data];
                                    if (completion) {
                                        completion(YES, info);
                                    }
                                } else {
                                    if (completion) {
                                        completion(NO, info);
                                    }
                                }
                            }];
}

- (void)setTopOrNotificationWithType:(ConversationSettingType)type
                    conversationType:(RCConversationType)conversationType
                            targetid:(nonnull NSString *)targetid
                                open:(BOOL)open
                          completion:(nullable CommonBlock)completion {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = YUCLOUD_ACCOUNT_USERID;

    [params setObject:YUCLOUD_ACCOUNT_USERID forKey:@"userId"];
    [params setObject:@(conversationType) forKey:@"conversationType"];
    [params setObject:targetid forKey:@"targetId"];
    [params setObject:@(type) forKey:@"type"];
    [params setObject:@(open) forKey:@"isOpen"];

    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"Notification/setNotification"
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

- (BOOL)wordsDuplicated:(NSArray *)arr1 and:(NSArray *)arr2 {
    if (arr1.count < 5 || arr2.count < 5) {
        return NO;
    }

    NSInteger count1 = 0, count2 = 0;
    for (NSString *item in arr1) {
        if ([arr2 containsObject:item]) {
            count1++;
        }
    }

    for (NSString *item in arr2) {
        if ([arr1 containsObject:item]) {
            count2++;
        }
    }

    if (count1 == arr1.count || count2 == arr2.count) {
        // 全包含
        return YES;
    }

    return (count1 + count2) > (arr1.count + arr2.count) * 0.85;
}

- (BOOL)isDuplicatedMessage:(RCMessageContent *)message {
    if (![message isKindOfClass:[RCTextMessage class]]) {
        return NO;
    }

    if (!self.textHistory) {
        self.textHistory = [NSMutableArray new];
    }

    RCTextMessage *textMessage = (RCTextMessage *)message;
    NSArray *comps = [textMessage.content wordComponentsWithLimit:2];

    BOOL found = NO;
    for (NSArray *item in self.textHistory) {
        if ([self wordsDuplicated:item and:comps]) {
            found = YES;
            break;
        }
    }

    if (!found) {
        // 没有匹配到，需要加入到 history
        [self.textHistory addObject:comps];
        if (self.textHistory.count > 10) {
            [self.textHistory removeObjectAtIndex:0];
        }

        return NO;
    }
    else {
        // 匹配到了，直接返回
        return YES;
    }
}

- (void)removeConversation:(RCConversationType)conversationType
                  targetId:(NSString *)targetId {
    [[RCIMClient sharedRCIMClient] removeConversation:conversationType
                                             targetId:targetId];

    [[RCIMClient sharedRCIMClient] deleteMessages:conversationType
                                         targetId:targetId
                                          success:nil
                                            error:nil];

    [[RCIMClient sharedRCIMClient] clearRemoteHistoryMessages:conversationType
                                                     targetId:targetId
                                                   recordTime:0
                                                      success:nil
                                                        error:nil];
}

- (void)startConversationWithType:(RCConversationType)type
                         targetId:(NSString *)targetid
                            title:(NSString *)title {
    ConversationViewController *conversation = [[ConversationViewController alloc] init];
    conversation.conversationType = type;
    conversation.targetId = targetid;
    conversation.title = title;

    UITabBarController *tabBarController = (UITabBarController *)APP_DELEGATE_WINDOW.rootViewController;
    if(tabBarController.selectedIndex == 0) {
        UINavigationController *navi = (UINavigationController *)tabBarController.selectedViewController;
        [navi popToRootViewControllerAnimated:NO];
        [navi pushViewController:conversation animated:YES];
    } else {
        UINavigationController *naviTemp = (UINavigationController *)tabBarController.selectedViewController;
        [tabBarController setSelectedIndex:0];
        UINavigationController *navi = (UINavigationController *)tabBarController.viewControllers.firstObject;
        [navi pushViewController:conversation animated:YES];
        [naviTemp popToRootViewControllerAnimated:NO];
    }

    [self addCacheIndexForConversation:type targetid:targetid];
}

// targetid 只在某一种会话体系中是唯一的，我们需要根据 会话类型+目标id 生成唯一key值
- (NSString *)uniqueKeyForConversation:(RCConversationType)type
                              targetid:(NSString *)targetid {
    return [NSString stringWithFormat:@"%ld+%@", type, targetid];
}

- (void)addCacheIndexForConversation:(RCConversationType)type
                            targetid:(NSString *)targetid {
    if ([AccountManager manager].isSpecialOrStaff) {
        NSString *uniqueKey = [self uniqueKeyForConversation:type
                                                    targetid:targetid];

        NSNumber *number = self.cachedIndex[uniqueKey];
        if (!number) {
            __block NSInteger max = 1;
            [self.cachedIndex enumerateKeysAndObjectsUsingBlock:^(NSString *targetId, NSNumber *index, BOOL * _Nonnull stop) {
                max = MAX(max, index.integerValue + 1);
            }];

            [self.cachedIndex setObject:@(max) forKey:uniqueKey];
        }
    }
}
- (NSMutableArray *)sortConversationListDataSource:(NSMutableArray *)dataSource {
    if ([AccountManager manager].isSpecialOrStaff) {
        [dataSource sortUsingComparator:^NSComparisonResult(RCConversationModel *obj1, RCConversationModel *obj2) {
            NSString *uniqueKey1 = [self uniqueKeyForConversation:obj1.conversationType
                                                         targetid:obj1.targetId];

            NSString *uniqueKey2 = [self uniqueKeyForConversation:obj2.conversationType
                                                         targetid:obj2.targetId];

            NSNumber *number1 = self.cachedIndex[uniqueKey1];
            NSNumber *number2 = self.cachedIndex[uniqueKey2];
            if (number1 || number2) {
                if (number1 && number2) {
                    if (obj1.isTop != obj2.isTop) {
                        return obj1.isTop?NSOrderedAscending:NSOrderedDescending;
                    }
                    else {
                        return [number1 compare:number2];
                    }
                }
                else {
                    if (number1) {
                        return NSOrderedAscending;
                    }
                    else if (number2) {
                        return NSOrderedDescending;
                    }
                }
            }

            if (obj1.isTop != obj2.isTop) {
                return obj1.isTop?NSOrderedAscending:NSOrderedDescending;
            }
            else {
                return obj1.lastestMessageId < obj2.lastestMessageId;
            }
        }];
    }

    return dataSource;
}

- (void)removeCacheIndexForConversation:(RCConversationModel *)model {
    [self removeCacheIndexForConversation:model.conversationType targetid:model.targetId];
}

- (void)removeCacheIndexForConversation:(RCConversationType)type
                               targetid:(NSString *)targetid {
    if ([AccountManager manager].isSpecialOrStaff) {
        NSString *uniqueKey = [self uniqueKeyForConversation:type
                                                    targetid:targetid];

        [self.cachedIndex removeObjectForKey:uniqueKey];
    }
}

@end

