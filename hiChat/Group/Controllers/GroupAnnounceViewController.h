//
//  GroupAnnounceController.h
//  hiChat
//
//  Created by Polly polly on 21/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GroupAnnounceControllerDelegate <NSObject>

- (void)editGroupWithAnnouncement:(NSString *)announcement;

@end

@interface GroupAnnounceViewController : UIViewController

@property (nonatomic, weak)   id <GroupAnnounceControllerDelegate> delegate;

@property (nonatomic, copy)   NSString *announcement;
@property (nonatomic, assign) BOOL     isAdmin;

@end

NS_ASSUME_NONNULL_END
