//
//  GroupMemberSelectController.h
//  hiChat
//
//  Created by Polly polly on 17/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GroupMemberSelectDelegate <NSObject>

- (void)selectWithMembers:(nullable NSArray *)contacts;

@end

@interface GroupMemberSelectViewController : UIViewController

- (instancetype)initWithGroupid:(NSString *)groupid;

@property (nonatomic, weak)   id<GroupMemberSelectDelegate>  delegate;
@property (nonatomic, copy)   NSString                       *groupid;
@property (nonatomic, assign) BOOL                           allowMulSelect;
@property (nonatomic, assign) ContactSelectPurpose           purpose;

@end

NS_ASSUME_NONNULL_END
