//
//  ContactsViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "ContactsViewController.h"
#import "UniManager.h"
#import "ContactCell.h"
#import "GroupListViewController.h"
#import "FriendsRequestViewController.h"
#import "FriendSearchViewController.h"
#import "ContactDetailViewController.h"

@interface ContactsViewController () < VIDataSourceDelegate, UISearchBarDelegate >

@property (nonatomic, weak)   ContactsDataSource      *dataSource;
@property (nonatomic, copy)   NSString                *dataKey;
@property (nonatomic, assign) BOOL                    isSearching;
@property (nonatomic, copy)   NSString                *predicateStr;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUnreadMessage)
                                                 name:CONTACT_UNREAD_FRIENDREQUEST_NOTIFICATION
                                               object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_contacts_add"] imageResized:26]
                                                                              style:UIBarButtonItemStylePlain target:self
                                                                             action:@selector(addNewFriend)];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 56)];
    searchBar.placeholder = @"搜索好友";
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                refreshingAction:@selector(touchRefresh)];
    
    [self.tableView registerClass:[ContactCell class]
           forCellReuseIdentifier:[ContactCell reuseIdentifier]];
    
    [self.tableView registerClass:[ContactCell class]
           forCellReuseIdentifier:[ContactCell staticReuseIdentifier]];
    
    self.tableView.sectionIndexColor = [UIColor blackColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.dataSource = [ContactsDataSource sharedClient];
    self.dataKey = NSStringFromClass(self.class);
    [self.dataSource registerDelegate:self
                               entity:[ContactEntity entityName]
                            predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                   sectionNameKeyPath:@"sectionKey"
                                  key:self.dataKey];
    
    [self refreshFooterView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refreshUnreadMessage];
}

- (NSArray *)refreshSectionKeys {
    NSArray *contacts = [[ContactsDataSource sharedClient] allContactsForKey:self.dataKey];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:contacts.count];
    
    for(ContactData *contact in contacts) {
        [mulArr addObject:contact.sectionKey];
    }
    NSSet *set = [NSSet setWithArray:mulArr];
    NSArray *arrT = [set sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil
                                                                                     ascending:YES]]];
    [mulArr removeAllObjects];
    [mulArr addObjectsFromArray:arrT];
    
    return mulArr;
}

