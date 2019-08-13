//
//  ContactsManager.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "BaseManager.h"
#import "ContactsDataSource.h"

#define CONTACT_UNREAD_FRIENDREQUEST_NOTIFICATION    @"contact.unread.friend.request.message"
#define CONTACT_UPDATE_BLACKLIST_NOTIFICATION        @"contact.update.blacklist.notification"
#define GROUP_UPDATE_BLACKLIST_NOTIFICATION          @"group.update.blacklist.notification"
#define GROUP_UPDATE_MEMBERSLIST_NOTIFICATION         @"group.update.groupmembers.notification"
#define CONTACT_UPDATE_FRIEND_NOTIFICATION           @"contact.update.friend.notification"
#define CONTACT_UPDATE_DISPALYNAME_NOTIFICATION      @"contact.update.displayname.notification"

NS_ASSUME_NONNULL_BEGIN

@interface ContactsManager : BaseManager

+ (NSArray *)colorArray;

// 获取好友数据
- (void)refreshFriendsListWithCompletion:(nullable CommonBlock)completion;

// 获取好友请求列表
- (void)requestFriendRequestListWithCompletion:(nullable CommonBlock)completion;

// 查找好友
- (void)searchFriendWithName:(NSString *)name
                  completion:(nullable CommonBlock)completion;

// 查找用户
- (void)searchUserWithPhone:(NSString *)phone
                 completion:(nullable CommonBlock)completion;

// 添加好友
- (void)addFriendByUserid:(NSString *)userid
               completion:(nullable CommonBlock)completion;

// 响应好友请求
- (void)processFriendRequestWithUserid:(NSString *)userid
                                accept:(BOOL)accept
                            completion:(nullable CommonBlock)completion;
// 设置好友备注
- (void)updateFriendDisplayNameByUserid:(NSString *)userid
                            displayName:(NSString *)displayName
                             completion:(nullable CommonBlock)completion;

// 删除好友
- (void)deleteFriendWithUserid:(NSString *)userid
                    completion:(nullable CommonBlock)completion;

// 判断好友关系
- (void)checkFriendRelationBetweenUser:(NSString *)userid
                            completion:(nullable CommonBlock)completion;

// 黑名单列表
- (void)requestFriendBlackListWithCompletion:(nullable CommonBlock)completion;

// 拉黑
- (void)addBlackListWithFriendid:(NSString *)friendID
                      completion:(nullable CommonBlock)completion;

// 取消拉黑
- (void)deleteBlackListWithFriendid:(NSString *)friendID
                         completion:(nullable CommonBlock)completion;

// 检查消息能力
- (void)checkMessageAbilityForConversation:(RCConversationType)type
                                    target:(NSString *)targetid
                                completion:(nullable CommonBlock)completion;

- (NSUInteger)unreadFriendRequstMessageCount;

- (void)increaseUnreadFriendRequstMessageCount;

- (void)clearUnreadFriendRequstMessageCount;


@end

NS_ASSUME_NONNULL_END
