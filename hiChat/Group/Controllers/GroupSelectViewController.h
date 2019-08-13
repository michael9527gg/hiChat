//
//  GroupSelectViewController.h
//  hiChat
//
//  Created by Polly polly on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GroupSelectPurposeMessageForward,
    GroupSelectPurposeMessageForwardForStaff,
    GroupSelectPurposeOther
} GroupSelectPurpose;

NS_ASSUME_NONNULL_BEGIN

@protocol GroupSelectDelegate <NSObject>

- (void)selectWithGroups:(NSArray *)groups
                 purpose:(GroupSelectPurpose)purpose;

@end

@interface GroupSelectViewController : UITableViewController

- (instancetype)initWithPurpose:(GroupSelectPurpose)purpose
                       delegate:(nullable id<GroupSelectDelegate>)delegate;

@property (nonatomic, weak)   id<GroupSelectDelegate>  delegate;
@property (nonatomic, assign) GroupSelectPurpose       purpose;
@property (nonatomic, strong) NSArray                  *groups;

@end

NS_ASSUME_NONNULL_END
