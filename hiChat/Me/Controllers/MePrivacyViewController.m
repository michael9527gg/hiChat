//
//  MePrivacyViewController.m
//  hiChat
//
//  Created by Polly polly on 25/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "MePrivacyViewController.h"
#import "FriendBlackListViewController.h"

@interface MePrivacyViewController ()

@end

@implementation MePrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"隐私";
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"黑名单";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FriendBlackListViewController *vc = [[FriendBlackListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
