//
//  OnekeyImageCell.h
//  hiChat
//
//  Created by Polly polly on 31/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OnekeyImageCell;

@protocol OnekeyImageCellDelegate <NSObject>

- (void)userChooseDelete:(OnekeyImageCell *)cell;

@end

@interface OnekeyImageCell : UICollectionViewCell

@property (nonatomic, weak)   id<OnekeyImageCellDelegate> delegate;
@property (nonatomic, strong) UIImageView                 *iconView;
@property (nonatomic, assign) BOOL                        showDelete;

@end

NS_ASSUME_NONNULL_END
