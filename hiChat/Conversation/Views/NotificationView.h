//
//  NotificationView.h
//  hiChat
//
//  Created by Polly polly on 17/03/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationView : UIView

+ (instancetype)show:(NotificationData *)notification;

@property (nonatomic, strong) NotificationData *notification;

@end

NS_ASSUME_NONNULL_END
