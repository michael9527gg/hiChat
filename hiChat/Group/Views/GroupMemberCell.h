//
//  GroupMemberCell.h
//  hiChat
//
//  Created by Polly polly on 17/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupMemberCell : UICollectionViewCell

@property (nonatomic, strong) GroupMemberData *groupMember;
@property (nonatomic, strong) UIImage         *functionImage;

@end

NS_ASSUME_NONNULL_END
