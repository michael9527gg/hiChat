//
//  TSAuthViewController.h
//  hiChat
//
//  Created by zhangliyong on 21/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "PopupViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class TSAuthViewController;

@protocol TSAuthViewControllerDelegate <NSObject>

- (void)authViewController:(TSAuthViewController *)viewController didFinishWithText:(NSString *)text;

- (void)authViewControllerDidCancel:(TSAuthViewController *)viewController;

@end

@interface TSAuthViewController : PopupViewController

@property (nonatomic, weak) id<TSAuthViewControllerDelegate>    delegate;
@property (nonatomic, copy) NSString                            *code;

- (instancetype)initWithMsg:(nullable NSString *)msg;

@end

NS_ASSUME_NONNULL_END
