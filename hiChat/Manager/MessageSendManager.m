//
//  MessageSendManager.m
//  hiChat
//
//  Created by Polly polly on 03/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "MessageSendManager.h"
#import "RCManager.h"
#import <UIImage+MultiFormat.h>
#import <ZXingObjC/ZXingObjC.h>
#import <LBXZBarWrapper.h>
#import <debug.h>

#pragma mark - ArrayQueue

// 静态顺序队列，方便扩展
@interface ArrayQueue : NSObject

+ (instancetype)arrayQueueWithCapacity:(NSInteger)capacity;

- (void)enqueue:(id)obj;
- (id)dequeue;
- (void)clearQueue;

@property (nonatomic, weak)   id          frontObject;
@property (nonatomic, weak)   id          rearObject;
@property (nonatomic, assign) NSInteger   length;

@end

@interface ArrayQueue()

@property (nonatomic, assign) NSInteger      capacity;
@property (nonatomic, strong) NSMutableArray *mulArray;

@end

@implementation ArrayQueue

+ (instancetype)arrayQueueWithCapacity:(NSInteger)capacity {
    return [[ArrayQueue alloc] initWithCapacity:capacity];
}

- (instancetype)initWithCapacity:(NSInteger)capacity {
    if (self = [super init]) {
        self.capacity = capacity;
        self.mulArray = [NSMutableArray arrayWithCapacity:capacity];
    }
    return self;
}

- (void)enqueue:(id)obj {
    if(self.mulArray.count == self.capacity) {
        [self.mulArray removeObjectAtIndex:0];
    }
    [self.mulArray addObject:obj];
}

- (id)dequeue {
    if(self.mulArray.count) {
        id obj = self.mulArray.firstObject;
        [self.mulArray removeObjectAtIndex:0];
        
        return obj;
    }
    
    return nil;
}

- (id)frontObject {
    return self.mulArray.firstObject;
}

- (id)rearObject {
    return self.mulArray.lastObject;
}

- (void)clearQueue {
    [self.mulArray removeAllObjects];
}

- (NSInteger)length {
    return self.mulArray.count;
}

@end

#pragma mark - MesssageItem

@implementation MesssageItem

+ (instancetype)itemWithConversationType:(RCConversationType)conversationType
                                targetid:(NSString *)targetid
                                 content:(RCMessageContent *)content {
    return [[self alloc] initWithConversationType:conversationType
                                         targetid:targetid
                                          content:content];
}

- (instancetype)initWithConversationType:(RCConversationType)conversationType
                                targetid:(NSString *)targetid
                                 content:(RCMessageContent *)content {
    if(self = [super init]) {
        self.conversationType = conversationType;
        self.targetid = targetid;
        self.content = content;
    }
    
    return self;
}

@end

#pragma mark - MessageSendManager

#define message_max_send_interval           1.0
#define message_frequency_check_num         2
#define message_frequency_check_sec_send    10
#define message_frequency_check_sec_forward 15

@interface MessageSendManager()

@property (nonatomic, strong) NSMutableArray    *messagesArray;
@property (nonatomic, strong) NSMutableArray    *overrunErrorArray;
@property (nonatomic, strong) NSMutableArray    *timeoutErrorArray;
@property (nonatomic, strong) NSMutableArray    *otherErrorArray;
@property (nonatomic, strong) NSTimer           *timer;
@property (nonatomic, strong) MBProgressHUD     *hud;
@property (nonatomic, assign) NSInteger         totalCount;
@property (nonatomic, assign) BOOL              isSending;

@property (nonatomic, strong) ArrayQueue        *historyMessageQueue;

@end

@implementation MessageSendManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static MessageSendManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[MessageSendManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        [[AccountManager manager] addObserver:self
                                   forKeyPath:ACCOUNT_STATUS_KEYPATH
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
    }
    
    return self;
}

- (ArrayQueue *)historyMessageQueue {
    if(!_historyMessageQueue) {
        _historyMessageQueue = [ArrayQueue arrayQueueWithCapacity:message_frequency_check_num];
    }
    
    return _historyMessageQueue;
}

- (NSMutableArray *)messagesArray {
    if(!_messagesArray) {
        _messagesArray = [NSMutableArray array];
    }
    
    return _messagesArray;
}

- (NSMutableArray *)overrunErrorArray {
    if(!_overrunErrorArray) {
        _overrunErrorArray = [NSMutableArray array];
    }
    return _overrunErrorArray;
}

