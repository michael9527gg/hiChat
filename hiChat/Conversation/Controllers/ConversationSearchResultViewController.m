//
//  ConversationSearchResultViewController.m
//  hiChat
//
//  Created by Polly polly on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "ConversationSearchResultViewController.h"
#import "HistorySearchCell.h"
#import "ContactCell.h"
#import "GroupListCell.h"
#import "ContactDetailViewController.h"
#import "MessageHistoryViewController.h"

typedef enum : NSUInteger {
    ResultShowTypeHistory,
    ResultShowTypeContact,
    ResultShowTypeGroup
} ResultShowType;

@interface ConversationSearchResultViewController () < UITableViewDataSource, UITableViewDelegate, VIDataSourceDelegate >

@property (nonatomic, strong) UITableView        *tableView;
@property (nonatomic, strong) NSMutableArray     *topBtnArray;
@property (nonatomic, assign) ResultShowType     currentShowType;

@property (nonatomic, strong) NSArray<RCSearchConversationResult *>            *historyDataSource;

@property (nonatomic, weak)   ContactsDataSource      *contactsDataSource;
@property (nonatomic, copy)   NSString                *contactsDataKey;

@property (nonatomic, weak)   GroupDataSource         *groupDataSource;
@property (nonatomic, copy)   NSString                *groupDataKey;

@end

@implementation ConversationSearchResultViewController

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    
    UIColor *tintColor = [UIColor colorFromHex:0x0099ff];
    
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor colorFromString:@"0xf0f0f6"];
    self.topBtnArray = [NSMutableArray arrayWithCapacity:3];
    
    UIButton *historyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    historyBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [historyBtn setTitle:@"聊天记录"
                     forState:UIControlStateNormal];
    [historyBtn setTitleColor:[UIColor lightGrayColor]
                          forState:UIControlStateNormal];
    [historyBtn setTitleColor:tintColor
                          forState:UIControlStateSelected];
    [historyBtn addTarget:self
                        action:@selector(btnAction:)
              forControlEvents:UIControlEventTouchUpInside];
    historyBtn.selected = YES;
    self.currentShowType = ResultShowTypeHistory;
    [topView addSubview:historyBtn];
    [self.topBtnArray addObject:historyBtn];
            
    UIButton *contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    contactBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [contactBtn setTitle:@"联系人"
                     forState:UIControlStateNormal];
    [contactBtn setTitleColor:[UIColor lightGrayColor]
                          forState:UIControlStateNormal];
    [contactBtn setTitleColor:tintColor
                          forState:UIControlStateSelected];
    [contactBtn addTarget:self
                        action:@selector(btnAction:)
              forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:contactBtn];
    [self.topBtnArray addObject:contactBtn];
    
    UIButton *groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    groupBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [groupBtn setTitle:@"群组"
                   forState:UIControlStateNormal];
    [groupBtn setTitleColor:[UIColor lightGrayColor]
                        forState:UIControlStateNormal];
    [groupBtn setTitleColor:tintColor
                        forState:UIControlStateSelected];
    [groupBtn addTarget:self
                      action:@selector(btnAction:)
            forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:groupBtn];
    [self.topBtnArray addObject:groupBtn];
    
    [historyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(topView);
        make.right.equalTo(contactBtn.mas_left);
        make.width.equalTo(contactBtn.mas_width);
    }];
    
    [contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(topView);
        make.left.equalTo(historyBtn.mas_right);
        make.right.equalTo(groupBtn.mas_left);
        make.width.equalTo(groupBtn.mas_width);
    }];
    
    [groupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(topView);
        make.left.equalTo(contactBtn.mas_right);
        make.width.equalTo(contactBtn.mas_width);
    }];
    
    [view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
        make.height.equalTo(@44);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    [self.tableView registerClass:[HistorySearchCell class]
           forCellReuseIdentifier:[HistorySearchCell reuseIdentifier]];
    [self.tableView registerClass:[ContactCell class]
           forCellReuseIdentifier:[ContactCell reuseIdentifier]];
    [self.tableView registerClass:[GroupListCell class]
           forCellReuseIdentifier:[GroupListCell reuseIdentifier]];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.tableFooterView = [UIView new];
    [view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom);
        make.left.right.bottom.equalTo(view);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.contactsDataSource = [ContactsDataSource sharedClient];
    self.contactsDataKey= NSStringFromClass(self.class);
    
    self.groupDataSource = [GroupDataSource sharedClient];
    self.groupDataKey = NSStringFromClass(self.class);
}

- (void)setSearchText:(NSString *)searchText {
    _searchText = searchText;
    
    [self refreshMessageHistoryWithText:searchText];
    
    [self searchContactWithText:searchText];
    
    [self searchGroupWithText:searchText];
    
    [self.tableView reloadData];
}

- (void)refreshMessageHistoryWithText:(NSString *)keywords {
    self.historyDataSource = [[RCIMClient sharedRCIMClient] searchConversations:@[@(ConversationType_PRIVATE),
                                                                                  @(ConversationType_GROUP)]
                                                                    messageType:@[[RCTextMessage getObjectName]]
                                                                        keyword:keywords];
}

