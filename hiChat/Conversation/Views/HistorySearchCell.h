//
//  HistorySearchCell.h
//  hiChat
//
//  Created by Polly polly on 28/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistorySearchCell : UITableViewCell

@property (nonatomic, strong) id data;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *detailLabel;

@end

NS_ASSUME_NONNULL_END
