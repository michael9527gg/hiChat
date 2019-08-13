//
//  GroupMemberListController.m
//  hiChat
//
//  Created by Polly polly on 17/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupMemberListViewController.h"
#import "GroupMemberListCell.h"
#import "ContactDetailViewController.h"

@interface GroupMemberListViewController () < VIDataSourceDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate >

@property (nonatomic, strong) UITableView             *tableView;

@property (nonatomic, weak)   GroupDataSource         *dataSource;
@property (nonatomic, copy)   NSString                *dataKey;

@property (nonatomic, strong) NSMutableArray          *adminDataSource;
@property (nonatomic, assign) BOOL                    isSearching;

@end

@implementation GroupMemberListViewController

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 56)];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    
    [self.tableView registerClass:[GroupMemberListCell class]
           forCellReuseIdentifier:[GroupMemberListCell reuseIdentifier]];
    self.tableView.sectionIndexColor = [UIColor blackColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.tableView.tableFooterView = [UIView new];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"成员列表";
    
    [self registerDataBase];
}

- (NSArray *)refreshSectionKeys {
    NSArray *contacts = [[GroupDataSource sharedClient] allGroupMembersForKey:self.dataKey];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:contacts.count];
    
    for(GroupMemberData *contact in contacts) {
        [mulArr addObject:contact.sectionKey];
    }
    NSSet *set = [NSSet setWithArray:mulArr];
    NSArray *arrT = [set sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil
                                                                                     ascending:YES]]];
    [mulArr removeAllObjects];
    [mulArr addObjectsFromArray:arrT];
    
    if(!self.isSearching) {
        if(self.adminDataSource.count > 1) {
            [mulArr insertObject:@"管理" atIndex:0];
        }
        [mulArr insertObject:@"群主" atIndex:0];
    }
    
    return mulArr;
}

- (void)registerDataBase {
    self.dataSource = [GroupDataSource sharedClient];
    self.dataKey = NSStringFromClass(self.class);
    [self.dataSource registerDelegate:self
                               entity:[GroupMemberEntity entityName]
                            predicate:[NSPredicate predicateWithFormat:@"groupid == %@ && groupRole == %@", self.groupid, @"0"]
                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                   sectionNameKeyPath:@"sectionKey"
                                  key:self.dataKey];
    
    GroupMemberData *lord = [[GroupDataSource sharedClient] groupLordForGroupid:self.groupid];
    NSArray *admins = [[GroupDataSource sharedClient] groupAdminsForGroupid:self.groupid];
    if(lord) {
        self.adminDataSource = [NSMutableArray arrayWithObject:lord];
        [self.adminDataSource addObjectsFromArray:admins];
    }
}

- (void)refreshDataSourceWithKeywords:(NSString *)keywords {
    keywords = [keywords uppercaseString];
    
    if(keywords.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS %@ || shengmu CONTAINS %@) && groupid == %@", keywords, keywords, self.groupid];
        // 群组或者管理员可以使用手机号查询
        GroupMemberData *curMember = [[GroupDataSource sharedClient] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                                  groupid:self.groupid];
        if(curMember.isLord || curMember.isAdmin) {
            predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS %@ || shengmu CONTAINS %@ || phone CONTAINS %@) && groupid == %@", keywords, keywords, keywords, self.groupid];
        }
        
        [self.dataSource registerDelegate:self
                                   entity:[ContactEntity entityName]
                                predicate:predicate
                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                       sectionNameKeyPath:@"sectionKey"
                                      key:self.dataKey];
    } else {
        if(self.isSearching) {
            [self.dataSource registerDelegate:self
                                       entity:[GroupMemberEntity entityName]
                                    predicate:[NSPredicate predicateWithFormat:@"groupid == %@", self.groupid]
                              sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                           sectionNameKeyPath:@"sectionKey"
                                          key:self.dataKey];
        } else {
            [self.dataSource registerDelegate:self
                                       entity:[GroupMemberEntity entityName]
                                    predicate:[NSPredicate predicateWithFormat:@"groupid == %@ && groupRole == %@", self.groupid, @"0"]
                              sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                           sectionNameKeyPath:@"sectionKey"
                                          key:self.dataKey];
        }
    }
    
    [self.tableView reloadData];
}

- (void)dealloc {
    
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.isSearching) {
        return [self.dataSource numberOfSectionsForKey:self.dataKey];
    }
    return [self.dataSource numberOfSectionsForKey:self.dataKey] + MIN(self.adminDataSource.count, 2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isSearching) {
        return [self.dataSource numberOfItemsForKey:self.dataKey
                                          inSection:section];
    }
    
    if(section == 0) {
        return 1;
    }
    else if((section == 1) && (self.adminDataSource.count > 1)) {
        return self.adminDataSource.count-1;
    }
    
    return [self.dataSource numberOfItemsForKey:self.dataKey
                                      inSection:section-MIN(self.adminDataSource.count, 2)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.isSearching) {
        GroupMemberData *data = [self.dataSource groupMemberAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                           inSection:section]
                                                                 forKey:self.dataKey];
        return data.sectionKey;
    }
    
    if(section == 0) {
        return @"群主";
    }
    else if((section == 1) && (self.adminDataSource.count > 1)) {
        return @"管理员";
    }
    
    GroupMemberData *data = [self.dataSource groupMemberAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                       inSection:section-MIN(self.adminDataSource.count, 2)]
                                                             forKey:self.dataKey];
    return data.sectionKey;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self refreshSectionKeys];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[GroupMemberListCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(GroupMemberListCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isSearching) {
        cell.data = [self.dataSource groupMemberAtIndexPath:indexPath
                                                     forKey:self.dataKey];
        return;
    }
    
    if(indexPath.section == 0) {
        GroupMemberData *lord = (GroupMemberData *)self.adminDataSource.firstObject;
        cell.data = lord;
        
        return;
    }
    else if((indexPath.section == 1) && (self.adminDataSource.count > 1)) {
        GroupMemberData *admin = self.adminDataSource[indexPath.row+1];
        cell.data = admin;
        
        return;
    }
    
    cell.data = [self.dataSource groupMemberAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                           inSection:indexPath.section-MIN(self.adminDataSource.count, 2)]
                                                 forKey:self.dataKey];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GroupMemberData *member = nil;
    
    if(self.isSearching) {
        member = [self.dataSource groupMemberAtIndexPath:indexPath
                                                  forKey:self.dataKey];
    } else {
        if(indexPath.section == 0) {
            member = (GroupMemberData *)self.adminDataSource.firstObject;
        }
        else if((indexPath.section == 1) && (self.adminDataSource.count > 1)) {
            member = self.adminDataSource[indexPath.row+1];
        }
        else {
            member = [self.dataSource groupMemberAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                inSection:indexPath.section-MIN(self.adminDataSource.count, 2)]
                                                      forKey:self.dataKey];
        }
    }
    
    ContactDetailViewController *vc = [[ContactDetailViewController alloc] initWithUserid:member.userid
                                                                                     user:nil
                                                                                  groupid:self.groupid];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.isSearching = NO;
    [self refreshDataSourceWithKeywords:searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.isSearching = YES;
    [self refreshDataSourceWithKeywords:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    [self refreshDataSourceWithKeywords:searchText];
}

@end
