//
//  GroupOnekeyEditViewController.h
//  hiChat
//
//  Created by Polly polly on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageSendManager.h"

typedef enum : NSUInteger {
    OnekeyEditTypeContact,
    OnekeyEditTypeGroup,
    OnekeyEditTypeOther
} OnekeyEditType;

NS_ASSUME_NONNULL_BEGIN

@interface GroupOnekeyEditViewController : UIViewController

- (instancetype)initWithOnekeyEditType:(OnekeyEditType)onekeyEditType
                                  data:(NSArray *)data;

@end

NS_ASSUME_NONNULL_END
