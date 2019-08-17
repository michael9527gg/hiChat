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

@interface FriendBlackListViewController () < LYDataSourceDelegate >

@property (nonatomic, weak)   ContactsDataSource         *dataSource;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

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
    self.dataSource = [ContactsDataSource sharedInstance];
    
    self.fetchedResultsController = [self.dataSource addDelegate:self
                                                          entity:[FriendBlackEntity entityName]
                                                       predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]
                                              sectionNameKeyPath:nil];
    
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
    return [self.dataSource numberOfSections:self.fetchedResultsController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = [self.dataSource numberOfItems:self.fetchedResultsController inSection:section];
    
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
                                                   controller:self.fetchedResultsController];
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
                                                                                                                           controller:self.fetchedResultsController];
                                                                        [self deleteFromBlackList:data.userid];
                                                                    }];
    
    return @[delete];
}

- (void)deleteFromBlackList:(NSString *)userid {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[ContactsManager manager] deleteBlackListWithFriendid:userid
                                                completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                    if(success) {
                                                        FriendBlackData *data = [[ContactsDataSource sharedInstance] blackWithUserid:userid];
                                                        [[ContactsDataSource sharedInstance] deleteObject:data];
                                                        
                                                        // 消息能力
                                                        ConversationSettingData *setting = [ConversationSettingData conversationSettingWithType:ConversationType_PRIVATE
                                                                                                                                       targetId:userid];
                                                        setting.canMessage = YES;
                                                        [[ConversationSettingDataSource sharedInstance] addObject:setting];
                                                        
                                                        
                                                        self.isModified = YES;
                                                    }
                                                    
                                                    [MBProgressHUD finishLoading:hud
                                                                          result:success
                                                                            text:success?@"取消成功":info[@"msg"]
                                                                      completion:nil];
                                                }];
}

#pragma mark - LYDataSourceDelegate

- (void)didChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
