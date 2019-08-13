//
//  MessageForwardCell.h
//  hiChat
//
//  Created by Polly polly on 16/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageForwardCell : UITableViewCell

- (void)setName:(NSString *)name
       portrail:(NSString *)portrail
           type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