- (void)searchContactWithText:(NSString *)keywords {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(displayName CONTAINS[cd] %@ || nickname CONTAINS[cd] %@ || shengmu CONTAINS[cd] %@) && loginid == %@", keywords, keywords, keywords, YUCLOUD_ACCOUNT_USERID];
    if([[AccountManager manager].accountInfo.role isSpecialUser]) {
        predicate = [NSPredicate predicateWithFormat:@"(displayName CONTAINS[cd] %@ || nickname CONTAINS[cd] %@ || shengmu CONTAINS[cd] %@ || phone CONTAINS[cd] %@) && loginid == %@", keywords, keywords, keywords, keywords, YUCLOUD_ACCOUNT_USERID];
    }
    
    [self.contactsDataSource registerDelegate:self
                                       entity:[ContactEntity entityName]
                                    predicate:predicate
                              sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                           sectionNameKeyPath:nil
                                          key:self.contactsDataKey];
}

- (void)searchGroupWithText:(NSString *)keywords {
    [self.groupDataSource registerDelegate:self
                                    entity:[GroupEntity entityName]
                                 predicate:[NSPredicate predicateWithFormat:@"loginid == %@ && name CONTAINS[cd] %@", YUCLOUD_ACCOUNT_USERID, keywords]
                           sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                        sectionNameKeyPath:nil
                                       key:self.groupDataKey];
}

- (void)btnAction:(UIButton *)button {
    for(UIButton *btn in self.topBtnArray) {
        btn.selected = btn == button;
    }
    
    self.currentShowType = [self.topBtnArray indexOfObject:button];
    
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
        make.centerX.equalTo(emptyView);
        make.centerY.equalTo(emptyView).offset(-64);
    }];
    
    return emptyView;
}

- (NSString *)emptyStringForZero {
    switch (self.currentShowType) {
        case ResultShowTypeHistory: {
            return @"找不到相关记录";
        }
        case ResultShowTypeContact: {
            return @"找不到相关联系人";
        }
        case ResultShowTypeGroup: {
            return @"找不到相关群组";
        }
        default:
            return nil;
    }
}

- (void)dealloc {
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger num = 0;
    switch (self.currentShowType) {
        case ResultShowTypeHistory: {
            num = [self.historyDataSource count];
        }
            break;
        case ResultShowTypeContact: {
            num = [self.contactsDataSource numberOfItemsForKey:self.contactsDataKey inSection:section];
        }
            break;
        case ResultShowTypeGroup: {
            num = [self.groupDataSource numberOfItemsForKey:self.groupDataKey inSection:section];
        }
            break;
        default:
            break;
    }
    
    if(!num) {
        NSString *emptyStr = [self emptyStringForZero];
        tableView.backgroundView = [self emptyViewWithTitle:emptyStr];
    } else {
        tableView.backgroundView = nil;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (self.currentShowType) {
        case ResultShowTypeHistory: {
            return [tableView dequeueReusableCellWithIdentifier:[HistorySearchCell reuseIdentifier]
                                                   forIndexPath:indexPath];
        }
        case ResultShowTypeContact: {
            return [tableView dequeueReusableCellWithIdentifier:[ContactCell reuseIdentifier]
                                                   forIndexPath:indexPath];
        }
        case ResultShowTypeGroup: {
            return [tableView dequeueReusableCellWithIdentifier:[GroupListCell reuseIdentifier]
                                                   forIndexPath:indexPath];
        }
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.currentShowType) {
        case ResultShowTypeHistory: {
            HistorySearchCell *hCell = (HistorySearchCell *)cell;
            hCell.data = self.historyDataSource[indexPath.row];
        }
            break;
        case ResultShowTypeContact: {
            ContactCell *cCell = (ContactCell *)cell;
            ContactData *contact = [self.contactsDataSource contactAtIndexPath:indexPath
                                                                        forKey:self.contactsDataKey];
            
            cCell.portraitUri = [contact.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE];
            cCell.string = contact.name;
            cCell.badgeNum = 0;
        }
            break;
        case ResultShowTypeGroup: {
            GroupListCell *gCell = (GroupListCell *)cell;
            GroupData *group = [self.groupDataSource groupAtIndexPath:indexPath
                                                               forKey:self.groupDataKey];
            gCell.data = group;
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (self.currentShowType) {
        case ResultShowTypeHistory: {
            RCSearchConversationResult *result = self.historyDataSource[indexPath.row];
            MessageHistoryViewController *vc = [[MessageHistoryViewController alloc] init];
            vc.conversationType = result.conversation.conversationType;
            vc.targetid = result.conversation.targetId;
            vc.keywords = self.searchText;
            [[UniManager manager].topNavigationController pushViewController:vc animated:YES];
        }
            break;
        case ResultShowTypeContact: {
            ContactData *contact = [self.contactsDataSource contactAtIndexPath:indexPath
                                                                        forKey:self.contactsDataKey];
            ContactDetailViewController *vc = [[ContactDetailViewController alloc] initWithUserid:contact.uid
                                                                                     user:nil
                                                                                  groupid:nil];
            [[UniManager manager].topNavigationController pushViewController:vc animated:YES];
        }
            break;
        case ResultShowTypeGroup: {
            GroupData *group = [self.groupDataSource groupAtIndexPath:indexPath
                                                               forKey:self.groupDataKey];
            [[RCManager manager] startConversationWithType:ConversationType_GROUP
                                                  targetId:group.uid
                                                     title:group.name];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

@end
