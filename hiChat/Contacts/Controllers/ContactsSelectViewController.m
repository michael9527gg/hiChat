//
//  ContactsSelectViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "ContactsSelectViewController.h"
#import "UniManager.h"
#import "GroupInfoEditViewController.h"
#import "GroupOnekeyEditViewController.h"
#import "ContactSelectCell.h"

@interface ContactsSelectViewController () < LYDataSourceDelegate, UITableViewDataSource, UITableViewDelegate, UserSelectHeaderDelegate >

@property (nonatomic, strong) UITableView             *tableView;
@property (nonatomic, strong) UserSelectHeader        *header;

@property (nonatomic, weak)   ContactsDataSource      *dataSource;
@property (nonatomic, strong)   NSFetchedResultsController                *fetchedResultsController;

@property (nonatomic, strong) NSMutableArray          *selectedResult;
@property (nonatomic, strong) NSMutableArray          *groupMembers;
@property (nonatomic, copy)   NSString                *groupid;


@end

@implementation ContactsSelectViewController

- (instancetype)initWithPurpose:(ContactSelectPurpose)purpose
                 allowMulSelect:(BOOL)allowMulSelect
                       delegate:(nonnull id<ContactsSelectDelegate>)delegate
                        groupid:(nullable NSString *)groupid {
    if(self = [super init]) {
        
        self.purpose = purpose;
        self.allowMulSelect = allowMulSelect;
        self.delegate = delegate;
        self.groupid = groupid;
        if(self.purpose == ContactSelectPurposeInviteGroupMember) {
            NSArray *array = [[GroupDataSource sharedInstance] allGroupMembersForGroupid:groupid];
            self.groupMembers = [NSMutableArray arrayWithCapacity:array.count];
            for(GroupMemberData *member in array) {
                [self.groupMembers addObject:member.userid];
            }
        }
        
        if(self.purpose == ContactSelectPurposeOneKey) {
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        }
    }
    
    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    UserSelectHeader *header = [[UserSelectHeader alloc] init];
    header.delegate = self;
    [view addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(view);
    }];
    
    self.header = header;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(header.mas_bottom);
        make.bottom.equalTo(view);
    }];
    
    self.tableView = tableView;
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择联系人";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.selectedResult = [NSMutableArray array];
    
    if(self.purpose != ContactSelectPurposeMessageForward) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_CANCEL
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(touchCancel)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(touchFinish)];
    }
    
    if(self.purpose == ContactSelectPurposeMessageForwardForStaff) {
        [self.selectedResult addObjectsFromArray:self.selectedContacts];
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self refreshFinishBtnStatus];
    
    self.header.selectPurpose = self.purpose;
    
    [self.tableView registerClass:[ContactSelectCell class]
           forCellReuseIdentifier:[ContactSelectCell reuseIdentifier]];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.sectionIndexColor = [UIColor blackColor];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.dataSource = [ContactsDataSource sharedInstance];
    
    self.fetchedResultsController = [self.dataSource addDelegate:self
                                                          entity:[ContactEntity entityName]
                                                       predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID] sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                                                                                                                                                                                               [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                                              sectionNameKeyPath:@"sectionKey"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(self.purpose == ContactSelectPurposeMessageForwardForStaff) {
        if(self.delegate) {
            [self.delegate selectWithContacts:self.selectedResult
                                      purpose:self.purpose
                                    mulSelect:self.allowMulSelect];
        }
    }
}

