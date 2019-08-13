//
//  MessageForwardViewController.m
//  hiChat
//
//  Created by Polly polly on 16/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "StaffMessageForwardViewController.h"
#import "MessageSendManager.h"
#import "ContactsSelectViewController.h"
#import "GroupSelectViewController.h"
#import "MessageForwardCell.h"
#import "ContactSelectCell.h"

static NSString *cellIdentifier = @"StaffMessageForwardCell";

@interface StaffMessageForwardViewController () < UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, ContactsSelectDelegate, GroupSelectDelegate, MessageSendManagerDelegate >

@property (nonatomic, strong) UITableView                  *tableView;
@property (nonatomic, strong) NSArray                      *dataSource;
@property (nonatomic, strong) UISearchController           *searchController;
@property (nonatomic, strong) NSMutableArray               *selectedItems;

@end

@implementation StaffMessageForwardViewController

- (void)loadView {
    UIView *view = [UIView new];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    [self.tableView registerClass:[ContactSelectCell class]
           forCellReuseIdentifier:[ContactSelectCell reuseIdentifier]];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择转发对象";
    
    [MessageSendManager manager].delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(touchCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(touchSend)];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.tableFooterView = [UIView new];
    
    NSArray *array = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE),
                                                                          @(ConversationType_GROUP)]];
    // 过滤下融云本地的会话列表，可能会有失效的会话，maybe群组解散，maybe好友被删除
    NSMutableArray *mulArr = [NSMutableArray arrayWithArray:array];
    for(RCConversation *conversation in array) {
        if(conversation.conversationType == ConversationType_PRIVATE) {
            ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:conversation.targetId];
            if(!contact) {
                [mulArr removeObject:conversation];
            }
        } else if (conversation.conversationType == ConversationType_GROUP) {
            GroupData *group = [[GroupDataSource sharedClient] groupWithGroupid:conversation.targetId];
            if(!group) {
                [mulArr removeObject:conversation];
            }
        }
    }
    
    self.dataSource = mulArr;
    
    [self.tableView reloadData];
}

- (void)touchSend {
    if(!self.selectedItems.count) {
        [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                            withResult:NO
                             labelText:@"请选择发送对象"
                             delayHide:YES
                            completion:nil];
        return;
    }
    NSString *t1 = [NSString stringWithFormat:@" %ld 位好友", [self selectedContacts].count];
    NSString *t2 = [NSString stringWithFormat:@" %ld 个群组", [self selectedGroups].count];
    NSString *title = @"发送给\n";
    if([self selectedContacts].count) {
        title = [title stringByAppendingString:t1];
    }
    if([self selectedGroups].count) {
        title = [title stringByAppendingString:t2];
    }
    NSString *contentStr = nil;
    if([self.message isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)self.message;
        contentStr = textMessage.content;
    } else if([self.message isKindOfClass:[RCImageMessage class]]) {
        contentStr = @"图片";
    }
    [YuAlertViewController showAlertWithTitle:title
                                      message:contentStr
                               viewController:self.navigationController
                                      okTitle:@"确定"
                                     okAction:^(UIAlertAction * _Nonnull action) {
                                         [[MessageSendManager manager] sendMessages:self.selectedItems];
                                     }
                                  cancelTitle:YUCLOUD_STRING_CANCEL
                                 cancelAction:nil
                                   completion:nil];
}

