//
//  ContactSelectCell.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsDataSource.h"

typedef enum : NSUInteger {
    SelectCellStatusNotSelected,
    SelectCellStatusBeSelected,
    SelectCellStatusNotEnable,
    SelectCellStatusHidden
} SelectCellStatus;

NS_ASSUME_NONNULL_BEGIN

@interface ContactSelectCell : UITableViewCell

@property (nonatomic, strong)   id                      data;
@property (nonatomic, assign)   SelectCellStatus        status;
@property (nonatomic, readonly) NSString                *userid;

@end

NS_ASSUME_NONNULL_END
