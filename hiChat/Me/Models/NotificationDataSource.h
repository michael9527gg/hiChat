//
//  NotificationDataSource.h
//  hiChat
//
//  Created by Polly polly on 27/02/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "VICocoaTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationData : NSObject

@property (nonatomic, copy)   NSString *uid;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *content;
@property (nonatomic, copy)   NSDate   *time;
@property (nonatomic, assign) BOOL     read;
@property (nonatomic, assign) BOOL     alert;

+ (instancetype)notificationWithData:(NSDictionary *)data;

@end

@interface NotificationDataSource : VIDataSource

- (NotificationData *)notificationAtIndexPath:(NSIndexPath *)indexPath
                                       forKey:(NSString *)key;

- (NotificationData *)notificationWithUid:(NSString *)uid;

- (NSInteger)unReadNotificationsCount;

- (void)clearAllNotifications;

@end

NS_ASSUME_NONNULL_END