- (NSArray *)refreshSectionKeys {
    NSArray *contacts = [[ContactsDataSource sharedInstance] allContactsForController:self.fetchedResultsController];
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

- (void)refreshDataSourceWithKeywords:(NSString *)keywords {
    keywords = [keywords uppercaseString];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(displayName CONTAINS[cd] %@ || nickname CONTAINS[cd] %@ || shengmu CONTAINS[cd] %@) && loginid == %@", keywords, keywords, keywords, YUCLOUD_ACCOUNT_USERID];
    
    if(self.purpose == ContactSelectPurposeInviteGroupMember ||
       [[AccountManager manager].accountInfo.role isSpecialUser]) {
        // 能邀请好友进群组肯定是管理员，其他情况只有特殊会员才能通过手机号查询
        predicate = [NSPredicate predicateWithFormat:@"(displayName CONTAINS[cd] %@ || nickname CONTAINS[cd] %@ || shengmu CONTAINS[cd] %@ || phone CONTAINS[cd] %@) && loginid == %@", keywords, keywords, keywords, keywords, YUCLOUD_ACCOUNT_USERID];
    }
    
    if(keywords.length) {
        self.fetchedResultsController = [self.dataSource addDelegate:self
                                                              entity:[ContactEntity entityName]
                                                           predicate:predicate
                                                     sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                                                       [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                                                  sectionNameKeyPath:@"sectionKey"];
    }
    else {
        self.fetchedResultsController = [self.dataSource addDelegate:self
                                                              entity:[ContactEntity entityName]
                                                           predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                                                     sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES],
                                                                       [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                                                  sectionNameKeyPath:@"sectionKey"];
    }
    
    [self.tableView reloadData];
}

- (void)refreshFinishBtnStatus {
    self.navigationItem.rightBarButtonItem.enabled = self.selectedResult.count;
    if(self.selectedResult.count) {
        self.title = [NSString stringWithFormat:@"已选联系人(%lu)", (unsigned long)self.selectedResult.count];
    } else {
        self.title = @"选择联系人";
    }
}

- (void)touchFinish {
    if(self.purpose == ContactSelectPurposeCreateGroup) {
        GroupInfoEditViewController *vc = [[GroupInfoEditViewController alloc] init];
        vc.contactsArray = self.selectedResult;
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    if(self.purpose == ContactSelectPurposeOneKey) {
        GroupOnekeyEditViewController *edit = [[GroupOnekeyEditViewController alloc] initWithOnekeyEditType:OnekeyEditTypeContact
                                                                                                       data:self.selectedResult];
        [self.navigationController pushViewController:edit animated:YES];
        
        return;
    }
    
    if(self.delegate) {
        [self.delegate selectWithContacts:self.selectedResult
                                  purpose:self.purpose
                                mulSelect:self.allowMulSelect];
        if(self.purpose == ContactSelectPurposeMessageForwardForStaff) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)touchCancel {
    if(self.purpose == ContactSelectPurposeMessageForwardForStaff) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (SelectCellStatus)statusForUserid:(NSString *)userid {
    switch (self.purpose) {
        case ContactSelectPurposeInviteGroupMember: {
            if([self.groupMembers containsObject:userid]) {
                return SelectCellStatusNotEnable;
            } else if([self.selectedResult containsObject:userid]) {
                return SelectCellStatusBeSelected;
            } else {
                return SelectCellStatusNotSelected;
            }
        }
        case ContactSelectPurposeStartChat:
        case ContactSelectPurposeOneKey:
        case ContactSelectPurposeMessageForwardForStaff:
        case ContactSelectPurposeCreateGroup: {
            if([self.selectedResult containsObject:userid]) {
                return SelectCellStatusBeSelected;
            } else {
                return SelectCellStatusNotSelected;
            }
        }
        case ContactSelectPurposeMessageForward: {
            return SelectCellStatusHidden;
        }
        default:
            return SelectCellStatusNotSelected;
    }
}

#pragma mark - LYDataSourceDelegate

- (void)didChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSections:self.fetchedResultsController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfItems:self.fetchedResultsController inSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    ContactData *data = [self.dataSource contactAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                 controller:self.fetchedResultsController];
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
    ContactData *contact = [self.dataSource contactAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]
                                                    controller:self.fetchedResultsController];
    cell.data = contact;
    cell.status = [self statusForUserid:contact.uid];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactSelectCell *cell = (ContactSelectCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(self.purpose == ContactSelectPurposeMessageForward) {
        if(self.delegate) {
            [self.selectedResult addObject:cell.userid];
            
            [self.delegate selectWithContacts:self.selectedResult
                                      purpose:self.purpose
                                    mulSelect:self.allowMulSelect];
        }
    } else {
        switch (cell.status) {
            case SelectCellStatusNotEnable:
                return;
                
            case SelectCellStatusNotSelected:
                if(self.allowMulSelect) {
                    [self.selectedResult addObject:cell.userid];
                } else {
                    [self.selectedResult removeAllObjects];
                    [self.selectedResult addObject:cell.userid];
                }
                break;
            case SelectCellStatusBeSelected:
                [self.selectedResult removeObject:cell.userid];
                break;
                
            default:
                break;
        }
        
        [self.tableView reloadData];
        
        [self refreshFinishBtnStatus];
    }
}

#pragma mark - UserSelectHeaderDelegate

- (void)searchWithText:(NSString *)searchText {
    [self refreshDataSourceWithKeywords:searchText];
}

- (void)userChooseSelectAll:(BOOL)selectAll {
    if(selectAll) {
        NSArray *contacts = [[ContactsDataSource sharedInstance] allContacts];
        
        [self.selectedResult removeAllObjects];
        
        for(ContactData *data in contacts) {
            if(self.purpose == ContactSelectPurposeInviteGroupMember) {
                if(![self.groupMembers containsObject:data.uid]) {
                    [self.selectedResult addObject:data.uid];
                }
            } else {
                [self.selectedResult addObject:data.uid];
            }
        }
    } else {
        [self.selectedResult removeAllObjects];
    }
    
    [self.tableView reloadData];
    
    [self refreshFinishBtnStatus];
}

@end
