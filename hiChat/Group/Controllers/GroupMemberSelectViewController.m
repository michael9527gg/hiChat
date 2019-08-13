//
//  GroupMemberSelectController.m
//  hiChat
//
//  Created by Polly polly on 17/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupMemberSelectViewController.h"
#import "ContactSelectCell.h"

@interface GroupMemberSelectViewController () < UITableViewDataSource, UITableViewDelegate, UserSelectHeaderDelegate, VIDataSourceDelegate >

@property (nonatomic, strong) UITableView             *tableView;
@property (nonatomic, strong) UserSelectHeader        *header;

@property (nonatomic, weak)   GroupDataSource         *dataSource;
@property (nonatomic, copy)   NSString                *dataKey;

@property (nonatomic, strong) NSMutableArray          *selectedMembers;

@end

@implementation GroupMemberSelectViewController

- (instancetype)initWithGroupid:(NSString *)groupid {
    if(self = [super init]) {
        self.groupid = groupid;
    }
    
    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    UserSelectHeader *header = [[UserSelectHeader alloc] initWithFrame:CGRectZero];
    header.delegate = self;
    [view addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(view);
    }];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                          style:UITableViewStylePlain];
    [tableView registerClass:[ContactSelectCell class]
           forCellReuseIdentifier:[ContactSelectCell reuseIdentifier]];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.tableFooterView = [UIView new];
    [view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(header.mas_bottom);
        make.bottom.equalTo(view);
    }];
    
    self.header = header;
    self.tableView = tableView;
    
    self.tableView.sectionIndexColor = [UIColor blackColor];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择群成员";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.selectedMembers = [NSMutableArray array];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_CANCEL
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(touchCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(touchFinish)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.header.selectPurpose = self.purpose;
    
    // 顶部视图属性配置
    if(!self.allowMulSelect) {
        GroupMemberData *member = [[GroupDataSource sharedClient] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                               groupid:self.groupid];
        if(!member.isLord && !member.isAdmin) {
            self.header.showMentionAll = NO;
        }
    }
    
    [self registerDatabase];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)registerDatabase {
    self.dataSource = [GroupDataSource sharedClient];
    self.dataKey = NSStringFromClass(self.class);
    [self.dataSource registerDelegate:self
                               entity:[GroupMemberEntity entityName]
                            predicate:[NSPredicate predicateWithFormat:@"groupid == %@", self.groupid]
                      sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                   sectionNameKeyPath:@"sectionKey"
                                  key:self.dataKey];
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
    
    return mulArr;
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
                                   entity:[GroupMemberEntity entityName]
                                predicate:predicate
                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                       sectionNameKeyPath:@"sectionKey"
                                      key:self.dataKey];
    } else {
        [self.dataSource registerDelegate:self
                                   entity:[GroupMemberEntity entityName]
                                predicate:[NSPredicate predicateWithFormat:@"groupid == %@", self.groupid]
                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                       sectionNameKeyPath:@"sectionKey"
                                      key:self.dataKey];
    }
    
    [self.tableView reloadData];
}

- (void)touchCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchFinish {
    if(self.delegate) {
        [self.delegate selectWithMembers:self.selectedMembers];
    }
    [self touchCancel];
}

- (void)refreshFinishBtnStatus {
    self.navigationItem.rightBarButtonItem.enabled = self.selectedMembers.count;
    if(self.selectedMembers.count) {
        self.title = [NSString stringWithFormat:@"已选成员(%lu)", (unsigned long)self.selectedMembers.count];
    } else {
        self.title = @"选择群成员";
    }
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsForKey:self.dataKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsForKey:self.dataKey inSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    GroupMemberData *data = [self.dataSource groupMemberAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                             forKey:self.dataKey];
    return data.sectionKey;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self refreshSectionKeys];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[ContactSelectCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ContactSelectCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupMemberData *member = [self.dataSource groupMemberAtIndexPath:indexPath
                                                               forKey:self.dataKey];
    cell.data = member;
    
    if(self.allowMulSelect) {
        SelectCellStatus status;
        GroupData *group = [[GroupDataSource sharedClient] groupWithGroupid:self.groupid];
        // 群主和自己不能删除
        if([group.creatorid isEqualToString:member.userid] ||
           [member.userid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
            status = SelectCellStatusNotEnable;
        } else if([self.selectedMembers containsObject:member.userid]) {
            status = SelectCellStatusBeSelected;
        } else {
            status = SelectCellStatusNotSelected;
        }
        
        cell.status = status;
    } else {
        // 不能@自己
        if([member.userid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
            cell.status = SelectCellStatusNotEnable;
        } else {
            cell.status = SelectCellStatusNotSelected;
        }
     }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactSelectCell *cell = (ContactSelectCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(self.allowMulSelect) {
        
        switch (cell.status) {
            case SelectCellStatusNotEnable:
                return;
                
            case SelectCellStatusNotSelected:
                [self.selectedMembers addObject:cell.userid];
                break;
            case SelectCellStatusBeSelected:
                [self.selectedMembers removeObject:cell.userid];
                break;
                
            default:
                break;
        }
        
        [self.tableView reloadData];
        
        [self refreshFinishBtnStatus];
    }
    else {
        if(cell.status != SelectCellStatusNotEnable) {
            GroupMemberData *member = [self.dataSource groupMemberAtIndexPath:indexPath
                                                                       forKey:self.dataKey];
            if(self.delegate) {
                [self.delegate selectWithMembers:@[member.userid]];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - UserSelectHeaderDelegate

- (void)searchWithText:(NSString *)searchText {
    [self refreshDataSourceWithKeywords:searchText];
}

- (void)userChooseSelectAll:(BOOL)selectAll {
    if(selectAll) {
        NSArray *members = [[GroupDataSource sharedClient] allGroupMembersForGroupid:self.groupid];
        GroupData *group = [[GroupDataSource sharedClient] groupWithGroupid:self.groupid];
        
        [self.selectedMembers removeAllObjects];
        
        for(GroupMemberData *data in members) {
            if(![group.creatorid isEqualToString:data.userid] ||
               ![data.userid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
                [self.selectedMembers addObject:data.userid];
            }
        }
    } else {
        [self.selectedMembers removeAllObjects];
    }
    
    [self.tableView reloadData];
    
    [self refreshFinishBtnStatus];
}

- (void)userChooseAllMember {
    if(self.delegate) {
        [self.delegate selectWithMembers:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