- (NSMutableArray *)timeoutErrorArray {
    if(!_timeoutErrorArray) {
        _timeoutErrorArray = [NSMutableArray array];
    }
    return _timeoutErrorArray;
}

- (NSMutableArray *)otherErrorArray {
    if(!_otherErrorArray) {
        _otherErrorArray = [NSMutableArray array];
    }
    return _otherErrorArray;
}

- (void)initAllArray {
    [self.messagesArray removeAllObjects];
    [self.timeoutErrorArray removeAllObjects];
    [self.overrunErrorArray removeAllObjects];
    [self.otherErrorArray removeAllObjects];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:ACCOUNT_STATUS_KEYPATH]) {
        if (![[AccountManager manager] isServerSignin]) {
            if(self.isSending) {
                [self endSendLoop];
            }
            if(self.historyMessageQueue) {
                [self.historyMessageQueue clearQueue];
            }
        }
    }
}

// 单条转发可能被普通会员使用，需要限制下
- (BOOL)sendMessage:(MesssageItem *)message {
    if([self checkMessageFrequencyOverrun:FrequencyOverrunForward] ||
       [self checkDuplicatedMessage:message.content]) {
        return NO;
    }
    
    [self initAllArray];
    [self sendMessageWithItem:message];
    
    return YES;
}

// 群发是给特殊会员和内部员工使用，无需做限制
- (void)sendMessages:(NSArray *)messages {
    [self initAllArray];
    [self.messagesArray addObjectsFromArray:messages];
    
    self.totalCount = self.messagesArray.count;
    
    self.hud = [MBProgressHUD showHUDAddedTo:APP_DELEGATE_WINDOW animated:YES];
    self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    [self refreshLeftTime];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:message_max_send_interval
                                                  target:self
                                                selector:@selector(startSendLoop)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)refreshLeftTime {
    self.hud.label.text = [NSString stringWithFormat:@"发送中（预估剩余时间：%ld秒)", self.messagesArray.count/5];
}

- (void)endSendLoop {
    [self.timer invalidate];
    self.timer = nil;
    self.isSending = NO;
}

- (void)startSendLoop {
    self.isSending = YES;
    
    if(self.messagesArray.count) {
        
        NSMutableArray *mulArr = [NSMutableArray arrayWithArray:self.messagesArray];
        NSArray *subArr = [mulArr subarrayWithRange:NSMakeRange(0, MIN(5, mulArr.count))];
        
        for(MesssageItem *item in subArr) {
            [self sendMessageWithItem:item];
        }
        
        [self.messagesArray removeObjectsInArray:subArr];
        
        CGFloat curProgress = (self.totalCount-self.messagesArray.count)/(CGFloat)self.totalCount;
        
        if(self.hud.progress < curProgress) {
            self.hud.progress = curProgress;
        } else {
            self.hud.progress = 1.0;
        }
    }
    else if(self.overrunErrorArray.count) {
        [self.messagesArray addObjectsFromArray:self.overrunErrorArray];
        [self.overrunErrorArray removeAllObjects];
        // 立即开始发送, 不能浪费一秒钟
        [self startSendLoop];
    }
    else if(self.timeoutErrorArray.count) {
        [self.messagesArray addObjectsFromArray:self.timeoutErrorArray];
        [self.timeoutErrorArray removeAllObjects];
        // 立即开始发送, 不能浪费一秒钟
        [self startSendLoop];
    }
    else {
        [self endSendLoop];
        [self.hud hideAnimated:YES];
        
        if(self.delegate) {
            NSString *message = [NSString stringWithFormat:@"成功 %ld 条，失败 %ld 条", self.totalCount-self.otherErrorArray.count, self.otherErrorArray.count];
            [YuAlertViewController showAlertWithTitle:@"已发送"
                                              message:message
                                       viewController:[UniManager manager].topViewController
                                              okTitle:YUCLOUD_STRING_OK
                                             okAction:^(UIAlertAction * _Nonnull action) {
                                                 [self.delegate messagesSendSuccess:YES];
                                             }
                                          cancelTitle:nil
                                         cancelAction:nil
                                           completion:nil];
        }
    }
    
    [self refreshLeftTime];
}

