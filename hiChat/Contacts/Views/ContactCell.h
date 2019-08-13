//
//  ContactCell.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactCell : UITableViewCell

@property (nonatomic, copy) UIImage     *icon;
@property (nonatomic, copy) NSString    *portraitUri;
@property (nonatomic, copy) NSString    *string;
@property (nonatomic, assign) NSInteger badgeNum;

+ (NSString *)staticReuseIdentifier;

@end

NS_ASSUME_NONNULL_END
