//
//  ContactsSelectViewController.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsDataSource.h"
#import "UserSelectHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class ContactsSelectViewController;

@protocol ContactsSelectDelegate <NSObject>

- (void)selectWithContacts:(NSArray *)contacts
                   purpose:(ContactSelectPurpose)purpose
                 mulSelect:(BOOL)mulSelect;

@end

@interface ContactsSelectViewController : UIViewController

- (instancetype)initWithPurpose:(ContactSelectPurpose)purpose
                 allowMulSelect:(BOOL)allowMulSelect
                       delegate:(id<ContactsSelectDelegate>)delegate
                        groupid:(nullable NSString *)groupid;

@property (nonatomic, weak)   id<ContactsSelectDelegate>  delegate;
@property (nonatomic, assign) ContactSelectPurpose        purpose;
@property (nonatomic, assign) BOOL                        allowMulSelect;
@property (nonatomic, strong) NSArray                     *selectedContacts;

@end

NS_ASSUME_NONNULL_END