- (void)touchRefresh {
    [[ContactsManager manager] refreshFriendsListWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)setIsSearching:(BOOL)isSearching {
    _isSearching = isSearching;
    
    if(isSearching) {
        self.tableView.tableFooterView = [UIView new];
    } else {
        [self refreshFooterView];
    }
}

- (void)addNewFriend {
    FriendSearchViewController *vc = [[FriendSearchViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refreshFooterView {
    NSArray *contacts = [[ContactsDataSource sharedClient] allContacts];
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    totalLabel.textColor = [UIColor lightGrayColor];
    totalLabel.text = [NSString stringWithFormat:@"%lu位联系人", (unsigned long)contacts.count];
    totalLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableFooterView = totalLabel;
}

- (void)refreshDataSourceWithKeywords:(NSString *)keywords {
    keywords = [keywords uppercaseString];
    
    if(keywords.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(displayName CONTAINS[cd] %@ || nickname CONTAINS[cd] %@ || shengmu CONTAINS[cd] %@) && loginid == %@", keywords, keywords, keywords, YUCLOUD_ACCOUNT_USERID];
        
        if([[AccountManager manager].accountInfo.role isSpecialUser]) {
            predicate = [NSPredicate predicateWithFormat:@"(displayName CONTAINS[cd] %@ || nickname CONTAINS[cd] %@ || shengmu CONTAINS[cd] %@ || phone CONTAINS[cd] %@) && loginid == %@", keywords, keywords, keywords, keywords, YUCLOUD_ACCOUNT_USERID];
        }
        
        [self.dataSource registerDelegate:self
                                   entity:[ContactEntity entityName]
                                predicate:predicate
                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                       sectionNameKeyPath:@"sectionKey"
                                      key:self.dataKey];
    } else {
        [self.dataSource registerDelegate:self
                                   entity:[ContactEntity entityName]
                                predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                       sectionNameKeyPath:@"sectionKey"
                                      key:self.dataKey];
    }
    
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

- (void)refreshUnreadMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)showContactDetailWithId:(NSString *)uid {
    ContactDetailViewController *vc = [[ContactDetailViewController alloc] initWithUserid:uid
                                                                             user:nil
                                                                          groupid:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
    [self refreshFooterView];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.isSearching) {
        return [self.dataSource numberOfSectionsForKey:self.dataKey];
    }
    
    return [self.dataSource numberOfSectionsForKey:self.dataKey] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isSearching) {
        return [self.dataSource numberOfItemsForKey:self.dataKey inSection:section];
    }
    
    if (section == 0) {
        return 3;
    }
    else {
        return [self.dataSource numberOfItemsForKey:self.dataKey inSection:section - 1];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.isSearching) {
        ContactData *data = [self.dataSource contactAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                         forKey:self.dataKey];
        return data.sectionKey;
    }
    
    if (section == 0) {
        return nil;
    }
    else {
        ContactData *data = [self.dataSource contactAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section - 1]
                                                         forKey:self.dataKey];
        return data.sectionKey;
    }
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self refreshSectionKeys];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isSearching && indexPath.section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:[ContactCell staticReuseIdentifier]
                                               forIndexPath:indexPath];
    }
    
    return [tableView dequeueReusableCellWithIdentifier:[ContactCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ContactCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isSearching) {
        ContactData *data = [self.dataSource contactAtIndexPath:indexPath
                                                         forKey:self.dataKey];
        
        cell.portraitUri = data.portraitUri;
        cell.string = data.name;
        cell.badgeNum = 0;
        
        return;
    }
    
    if (indexPath.section == 0) {
        NSString *string;
        NSInteger badgeNum = 0;
        switch (indexPath.row) {
            case 0:
                cell.icon = [UIImage imageNamed:@"ic_contacts_new"];
                string = @"新朋友";
                badgeNum = [[ContactsManager manager] unreadFriendRequstMessageCount];
                break;
                
            case 1:
                cell.icon = [UIImage imageNamed:@"ic_contacts_group"];
                string = @"群组";
                break;
                
            case 2: {
                // 自己，获取个人信息有延时，个人信息可能是空
                AccountInfo *info = [AccountManager manager].accountInfo;
                cell.portraitUri = info.portraitUri?:[NSUserDefaults portraitUriOfUser:YUCLOUD_ACCOUNT_USERID];
                string = info.nickname?:[NSUserDefaults nameOfUser:YUCLOUD_ACCOUNT_USERID];
            }
                break;
                
            default:
                break;
        }
        
        cell.string = string;
        cell.badgeNum = badgeNum;
    }
    else {
        ContactData *data = [self.dataSource contactAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1]
                                                         forKey:self.dataKey];
        
        cell.portraitUri = data.portraitUri;
        cell.string = data.name;
        cell.badgeNum = 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.isSearching) {
        ContactData *data = [self.dataSource contactAtIndexPath:indexPath
                                                         forKey:self.dataKey];
        [self showContactDetailWithId:data.uid];
        return;
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                FriendsRequestViewController *vc = [[FriendsRequestViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            case 1: {
                GroupListViewController *vc = [[GroupListViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            case 2: {
                [self showContactDetailWithId:YUCLOUD_ACCOUNT_USERID];
            }
                break;
                
            default:
                break;
        }
    }
    else {
        ContactData *data = [self.dataSource contactAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                   inSection:indexPath.section-1]
                                                         forKey:self.dataKey];
        [self showContactDetailWithId:data.uid];
    }
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
