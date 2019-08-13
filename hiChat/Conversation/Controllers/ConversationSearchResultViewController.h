//
//  ConversationSearchResultViewController.h
//  hiChat
//
//  Created by Polly polly on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ConversationResultDelegate <NSObject>


@end

@interface ConversationSearchResultViewController : UIViewController

@property (nonatomic, weak) id<ConversationResultDelegate>  delegate;
@property (nonatomic, copy) NSString                        *searchText;

@end

NS_ASSUME_NONNULL_END
