//
//  FriendsRequestController.m
//  hiChat
//
//  Created by Polly polly on 18/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "FriendsRequestViewController.h"
#import "ContactsManager.h"
#import "FriendRequestCell.h"

@interface FriendsRequestViewController () < VIDataSourceDelegate, FriendRequestCellDelegate >

@property (nonatomic, weak)   ContactsDataSource         *dataSource;
@property (nonatomic, copy)   NSString                   *dataKey;

@end

@implementation FriendsRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新朋友";
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[FriendRequestCell class]
           forCellReuseIdentifier:[FriendRequestCell reuseIdentifier]];
    
    [self registerDataBase];
    
    [self refreshFriendRequestList];
}

- (void)refreshFriendRequestList {
    [[ContactsManager manager] requestFriendRequestListWithCompletion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[ContactsManager manager] clearUnreadFriendRequstMessageCount];
}

- (void)registerDataBase {
    self.dataSource = [ContactsDataSource sharedClient];
    self.dataKey = NSStringFromClass(self.class);
    [self.dataSource registerDelegate:self
                               entity:[FriendRequestEntity entityName]
                            predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updateAt" ascending:YES]]
                   sectionNameKeyPath:nil
                                  key:self.dataKey];
    
    [self.tableView reloadData];
}

- (UIView *)emptyViewWithTitle:(NSString *)title {
    
    UIView *emptyView = [[UIView alloc] init];
    emptyView.backgroundColor = self.tableView.backgroundColor;
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor lightGrayColor];
    label.text = title;
    [emptyView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(emptyView);
    }];
    
    return emptyView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsForKey:self.dataKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = [self.dataSource numberOfItemsForKey:self.dataKey inSection:section];
    
    if(!num) {
        tableView.backgroundView = [self emptyViewWithTitle:@"暂无好友请求"];
    } else {
        tableView.backgroundView = nil;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[FriendRequestCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(FriendRequestCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendRequsetData *data = [self.dataSource requestAtIndexPath:indexPath
                                                      forKey:self.dataKey];
    cell.delegate = self;
    cell.data = data;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

#pragma mark - FriendRequestCellDelegate

- (void)processFriendRequestWithUserid:(NSString *)userid
                                accept:(BOOL)accept
                                  cell:(nonnull FriendRequestCell *)cell {
    MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    [[ContactsManager manager] processFriendRequestWithUserid:userid
                                                       accept:accept
                                                   completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                       if(success) {
                                                           [MBProgressHUD finishHudWithResult:YES
                                                                                          hud:hud
                                                                                    labelText:[info msg]
                                                                                   completion:^{
                                                                                       [self refreshFriendRequestList];
                                                                                       
                                                                                       if(accept) {
                                                                                           [[ContactsManager manager] refreshFriendsListWithCompletion:nil];
                                                                                           
                                                                                           [[RCManager manager] startConversationWithType:ConversationType_PRIVATE
                                                                                                                                 targetId:userid
                                                                                                                                    title:cell.data.name];
                                                                                       }
                                                                                   }];
                                                       }
                                                       else {
                                                           [MBProgressHUD finishHudWithResult:success
                                                                                          hud:hud
                                                                                    labelText:@"操作失败，稍后再试"
                                                                                   completion:nil];
                                                       }
                                                   }];
}

@end
