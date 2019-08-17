//
//  RCDataSource.m
//  hiChat
//
//  Created by Polly polly on 13/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "RCDataSource.h"
#import "CloudInterface.h"
#import "UserManager.h"
#import "GroupManager.h"

@interface RCDataSource()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDate *> *userInfoHistory;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDate *> *groupInfoHistory;

@end

@implementation RCDataSource

+ (RCDataSource *)shareInstance {
    static RCDataSource *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if(self = [super init]) {
        self.userInfoHistory = [NSMutableDictionary dictionary];
        self.groupInfoHistory = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - RCIMUserInfoDataSource

- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *))completion {
    __block NSString *userid = userId;
    dispatch_async(dispatch_get_main_queue(), ^{
        userid = [userid stringByReplacingOccurrencesOfString:@" " withString:@""];
        if(!userid.length) return;
        
        // 过滤错误数据
        if([userid containsString:@","]) {
            [[RCManager manager] removeConversation:ConversationType_PRIVATE
                                           targetId:userid];
            
            return;
        }
        
        // 兼容系统消息
        if([userid isEqualToString:@"admin"]) {
            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userid
                                                                 name:@"系统消息"
                                                             portrait:nil];
            return completion(userInfo);
        }
        
        ContactData *data = [[ContactsDataSource sharedInstance] contactWithUserid:userid];
        if(data) {
            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:data.uid
                                                                 name:data.name
                                                             portrait:data.portraitUri];
            return completion(userInfo);
        } else {
            NSDate *lastDate = [self.userInfoHistory valueForKey:userid];
            // 同一个用户限制一秒内
            if(!lastDate || ([NSDate date].timeIntervalSince1970 - lastDate.timeIntervalSince1970) > 1) {
                [self.userInfoHistory setValue:[NSDate date] forKey:userid];
                
                [[UserManager manager] requesUserInfoWithUserid:userid
                                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                         if(success) {
                                                             // 这里涉及到好友备注的问题
                                                             UserData *user = [info valueForKey:@"data"];
                                                             
                                                             NSString *name = user.name;
                                                             ContactData *contact = [[ContactsDataSource sharedInstance] contactWithUserid:user.uid];
                                                             if(contact) {
                                                                 name = contact.name;
                                                             }
                                                             RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:user.uid
                                                                                                                  name:name
                                                                                                              portrait:user.portrait];
                                                             return completion(userInfo);
                                                         }
                                                         else if([info code] == 1000) {
                                                             RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userid
                                                                                                                  name:@"用户已注销"
                                                                                                              portrait:nil];
                                                             return completion(userInfo);
                                                         }
                                                     }];
            }
        }
    });
}

#pragma mark - RCIMGroupInfoDataSource

- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *))completion {
    __block NSString *groupid = groupId;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!groupid.length) return;
        
        // 优先用缓存
        GroupData *data = [[GroupDataSource sharedInstance] groupWithGroupid:groupid];
        
        if(data) {
            RCGroup *groupInfo = [[RCGroup alloc] initWithGroupId:data.uid
                                                        groupName:data.name
                                                      portraitUri:[data.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]];
            
            return completion(groupInfo);
        } else {
            NSDate *lastDate = [self.groupInfoHistory valueForKey:groupid];
            // 同一个群组限制一秒内
            if(!lastDate || ([NSDate date].timeIntervalSince1970 - lastDate.timeIntervalSince1970) > 1) {
                [self.groupInfoHistory setValue:[NSDate date] forKey:groupid];
                [[GroupManager manager] requesGroupInfoWithGroupId:groupid
                                                        completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                            NSString *reason = YUCLOUD_VALIDATE_STRING([info valueForKey:@"reason"]);
                                                            if(success) {
                                                                GroupData *group = info[@"data"];
                                                                RCGroup *groupInfo = [[RCGroup alloc] initWithGroupId:group.uid
                                                                                                            groupName:group.name
                                                                                                          portraitUri:[group.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]];
                                                                
                                                                return completion(groupInfo);
                                                            }
                                                            else if([reason isEqualToString:@"notExist"]) {
                                                                [[RCManager manager] removeConversation:ConversationType_GROUP
                                                                                               targetId:groupid];
                                                            }
                                                        }];
            }
        }
    });
}

#pragma mark - RCIMGroupMemberDataSource

- (void)getAllMembersOfGroup:(NSString *)groupId
                      result:(void (^)(NSArray<NSString *> *))resultBlock {
    if(!groupId.length) return;
    
    [[GroupManager manager] requesGroupMembersWithGroupId:groupId
                                               completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                   if(success) {
                                                       NSArray *members = [info valueForKey:@"data"];
                                                       NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:members.count];
                                                       for(GroupMemberData *data in members) {
                                                           [mulArr addObject:data.userid];
                                                       }
                                                       
                                                       return resultBlock(mulArr);
                                                   } else {
                                                       return resultBlock(nil);
                                                   }
                                               }];
}

@end
