//
//  MessageForwardSearchResultViewController.h
//  hiChat
//
//  Created by Polly polly on 08/03/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TargetSearchResultControllerDelegate <NSObject>

- (void)searchResultChooseTarget:(id)target;

@end

@interface MessageForwardSearchResultViewController : UITableViewController

@property (nonatomic, weak)   id <TargetSearchResultControllerDelegate> delegate;
@property (nonatomic, copy)   NSString                *searchText;

@end

NS_ASSUME_NONNULL_END
