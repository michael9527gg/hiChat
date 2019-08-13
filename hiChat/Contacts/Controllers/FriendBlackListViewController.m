//
//  FriendBlackListController.m
//  hiChat
//
//  Created by Polly polly on 25/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "FriendBlackListViewController.h"
#import "ContactDetailCell.h"
#import "ConversationSettingDataSource.h"

@interface FriendBlackListViewController () < VIDataSourceDelegate >

@property (nonatomic, weak)   ContactsDataSource         *dataSource;
@property (nonatomic, copy)   NSString                   *dataKey;

@property (nonatomic, assign) BOOL                       isModified;

@end

@implementation FriendBlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"黑名单";
    
    [self.tableView registerClass:[ContactDetailCell class]
           forCellReuseIdentifier:[ContactDetailCell reuseIdentifier]];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                refreshingAction:@selector(refreshHome)];
    
    self.tableView.tableFooterView = [UIView new];
    
    [self registerDataBase];
    
    [[ContactsManager manager] requestFriendBlackListWithCompletion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(self.isModified) {
        [[ContactsManager manager] refreshFriendsListWithCompletion:nil];
    }
}

- (void)registerDataBase {
    self.dataSource = [ContactsDataSource sharedClient];
    self.dataKey = NSStringFromClass(self.class);
    [self.dataSource registerDelegate:self
                               entity:[FriendBlackEntity entityName]
                            predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]
                   sectionNameKeyPath:nil
                                  key:self.dataKey];
    
    [self.tableView reloadData];
}

- (void)refreshHome {
    [[ContactsManager manager] requestFriendBlackListWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        [self.tableView.mj_header endRefreshing];
    }];
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
        tableView.backgroundView = [self emptyViewWithTitle:@"暂无被拉黑的好友"];
    } else {
        tableView.backgroundView = nil;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[ContactDetailCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(ContactDetailCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendBlackData *data = [self.dataSource blackAtIndexPath:indexPath
                                                       forKey:self.dataKey];
    [cell setNickname:data.nickname
          displayName:nil
             portrait:data.portraitUri
                phone:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                      title:@"取消拉黑"
                                                                    handler:^(UITableViewRowAction * _Nonnull action,
                                                                              NSIndexPath * _Nonnull indexPath) {
                                                                        FriendBlackData *data = [self.dataSource blackAtIndexPath:indexPath
                                                                                                                           forKey:self.dataKey];
                                                                        [self deleteFromBlackList:data.userid];
                                                                    }];
    
    return @[delete];
}

- (void)deleteFromBlackList:(NSString *)userid {
    MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    [[ContactsManager manager] deleteBlackListWithFriendid:userid
                                                completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                    if(success) {
                                                        FriendBlackData *data = [[ContactsDataSource sharedClient] blackWithUserid:userid];
                                                        [[ContactsDataSource sharedClient] deleteObject:data];
                                                        
                                                        // 消息能力
                                                        ConversationSettingData *setting = [ConversationSettingData conversationSettingWithType:ConversationType_PRIVATE
                                                                                                                                       targetId:userid];
                                                        setting.canMessage = YES;
                                                        [[ConversationSettingDataSource sharedClient] addObject:setting
                                                                                                     entityName:[ConversationSettingEntity entityName]];
                                                        
                                                        
                                                        self.isModified = YES;
                                                    }
                                                    [MBProgressHUD finishHudWithResult:success
                                                                                   hud:hud
                                                                             labelText:success?@"取消成功":info[@"msg"]
                                                                            completion:nil];
                                                }];
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

@end
