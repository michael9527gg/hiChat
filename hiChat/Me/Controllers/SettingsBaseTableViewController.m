//
//  SettingsBaseTableViewController.m
//  hiChat
//
//  Created by zhangliyong on 25/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "SettingsBaseTableViewController.h"

@interface SettingsBaseTableViewController ()

@end

@implementation SettingsBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (NSUInteger)typeOfRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = self.data[indexPath.section];
    NSNumber *item = arr[indexPath.row];
    return item.integerValue;
}

@end
