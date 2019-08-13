//
//  GroupSelectCell.h
//  hiChat
//
//  Created by Polly polly on 30/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupSelectCell : UITableViewCell

@property (nonatomic, strong)    GroupData *data;
@property (nonatomic, assign)    BOOL      userChoose;

@end

NS_ASSUME_NONNULL_END
