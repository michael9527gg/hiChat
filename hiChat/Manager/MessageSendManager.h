//
//  MessageSendManager.h
//  hiChat
//
//  Created by Polly polly on 03/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "BaseManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FrequencyOverrunSend,
    FrequencyOverrunForward,
    FrequencyOverrunOther
} FrequencyOverrunType;

typedef enum : NSUInteger {
    ServerMessageTypeText,
    ServerMessageTypeImage,
    ServerMessageTypeVoice,
    ServerMessageTypeFile,
    ServerMessageTypeOther
} ServerMessageType;

@protocol MessageSendManagerDelegate <NSObject>

- (void)messagesSendSuccess:(BOOL)success;

@end

@interface MesssageItem : NSObject

@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, copy)   NSString           *targetid;
@property (nonatomic, strong) RCMessageContent   *content;

+ (instancetype)itemWithConversationType:(RCConversationType)conversationType
                                targetid:(NSString *)targetid
                                 content:(RCMessageContent *)content;

@end

@interface MessageSendManager : BaseManager

@property (nonatomic, weak) id<MessageSendManagerDelegate> delegate;

- (BOOL)sendMessage:(MesssageItem *)message;

- (void)sendMessages:(NSArray<MesssageItem *> *)messages;

- (void)sendMentionAllToGroup:(NSString *)groupid message:(NSString *)message;

- (BOOL)checkDuplicatedMessage:(RCMessageContent *)messageContent;

- (BOOL)checkMessageFrequencyOverrun:(FrequencyOverrunType)frequencyOverrunType;

- (void)sendMessagesToServer:(RCConversationType)conversationType
                   targetids:(NSArray *)targetids
                 messageType:(ServerMessageType)serverMessageType
                        text:(nullable NSString *)text
                    imageUrl:(nullable NSString *)imageUrl
                    audioUrl:(nullable NSString *)audioUrl
                     fileUrl:(nullable NSString *)fileUrl
                  completion:(nullable CommonBlock)completion;

- (BOOL)detectQRImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
