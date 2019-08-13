//
//  TextEditViewController.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TextEditViewController;

@protocol TextEditDelegate <NSObject>

- (void)textEditDidCancel:(TextEditViewController *)editor;

- (void)textEditDidSave:(TextEditViewController *)editor;

@end

@interface TextEditViewController : UITableViewController

@property (nonatomic, weak) id<TextEditDelegate>    delegate;

@property (nonatomic, copy) NSString        *text;
@property (nonatomic, copy) NSString        *placeholder;
@property (nonatomic, assign) NSInteger     maxLength;

@end

NS_ASSUME_NONNULL_END
