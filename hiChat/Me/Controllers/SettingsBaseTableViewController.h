//
//  SettingsBaseTableViewController.h
//  hiChat
//
//  Created by zhangliyong on 25/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsBaseTableViewController : UITableViewController

@property (nonatomic, copy) NSArray     *data;

- (NSUInteger)typeOfRowAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
