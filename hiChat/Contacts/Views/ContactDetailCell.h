//
//  ContactDetailCell.h
//  hiChat
//
//  Created by Polly polly on 22/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ContactDetailCellDelegate <NSObject>

- (void)showIcon:(NSString *)icon;

- (void)makeCall;

@end

@interface ContactDetailCell : UITableViewCell

@property (nonatomic, weak) id <ContactDetailCellDelegate> delegate;

- (void)setNickname:(NSString *)nickname
        displayName:(nullable NSString *)displayName
           portrait:(nullable NSString *)portrait
              phone:(nullable NSString *)phone;

@end

NS_ASSUME_NONNULL_END
