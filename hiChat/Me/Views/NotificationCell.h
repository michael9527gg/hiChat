//
//  NotificationCell.h
//  hiChat
//
//  Created by Polly polly on 27/02/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationCell : UITableViewCell

@property (nonatomic, strong) NotificationData *data;

@end

NS_ASSUME_NONNULL_END
