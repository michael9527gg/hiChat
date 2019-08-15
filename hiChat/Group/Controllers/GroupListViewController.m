//
//  GroupListController.m
//  hiChat
//
//  Created by Polly polly on 18/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupListViewController.h"
#import "GroupListCell.h"

@interface GroupListViewController () < VIDataSourceDelegate >

@property (nonatomic, weak)   GroupDataSource         *dataSource;
@property (nonatomic, copy)   NSString                *dataKey;

@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群组";
    
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                refreshingAction:@selector(touchRefresh)];
    
    [self.tableView registerClass:[GroupListCell class]
           forCellReuseIdentifier:[GroupListCell reuseIdentifier]];
    
    [self registerDataBase];
    
    [self refreshTotalLabel];
}

- (void)refreshTotalLabel {
    NSArray *array = [self.dataSource allObjectsForKey:self.dataKey];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    numLabel.text = [NSString stringWithFormat:@"%lu个群聊", (unsigned long)array.count];
    numLabel.textColor = [UIColor grayColor];
    numLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableFooterView = numLabel;
}

- (void)touchRefresh {
    [[GroupManager manager] requestAllGroupsWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        [self.tableView.mj_header endRefreshing];
        [self refreshTotalLabel];
    }];
}

- (void)registerDataBase {
    self.dataSource = [GroupDataSource sharedClient];
    self.dataKey = NSStringFromClass(self.class);
    [self.dataSource registerDelegate:self
                               entity:[GroupEntity entityName]
                            predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"mineKey" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"sortIndex" ascending:NO]]
                   sectionNameKeyPath:@"mineKey"
                                  key:self.dataKey];
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

- (void)dealloc {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsForKey:self.dataKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = [self.dataSource numberOfItemsForKey:self.dataKey inSection:section];
    
    if(!num) {
        tableView.backgroundView = [self emptyViewWithTitle:@"暂未加入任何群组"];
    } else {
        tableView.backgroundView = nil;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[GroupListCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(GroupListCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupData *data = [self.dataSource groupAtIndexPath:indexPath
                                                 forKey:self.dataKey];
    cell.data = data;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GroupData *data = [self.dataSource groupAtIndexPath:indexPath
                                                 forKey:self.dataKey];
    ConversationViewController *conversation = [[ConversationViewController alloc] init];
    conversation.conversationType = ConversationType_GROUP;
    conversation.targetId = data.uid;
    conversation.title = data.name;
    
    [self.navigationController pushViewController:conversation animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    GroupEntity *entity = [self.dataSource objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                      forKey:self.dataKey];
    return entity.mine;
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

@end