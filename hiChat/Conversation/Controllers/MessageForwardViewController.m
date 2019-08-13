//
//  MessageForwardViewController.m
//  hiChat
//
//  Created by Polly polly on 16/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "MessageForwardViewController.h"
#import "ContactCell.h"
#import "MessageSendManager.h"
#import "ContactsSelectViewController.h"
#import "GroupSelectViewController.h"
#import "MessageForwardSearchResultViewController.h"

@interface MessageForwardViewController () < UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, ContactsSelectDelegate, GroupSelectDelegate, TargetSearchResultControllerDelegate >

@property (nonatomic, strong) UITableView                  *tableView;
@property (nonatomic, strong) NSArray                      *dataSource;
@property (nonatomic, strong) UISearchController           *searchController;
@property (nonatomic, strong) MessageForwardSearchResultViewController *resultController;

@end

@implementation MessageForwardViewController

- (void)loadView {
    UIView *view = [UIView new];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    [self.tableView registerClass:[ContactCell class]
           forCellReuseIdentifier:[ContactCell reuseIdentifier]];
    
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
    
    self.title = @"发送给";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(touchCancel)];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.resultController = [[MessageForwardSearchResultViewController alloc] init];
    self.resultController.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
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

- (void)touchCancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
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
        return [tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]
                                               forIndexPath:indexPath];
    }
    
    return [tableView dequeueReusableCellWithIdentifier:[ContactCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if(indexPath.row == 0) {
            cell.textLabel.text = @"选择好友";
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"选择群聊";
        }
    } else {
        ContactCell *cCell = (ContactCell *)cell;
        RCConversation *conversation = self.dataSource[indexPath.row];
        
        if(conversation.conversationType == ConversationType_PRIVATE) {
            ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:conversation.targetId];
            cCell.portraitUri = contact.portraitUri;
            cCell.string = contact.name;
        } else if (conversation.conversationType == ConversationType_GROUP) {
            GroupData *group = [[GroupDataSource sharedClient] groupWithGroupid:conversation.targetId];
            cCell.portraitUri = group.portrait;
            cCell.string = group.name;
        }
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

- (void)alertSendMessageForTargetid:(NSString *)targetid
                   conversationType:(RCConversationType)conversationType
                         targetName:(NSString *)targetName
                            content:(RCMessageContent *)content {
    NSString *targetStr = [NSString stringWithFormat:@"发送给 %@", targetName];
    NSString *contentStr = nil;
    if([content isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)self.message;
        contentStr = textMessage.content;
    } else if([content isKindOfClass:[RCImageMessage class]]) {
        contentStr = @"图片";
    }
    [YuAlertViewController showAlertWithTitle:targetStr
                                      message:contentStr
                               viewController:self.navigationController
                                      okTitle:@"发送"
                                     okAction:^(UIAlertAction * _Nonnull action) {
                                         MesssageItem *item = [[MesssageItem alloc] init];
                                         item.conversationType = conversationType;
                                         item.targetid = targetid;
                                         item.content = content;
                                         if([[MessageSendManager manager] sendMessage:item]) {
                                             [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                                                                 withResult:YES
                                                                  labelText:@"已发送"
                                                                  delayHide:YES
                                                                 completion:^{
                                                                     [self touchCancel];
                                                                 }];
                                         }
                                     }
                                  cancelTitle:YUCLOUD_STRING_CANCEL
                                 cancelAction:nil
                                   completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            ContactsSelectViewController *contactVC = [[ContactsSelectViewController alloc] initWithPurpose:ContactSelectPurposeMessageForward
                                                                                             allowMulSelect:NO
                                                                                                   delegate:self
                                                                                                    groupid:nil];
            [self.navigationController pushViewController:contactVC animated:YES];
        } else if(indexPath.row == 1) {
            GroupSelectViewController *groupVC = [[GroupSelectViewController alloc] initWithPurpose:GroupSelectPurposeMessageForward
                                                                                           delegate:self];
            [self.navigationController pushViewController:groupVC animated:YES];
        }
    }
    else if(indexPath.section == 1) {
        RCConversation *conversation = self.dataSource[indexPath.row];
        NSString *targetName = nil;
        if(conversation.conversationType == ConversationType_PRIVATE) {
            ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:conversation.targetId];
            targetName = contact.name;
        } else if (conversation.conversationType == ConversationType_GROUP) {
            GroupData *group = [[GroupDataSource sharedClient] groupWithGroupid:conversation.targetId];
            targetName = group.name;
        }
        
        [self alertSendMessageForTargetid:conversation.targetId
                         conversationType:conversation.conversationType
                               targetName:targetName
                                  content:self.message];
    }
}

#pragma mark - ContactsSelectDelegate

- (void)selectWithContacts:(NSArray *)contacts
                   purpose:(ContactSelectPurpose)purpose
                 mulSelect:(BOOL)mulSelect {
    NSString *contactId = contacts.firstObject;
    ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:contactId];
    [self alertSendMessageForTargetid:contactId
                     conversationType:ConversationType_PRIVATE
                           targetName:contact.name
                              content:self.message];
}

#pragma mark - GroupSelectDelegate

- (void)selectWithGroups:(NSArray *)groups
                 purpose:(GroupSelectPurpose)purpose {
    NSString *groupId = groups.firstObject;
    GroupData *group = [[GroupDataSource sharedClient] groupWithGroupid:groupId];
    [self alertSendMessageForTargetid:groupId
                     conversationType:ConversationType_GROUP
                           targetName:group.name
                              content:self.message];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.resultController.searchText = searchBar.text;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.resultController.searchText = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultController.searchText = searchBar.text;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.resultController.searchText = searchBar.text;
}

#pragma mark - TargetSearchResultControllerDelegate

- (void)searchResultChooseTarget:(id)target {
    RCConversationType conversationType;
    NSString *name = nil;
    NSString *targetid = nil;
    
    if([target isKindOfClass:[ContactData class]]) {
        ContactData *contact = (ContactData *)target;
        conversationType = ConversationType_PRIVATE;
        targetid = contact.uid;
        name = contact.name;
    } else {
        GroupData *group = (GroupData *)target;
        conversationType = ConversationType_GROUP;
        targetid = group.uid;
        name = group.name;
    }
    
    [self alertSendMessageForTargetid:targetid
                     conversationType:conversationType
                           targetName:name
                              content:self.message];
}

@end
