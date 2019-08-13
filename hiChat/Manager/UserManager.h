//
//  UserManager.h
//  hiChat
//
//  Created by Polly polly on 16/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "BaseManager.h"

#define CONVERSATION_CLEAR_MESSAGE_NOTIFIACTION       @"conversation.clear.message.notification"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : BaseManager

- (void)refreshCurrentUserInfo;

- (void)requesUserInfoWithUserid:(NSString *)userid
                      completion:(nullable CommonBlock)completion;

// 刷新融云用户信息缓存
- (void)refreshRCUserInfoCacheWithUserid:(nullable NSString *)userid
                                userInfo:(nullable RCUserInfo *)userInfo
                              completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