- (void)startBackSend {
    if(!self.isSending) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:message_max_send_interval
                                                      target:self
                                                    selector:@selector(startSendLoop)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)sendMessageWithItem:(MesssageItem *)item {
    WEAK(self, sself);
    
    if([item.content isKindOfClass:[RCTextMessage class]]) {
        [[RCIM sharedRCIM] sendMessage:item.conversationType
                              targetId:item.targetid
                               content:item.content
                           pushContent:nil
                              pushData:nil
                               success:^(long messageId) {
                                   NSLog(@"sendTextMessage success for targetid : %@, time: %@" , item.targetid, [NSDate date]);
                               }
                                 error:^(RCErrorCode nErrorCode, long messageId) {
                                     NSLog(@"sendTextMessage error : %ld", (long)nErrorCode);
                                     
                                     // 错误消息是异步的，可能我们的定时器都结束了，但是回调还没回来
                                     if(nErrorCode == SEND_MSG_FREQUENCY_OVERRUN) {
                                         [sself.overrunErrorArray addObject:item];
                                         [[RCIMClient sharedRCIMClient] deleteMessages:@[@(messageId)]];
                                         
                                         [self startBackSend];
                                     }
                                     else if(nErrorCode == RC_MSG_RESPONSE_TIMEOUT) {
                                         [sself.timeoutErrorArray addObject:item];
                                         [[RCIMClient sharedRCIMClient] deleteMessages:@[@(messageId)]];
                                         
                                         [self startBackSend];
                                     }
                                     else {
                                         [sself.otherErrorArray addObject:item];
                                     }
                                 }];
    }
    else {
        [[RCIM sharedRCIM] sendMediaMessage:item.conversationType
                                   targetId:item.targetid
                                    content:item.content
                                pushContent:nil
                                   pushData:nil
                                   progress:nil
                                    success:^(long messageId) {
                                        NSLog(@"sendMediaMessage success for targetid : %@, time: %@" , item.targetid, [NSDate date]);
                                    }
                                      error:^(RCErrorCode errorCode, long messageId) {
                                          NSLog(@"sendMediaMessage error : %ld", (long)errorCode);
                                          
                                          if(errorCode == SEND_MSG_FREQUENCY_OVERRUN) {
                                              [sself.overrunErrorArray addObject:item];
                                              [[RCIMClient sharedRCIMClient] deleteMessages:@[@(messageId)]];
                                              
                                              [self startBackSend];
                                          }
                                          // 连接释放(30001)暂不处理，容易造成死循环
                                          else if(errorCode == RC_MSG_RESPONSE_TIMEOUT) {
                                              [sself.timeoutErrorArray addObject:item];
                                              [[RCIMClient sharedRCIMClient] deleteMessages:@[@(messageId)]];
                                              
                                              [self startBackSend];
                                          }
                                          else {
                                              [sself.otherErrorArray addObject:item];
                                          }
                                      } cancel:nil];
    }
}

- (void)sendMentionAllToGroup:(NSString *)groupid
                      message:(NSString *)message {
    RCMentionedInfo *mentionedInfo = [[RCMentionedInfo alloc] initWithMentionedType:RC_Mentioned_All
                                                                         userIdList:nil
                                                                   mentionedContent:nil];
    RCTextMessage *textMessage = [RCTextMessage messageWithContent:[NSString stringWithFormat:@"@所有人 %@", message]];
    textMessage.mentionedInfo = mentionedInfo;
    
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP
                          targetId:groupid
                           content:textMessage
                       pushContent:nil
                          pushData:nil
                           success:nil
                             error:^(RCErrorCode nErrorCode, long messageId) {
                                 NSLog(@"sendTextMessage error : %ld", (long)nErrorCode);
                             }];
}

- (BOOL)checkDuplicatedMessage:(RCMessageContent *)messageContent {
    if(![AccountManager manager].isSpecialOrStaff &&
       [[RCManager manager] isDuplicatedMessage:messageContent]) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"不能发送内容重复的消息"
                                   viewController:[UniManager manager].topViewController
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:nil
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)checkMessageFrequencyOverrun:(FrequencyOverrunType)frequencyOverrunType {
    // 直接发送限制10秒，转发UI操作本身就需要时间所以暂时限制15秒
    NSInteger interval = message_frequency_check_sec_send;
    if(frequencyOverrunType == FrequencyOverrunForward) {
        interval = message_frequency_check_sec_forward;
    }
    
    if(![AccountManager manager].isSpecialOrStaff) {
        if(self.historyMessageQueue.length == message_frequency_check_num) {
            NSDate *frontDate = (NSDate *)self.historyMessageQueue.frontObject;
            NSInteger tt = [NSDate date].timeIntervalSince1970 - frontDate.timeIntervalSince1970;
            NSLog(@"Message send interval : %ld", tt);
            if(tt < interval) {
                [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                                    withResult:NO
                                     labelText:@"您发送的太快了，请稍后再试"
                                     delayHide:YES
                                    completion:nil];
                
                return YES;
            } else {
                [self.historyMessageQueue enqueue:[NSDate date]];
            }
        } else {
            [self.historyMessageQueue enqueue:[NSDate date]];
        }
    }
    
    return NO;
}

