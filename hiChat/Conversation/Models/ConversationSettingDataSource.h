//
//  ConversationSettingDataSource.h
//  hiChat
//
//  Created by Polly polly on 27/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "VICocoaTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConversationSettingData : NSObject

@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, copy)   NSString           *targetId;
@property (nonatomic, assign) BOOL               isSilent;
@property (nonatomic, assign) BOOL               isTop;

@property (nonatomic, assign) BOOL               canMessage;
@property (nonatomic, copy)   NSString           *messageError;

+ (instancetype)conversationSettingWithType:(RCConversationType)conversationType
                                   targetId:(NSString *)targetId;

@end

@interface ConversationSettingDataSource : VIDataSource

- (void)initializeSettings;

- (ConversationSettingData *)settingWithType:(RCConversationType)conversationType
                                    targetId:(NSString *)targetId;

- (NSArray *)allSettings;

@end

NS_ASSUME_NONNULL_END
