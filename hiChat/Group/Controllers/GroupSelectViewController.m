//
//  GroupSelectViewController.m
//  hiChat
//
//  Created by Polly polly on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupSelectViewController.h"
#import "GroupListCell.h"
#import "GroupOnekeyEditViewController.h"
#import "ContactSelectCell.h"

@interface GroupSelectViewController () < VIDataSourceDelegate, UISearchBarDelegate >

@property (nonatomic, weak)   GroupDataSource         *dataSource;
@property (nonatomic, copy)   NSString                *dataKey;
@property (nonatomic, strong) NSMutableArray          *selectArr;

@end

@implementation GroupSelectViewController

- (instancetype)initWithPurpose:(GroupSelectPurpose)purpose
                       delegate:(id<GroupSelectDelegate>)delegate {
    if(self = [super init]) {
        self.purpose = purpose;
        self.delegate = delegate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择群组";
    
    self.selectArr = [NSMutableArray array];
    
    [self.selectArr addObjectsFromArray:self.groups];
    
    if(self.purpose != GroupSelectPurposeMessageForward) {
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                 target:self
                                                                                 action:@selector(touchFinish)];
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectBtn setTitle:@"全选" forState:UIControlStateNormal];
        [selectBtn setTitle:@"取消" forState:UIControlStateSelected];
        [selectBtn addTarget:self
                      action:@selector(touchSelectAll:)
            forControlEvents:UIControlEventTouchUpInside];
        [selectBtn sizeToFit];
        
        UIBarButtonItem *allBtn = [[UIBarButtonItem alloc] initWithCustomView:selectBtn];
        
        if(self.purpose != GroupSelectPurposeMessageForwardForStaff) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                  target:self
                                                                                                  action:@selector(touchCancel)];
            self.navigationItem.rightBarButtonItems = @[doneBtn, allBtn];
        } else {
            self.navigationItem.rightBarButtonItems = @[allBtn];
        }
    }
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 56)];
    searchBar.placeholder = @"搜索群组";
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    
    self.tableView.tableFooterView = [UIView new];

    self.tableView.sectionIndexColor = [UIColor blackColor];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    [self.tableView registerClass:[GroupListCell class]
           forCellReuseIdentifier:[GroupListCell reuseIdentifier]];
    [self.tableView registerClass:[ContactSelectCell class]
           forCellReuseIdentifier:[ContactSelectCell reuseIdentifier]];
    
    [self registerDataBase];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(self.purpose == GroupSelectPurposeMessageForwardForStaff) {
        if(self.delegate) {
            [self.delegate selectWithGroups:self.selectArr
                                    purpose:self.purpose];
        }
    }
}

- (NSArray *)refreshSectionKeys {
    NSArray *contacts = [[GroupDataSource sharedClient] allGroupsForKey:self.dataKey];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:contacts.count];
    
    for(GroupData *contact in contacts) {
        [mulArr addObject:contact.sectionKey];
    }
    NSSet *set = [NSSet setWithArray:mulArr];
    NSArray *arrT = [set sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil
                                                                                     ascending:YES]]];
    [mulArr removeAllObjects];
    [mulArr addObjectsFromArray:arrT];
    
    return mulArr;
}

- (void)registerDataBase {
    self.dataSource = [GroupDataSource sharedClient];
    self.dataKey = NSStringFromClass(self.class);
    [self.dataSource registerDelegate:self
                               entity:[GroupEntity entityName]
                            predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                   sectionNameKeyPath:@"sectionKey"
                                  key:self.dataKey];
    
    [self.tableView reloadData];
}

- (void)refreshDataSourceWithKeywords:(NSString *)keywords {
    keywords = [keywords uppercaseString];
    
    if(keywords.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(shengmu CONTAINS[cd] %@ || name CONTAINS[cd] %@) && loginid == %@", keywords, keywords, YUCLOUD_ACCOUNT_USERID];
        [self.dataSource registerDelegate:self
                                   entity:[GroupEntity entityName]
                                predicate:predicate
                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                       sectionNameKeyPath:nil
                                      key:self.dataKey];
    } else {
        [self.dataSource registerDelegate:self
                                   entity:[GroupEntity entityName]
                                predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                       sectionNameKeyPath:@"sectionKey"
                                      key:self.dataKey];
    }
    
    [self.tableView reloadData];
}

- (void)touchFinish {
    if(self.purpose == GroupSelectPurposeMessageForwardForStaff) {
        if(self.delegate) {
            [self.delegate selectWithGroups:self.selectArr
                                    purpose:self.purpose];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if(!self.selectArr.count) {
            [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                                withResult:NO
                                 labelText:@"发送群组不能为空"
                                 delayHide:YES
                                completion:nil];
            
            return;
        }
        
        GroupOnekeyEditViewController *edit = [[GroupOnekeyEditViewController alloc] initWithOnekeyEditType:OnekeyEditTypeGroup
                                                                                                       data:self.selectArr];
        [self.navigationController pushViewController:edit animated:YES];
    }
}

- (void)touchSelectAll:(UIButton *)button {
    button.selected = !button.isSelected;
    
    if(button.isSelected) {
        [self.selectArr removeAllObjects];
        
        NSArray *groups = [self.dataSource allGroupsForKey:self.dataKey];
        for(GroupData *data in groups) {
            [self.selectArr addObject:data.uid];
        }
    }
    else {
        [self.selectArr removeAllObjects];
    }
    
    [self.tableView reloadData];
}

- (void)touchCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        tableView.backgroundView = [self emptyViewWithTitle:@"暂无符合条件的群组"];
    } else {
        tableView.backgroundView = nil;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.purpose == GroupSelectPurposeMessageForwardForStaff) {
        return [tableView dequeueReusableCellWithIdentifier:[ContactSelectCell reuseIdentifier]
                                               forIndexPath:indexPath];
    }
    return [tableView dequeueReusableCellWithIdentifier:[GroupListCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupData *data = [self.dataSource groupAtIndexPath:indexPath
                                                 forKey:self.dataKey];
    
    if(self.purpose == GroupSelectPurposeMessageForwardForStaff) {
        ContactSelectCell *cCell = (ContactSelectCell *)cell;
        cCell.data = data;
        cCell.status = [self.selectArr containsObject:data.uid];
    } else {
        GroupListCell *gCell = (GroupListCell *)cell;
        gCell.data = data;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    GroupData *data = [self.dataSource groupAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                 forKey:self.dataKey];
    return data.sectionKey;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self refreshSectionKeys];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupData *data = [self.dataSource groupAtIndexPath:indexPath
                                                 forKey:self.dataKey];
    
    if(self.purpose == GroupSelectPurposeMessageForward) {
        [self.selectArr addObject:data.uid];
        if(self.delegate) {
            [self.delegate selectWithGroups:self.selectArr
                                    purpose:self.purpose];
        }
    } else if(self.purpose == GroupSelectPurposeMessageForwardForStaff) {
        if([self.selectArr containsObject:data.uid]) {
            [self.selectArr removeObject:data.uid];
        } else {
            [self.selectArr addObject:data.uid];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self refreshDataSourceWithKeywords:searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [self refreshDataSourceWithKeywords:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    [self refreshDataSourceWithKeywords:searchText];
}

@end
