//
//  MessageHistoryViewController.h
//  hiChat
//
//  Created by Polly polly on 28/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageHistoryViewController : UITableViewController

@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, copy)   NSString           *targetid;
@property (nullable, nonatomic, copy)   NSString           *keywords;

@end

NS_ASSUME_NONNULL_END
