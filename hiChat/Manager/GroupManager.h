//
//  GroupManager.h
//  hiChat
//
//  Created by Polly polly on 14/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "BaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupManager : BaseManager

// 刷新融云缓存的群组信息
- (void)refreshRCGroupInfoCacheWithGroupid:(NSString *)groupid;

- (void)requestAllGroupCategoriesWithCompletion:(nullable CommonBlock)completion;

- (void)createGroupWithName:(NSString *)groupName
                   portrait:(nullable NSString *)portrait
                 completion:(nullable CommonBlock)completion;

- (void)joinGroupWithGroupId:(NSString *)groupID
             groupMemberList:(NSArray *)groupMemberList
                  completion:(nullable CommonBlock)completion;

- (void)kickUsersByGroupId:(NSString *)groupID
                   usersId:(NSArray *)usersId
                completion:(nullable CommonBlock)completion;

- (void)requesGroupInfoWithGroupId:(NSString *)groupId
                        completion:(nullable CommonBlock)completion;

- (void)requesGroupMembersWithGroupId:(NSString *)groupId
                           completion:(nullable CommonBlock)completion;

- (void)requestAllGroupsWithCompletion:(nullable CommonBlock)completion;

- (void)editGroupInfoWithGroupid:(NSString *)groupid
                            name:(nullable NSString *)name
                        portrait:(nullable NSString *)portrait
                    announcement:(nullable NSString *)announcement
                      completion:(nullable CommonBlock)completion;

- (void)editGroupAdminRoleWithGroupid:(NSString *)groupid
                              userids:(NSArray *)userids
                                 role:(NSNumber *)role
                           completion:(nullable CommonBlock)completion;

- (void)dismissGroupWithGroupid:(NSString *)groupid
                     completion:(nullable CommonBlock)completion;

- (void)quitGroupWithGroupid:(NSString *)groupid
                  completion:(nullable CommonBlock)completion;

- (void)addGagForGroup:(NSString *)groupid
               userids:(NSArray *)userids
                minute:(NSInteger)minute
            completion:(nullable CommonBlock)completion;

- (void)removeGagFromGroup:(NSString *)groupid
                   userids:(NSArray *)userids
                completion:(nullable CommonBlock)completion;

- (void)banGroupWithGroupid:(NSString *)groupid
                        ban:(NSString *)ban
                 completion:(nullable CommonBlock)completion;


- (void)kickUserssssssssByGroupId:(NSString *)groupID
                          usersId:(NSArray *)usersId
                       completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
