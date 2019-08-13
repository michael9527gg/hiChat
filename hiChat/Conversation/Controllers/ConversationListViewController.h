//
//  ConversationListViewController.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
#import "ContactsSelectViewController.h"

@interface ConversationListViewController : RCConversationListViewController < ContactsSelectDelegate >


@end

