//
//  ContactDetailController.h
//  hiChat
//
//  Created by Polly polly on 19/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactDetailViewController : UITableViewController

- (instancetype)initWithUserid:(NSString *)userid
                          user:(nullable UserData *)user
                       groupid:(nullable NSString *)groupid;

@end

NS_ASSUME_NONNULL_END
