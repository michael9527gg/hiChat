//
//  FriendRequestCell.h
//  hiChat
//
//  Created by Polly polly on 20/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FriendRequestCell;

@protocol FriendRequestCellDelegate <NSObject>

- (void)processFriendRequestWithUserid:(NSString *)userid
                                accept:(BOOL)accept
                                  cell:(FriendRequestCell *)cell;

@end

@interface FriendRequestCell : UITableViewCell

@property (nonatomic, strong) FriendRequsetData *data;
@property (nonatomic, weak)   id <FriendRequestCellDelegate> delegate;

- (void)updateRequestStatus:(FriendRequestStatus)requestStatus;

@end

NS_ASSUME_NONNULL_END
