//
//  InfoDetailCell.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InfoDetailCell : UITableViewCell

- (void)setIcon:(UIImage *)icon
           name:(NSString *)name
         detail:(nullable NSString *)detail;

@end

NS_ASSUME_NONNULL_END