- (void)touchCancel {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (NSMutableArray *)selectedItems {
    if(!_selectedItems) {
        _selectedItems = [NSMutableArray array];
    }
    
    return _selectedItems;
}

- (void)addMessageItem:(MesssageItem *)item {
    [self addMessageItems:@[item]];
}

- (void)addMessageItems:(NSArray *)items {
    for(MesssageItem *item1 in items) {
        if(![self checkMessageItemExist:item1]) {
            [self.selectedItems addObject:item1];
        }
    }
}

- (MesssageItem *)checkMessageItemExist:(MesssageItem *)item {
    for(MesssageItem *itemT in self.selectedItems) {
        if((item.conversationType == itemT.conversationType) &&
           [item.targetid isEqualToString:itemT.targetid]) {
            return itemT;
        }
    }
    
    return nil;
}

- (SelectCellStatus)selectStatusForItem:(MesssageItem *)item {
    if([self checkMessageItemExist:item]) {
        return SelectCellStatusBeSelected;
    }
    
    return SelectCellStatusNotSelected;
}

- (NSArray *)selectedContacts {
    NSMutableArray *mulArr = [NSMutableArray array];
    for(MesssageItem *item in self.selectedItems) {
        if(item.conversationType == ConversationType_PRIVATE) {
            [mulArr addObject:item.targetid];
        }
    }
    
    return mulArr;
}

- (NSArray *)selectedGroups {
    NSMutableArray *mulArr = [NSMutableArray array];
    for(MesssageItem *item in self.selectedItems) {
        if(item.conversationType == ConversationType_GROUP) {
            [mulArr addObject:item.targetid];
        }
    }
    
    return mulArr;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 2;
    }
    
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier];
        }
        
        return cell;
    }
    
    return [tableView dequeueReusableCellWithIdentifier:[ContactSelectCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if(indexPath.row == 0) {
            cell.textLabel.text = @"选择好友";
            NSArray *contacts = [self selectedContacts];
            if(contacts.count) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"已选择 %ld 位好友", contacts.count];
            } else {
                cell.detailTextLabel.text = @"";
            }
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"选择群聊";
            NSArray *groups = [self selectedGroups];
            if(groups.count) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"已选择 %ld 个群组", groups.count];
            } else {
                cell.detailTextLabel.text = @"";
            }
        }
    } else if(indexPath.section == 1) {
        ContactSelectCell *cCell = (ContactSelectCell *)cell;
        RCConversation *conversation = self.dataSource[indexPath.row];
        
        if(conversation.conversationType == ConversationType_PRIVATE) {
            cCell.data = [[ContactsDataSource sharedClient] contactWithUserid:conversation.targetId];
        } else if (conversation.conversationType == ConversationType_GROUP) {
            cCell.data = [[GroupDataSource sharedClient] groupWithGroupid:conversation.targetId];
        }
        
        cCell.status = [self selectStatusForItem:[MesssageItem itemWithConversationType:conversation.conversationType
                                                                               targetid:conversation.targetId
                                                                                content:self.message]];
    } else {
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 1) {
        return @"最近";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            ContactsSelectViewController *contactVC = [[ContactsSelectViewController alloc] initWithPurpose:ContactSelectPurposeMessageForwardForStaff
                                                                                             allowMulSelect:YES
                                                                                                   delegate:self
                                                                                                    groupid:nil];
            contactVC.selectedContacts = [self selectedContacts];
            [self.navigationController pushViewController:contactVC animated:YES];
        } else if(indexPath.row == 1) {
            GroupSelectViewController *groupVC = [[GroupSelectViewController alloc] initWithPurpose:GroupSelectPurposeMessageForwardForStaff
                                                                                           delegate:self];
            groupVC.groups = [self selectedGroups];
            [self.navigationController pushViewController:groupVC animated:YES];
        }
    }
    else if(indexPath.section == 1) {
        RCConversation *conversation = self.dataSource[indexPath.row];
        
        MesssageItem *item = [MesssageItem itemWithConversationType:conversation.conversationType
                                                           targetid:conversation.targetId
                                                            content:self.message];
        MesssageItem *selectItem = [self checkMessageItemExist:item];
        if(selectItem) {
            [self.selectedItems removeObject:selectItem];
        } else {
            [self addMessageItem:item];
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - ContactsSelectDelegate

- (void)selectWithContacts:(NSArray *)contacts
                   purpose:(ContactSelectPurpose)purpose
                 mulSelect:(BOOL)mulSelect {
    // 先清空原来的好友
    NSMutableArray *mulArr = [NSMutableArray arrayWithArray:self.selectedItems];
    for(MesssageItem *item in mulArr) {
        if(item.conversationType == ConversationType_PRIVATE) {
            [self.selectedItems removeObject:item];
        }
    }
    
    // 添加新的
    for(NSString *userid in contacts) {
        MesssageItem *item = [MesssageItem itemWithConversationType:ConversationType_PRIVATE
                                                           targetid:userid
                                                            content:self.message];
        [self addMessageItem:item];
    }
    
    [self.tableView reloadData];
}

#pragma mark - GroupSelectDelegate

- (void)selectWithGroups:(NSArray *)groups
                 purpose:(GroupSelectPurpose)purpose {
    // 先清空原来的群组
    NSMutableArray *mulArr = [NSMutableArray arrayWithArray:self.selectedItems];
    for(MesssageItem *item in mulArr) {
        if(item.conversationType == ConversationType_GROUP) {
            [self.selectedItems removeObject:item];
        }
    }
    
    // 添加新的
    for(NSString *groupid in groups) {
        MesssageItem *item = [MesssageItem itemWithConversationType:ConversationType_GROUP
                                                           targetid:groupid
                                                            content:self.message];
        [self addMessageItem:item];
    }
    
    [self.tableView reloadData];
}

#pragma mark - MessageSendManagerDelegate

- (void)messagesSendSuccess:(BOOL)success {
    [self touchCancel];
}

@end
