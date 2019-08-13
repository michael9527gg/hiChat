//
//  UserSelectHeader.h
//  hiChat
//
//  Created by Polly polly on 17/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ContactSelectPurposeStartChat,
    ContactSelectPurposeCreateGroup,
    ContactSelectPurposeInviteGroupMember,
    ContactSelectPurposeMentionSomebody,
    ContactSelectPurposeMessageForward,
    ContactSelectPurposeMessageForwardForStaff,
    ContactSelectPurposeOneKey,
    ContactSelectPurposeOther
} ContactSelectPurpose;

@protocol UserSelectHeaderDelegate <NSObject>

@optional;

- (void)searchWithText:(NSString *)searchText;

- (void)userChooseSelectAll:(BOOL)selectAll;

- (void)userChooseAllMember;

@end

@interface UserSelectHeader : UIView

@property (nonatomic, weak)   id<UserSelectHeaderDelegate>  delegate;
@property (nonatomic, assign) ContactSelectPurpose          selectPurpose;
@property (nonatomic, assign) BOOL                          showMentionAll;

@end

NS_ASSUME_NONNULL_END
