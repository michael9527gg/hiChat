//
//  TextEditCell.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TextEditCellDelegate <NSObject>

- (void)textDidEdit:(NSString *)string;

@end

@interface TextEditCell : UITableViewCell

@property (nonatomic, weak) id<TextEditCellDelegate>    delegate;

@property (nonatomic, copy) NSString        *string;
@property (nonatomic, copy) NSString        *placeholder;

@end

NS_ASSUME_NONNULL_END
