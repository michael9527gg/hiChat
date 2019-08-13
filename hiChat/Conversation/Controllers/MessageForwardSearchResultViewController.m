//
//  MessageForwardSearchResultViewController.m
//  hiChat
//
//  Created by Polly polly on 08/03/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "MessageForwardSearchResultViewController.h"
#import "MessageForwardCell.h"

@interface MessageForwardSearchResultViewController() < VIDataSourceDelegate >

@property (nonatomic, weak)   ContactsDataSource      *contactsDataSource;
@property (nonatomic, copy)   NSString                *contactsDataKey;

@property (nonatomic, weak)   GroupDataSource         *groupDataSource;
@property (nonatomic, copy)   NSString                *groupDataKey;

@end

@implementation MessageForwardSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.tableView registerClass:[MessageForwardCell class]
           forCellReuseIdentifier:[MessageForwardCell reuseIdentifier]];
    
    self.contactsDataSource = [ContactsDataSource sharedClient];
    self.contactsDataKey= NSStringFromClass(self.class);
    
    self.groupDataSource = [GroupDataSource sharedClient];
    self.groupDataKey = NSStringFromClass(self.class);
}

- (void)setSearchText:(NSString *)searchText {
    _searchText = searchText.copy;
    
    [self searchContactWithText:searchText];
    
    [self searchGroupWithText:searchText];
    
    [self.tableView reloadData];
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

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [self.contactsDataSource numberOfItemsForKey:self.contactsDataKey inSection:section];
    }
    
    return [self.groupDataSource numberOfItemsForKey:self.groupDataKey inSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[MessageForwardCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(MessageForwardCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        ContactData *contact = [self.contactsDataSource contactAtIndexPath:indexPath
                                                                    forKey:self.contactsDataKey];
        [cell setName:contact.name
             portrail:contact.portraitUri
                 type:@"我的好友"];
        return;
    }
    
    GroupData *group = [self.groupDataSource groupAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                 inSection:0]
                                                       forKey:self.groupDataKey];
    [cell setName:group.name
         portrail:group.portrait
             type:@"群聊"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id data = nil;
    if(indexPath.section == 0) {
        data = [self.contactsDataSource contactAtIndexPath:indexPath
                                                    forKey:self.contactsDataKey];
    } else {
        data = [self.groupDataSource groupAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                         inSection:0]
                                               forKey:self.groupDataKey];
    }
    
    if(self.delegate) {
        [self.delegate searchResultChooseTarget:data];
    }
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self.tableView reloadData];
}

@end
