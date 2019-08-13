//
//  RCManager.h
//  hiChat
//
//  Created by Polly polly on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "BaseManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ConversationSettingTypeNotification = 1,
    ConversationSettingTypeTop,
} ConversationSettingType;

@interface RCManager : BaseManager

- (void)refreshDataForConversationListCompletion:(nullable CommonBlock)completion;

- (void)refreshTopAndNotificationListWithCompletion:(nullable CommonBlock)completion;

- (void)requestTopOrNotificationList:(ConversationSettingType)type
                          completion:(nullable CommonBlock)completion;

- (void)blockConversationNotificationWithType:(RCConversationType)conversationType
                                     targetid:(NSString *)targetid
                                        block:(BOOL)block
                                   completion:(nullable CommonBlock)completion;

- (void)topConversationNotificationWithType:(RCConversationType)conversationType
                                   targetid:(NSString *)targetid
                                        top:(BOOL)top
                                 completion:(nullable CommonBlock)completion;

- (BOOL)isDuplicatedMessage:(RCMessageContent *)message;

- (void)removeConversation:(RCConversationType)conversationType
                  targetId:(NSString *)targetId;

- (void)startConversationWithType:(RCConversationType)type
                         targetId:(NSString *)targetid
                            title:(NSString *)title;

- (NSMutableArray *)sortConversationListDataSource:(NSMutableArray *)dataSource;

- (void)removeCacheIndexForConversation:(RCConversationModel *)model;
    
@end

NS_ASSUME_NONNULL_END