- (void)sendMessagesToServer:(RCConversationType)conversationType
                   targetids:(NSArray *)targetids
                 messageType:(ServerMessageType)serverMessageType
                        text:(NSString *)text
                    imageUrl:(NSString *)imageUrl
                    audioUrl:(NSString *)audioUrl
                     fileUrl:(NSString *)fileUrl
                  completion:(CommonBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if(conversationType == ConversationType_GROUP) {
        [params setObject:@3 forKey:@"conversationType"];
    } else if(conversationType == ConversationType_PRIVATE) {
        [params setObject:@1 forKey:@"conversationType"];
    } else {
        NSAssert(NO, @"invalid conversation type");
    }
    
    [params setObject:targetids forKey:@"targetId"];
    
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    
    NSString *messageName = nil;
    switch (serverMessageType) {
        case ServerMessageTypeText:
            messageName = @"TextMessage";
            break;
        case ServerMessageTypeImage:
            messageName = @"ImageMessage";
            break;
        case ServerMessageTypeVoice:
            messageName = @"VoiceMessage";
            break;
        case ServerMessageTypeFile:
            messageName = @"FileMessage";
            break;
        default:
            NSAssert(NO, @"invalid server message type");
            break;
    }
    
    [content setObject:messageName forKey:@"messageName"];
    
    if(text) [content setObject:text forKey:@"content"];
    if(imageUrl) [content setObject:imageUrl forKey:@"image_url"];
    if(audioUrl) [content setObject:audioUrl forKey:@"audio_url"];
    if(fileUrl) [content setObject:fileUrl forKey:@"file_url"];
    
    [message setObject:content forKey:@"content"];
    [params setObject:message forKey:@"message"];
    
    [[CloudInterface sharedClient] doWithMethod:HttpPost
                                      urlString:@"messages/send"
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

/*
 * 目前的解码过程
 * 1. 系统解码效率比ZXing和ZBar都高，故我们优先采用高精度系统探测
 * 2. 系统高精度探测失败切换至低精度，同时灰化图片
 * 3. 采用ZXing解码，ZXing应对一般画中画效率很高
 * 4. 采用ZBar解码，如果不缩放解码失败，开启缩放再解析
 * 5. 目前已经能解析绝大部分画中画，更高精度需要开启frame移动聚焦➕缩放，测试会很消耗性能，延时较高。
 *
 * ZBar : http://zbar.sourceforge.net/iphone/sdkdoc/
 *
 */
- (BOOL)detectQRImage:(UIImage *)image {
    if ([AccountManager manager].isSpecialOrStaff) {
        return NO;
    }
    
    CIImage *sourceImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:sourceImage];
    
    if(features.count) {
        for(NSInteger index=0; index < features.count; index++) {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSLog(@"By native and high accuracy detector, decode image success with text : %@",feature.messageString);
        }
        
        return YES;
    }
    else {
        sourceImage = [CIImage imageWithCGImage:[image convertToGrayscale].CGImage];
        
        detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                      context:nil
                                      options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow }];
        features = [detector featuresInImage:sourceImage];
        if(features.count) {
            for(NSInteger index=0; index < features.count; index++) {
                CIQRCodeFeature *feature = [features objectAtIndex:index];
                NSLog(@"By native and low accuracy detector, decode image success with text : %@",feature.messageString);
            }
            
            return YES;
        }
    }

    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];

    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    [hints addPossibleFormat:kBarcodeFormatQRCode]; // 只检查QR一种类型，提高命中精度
    hints.tryHarder = YES; // try harer baby
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    if (result) {
        NSLog(@"By ZXing detector, decode image success with text : %@", result.text);

        return YES;
    }
    
    ZBarReaderController *read = [[ZBarReaderController alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    for(ZBarSymbol *symbol in [read scanImage:image.CGImage]) {
        NSString *strCode = symbol.data;
        zbar_symbol_type_t format = symbol.type;
        
        LBXZbarResult *result = [[LBXZbarResult alloc] init];
        result.strScanned = strCode;
        result.imgScanned = image;
        result.format = format;
        
        [array addObject:result];
    }
    
    if(array.count) {
        LBXZbarResult *firstObj = array.firstObject;
        NSLog(@"By ZBar detector, decode image success with text : %@", firstObj.strScanned);
        
        return YES;
    }
    
    return NO;
}

@end
