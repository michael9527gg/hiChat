//
//  MessageForwardSearchResultViewController.m
//  hiChat
//
//  Created by Polly polly on 08/03/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "MessageForwardSearchResultViewController.h"
#import "MessageForwardCell.h"

@interface MessageForwardSearchResultViewController() < LYDataSourceDelegate >

@property (nonatomic, weak)   ContactsDataSource      *contactsDataSource;
@property (nonatomic, strong) NSFetchedResultsController                *contactsResultsController;

@property (nonatomic, weak)   GroupDataSource         *groupDataSource;
@property (nonatomic, strong) NSFetchedResultsController                *groupsResultsController;

@end

@implementation MessageForwardSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.tableView registerClass:[MessageForwardCell class]
           forCellReuseIdentifier:[MessageForwardCell reuseIdentifier]];
    
    self.contactsDataSource = [ContactsDataSource sharedInstance];
    
    self.groupDataSource = [GroupDataSource sharedInstance];
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
    
    self.contactsResultsController = [self.contactsDataSource addDelegate:self
                                                                   entity:[ContactEntity entityName]
                                                                predicate:predicate
                                                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                                                       sectionNameKeyPath:nil];
}

- (void)searchGroupWithText:(NSString *)keywords {
    self.groupsResultsController = [self.groupDataSource addDelegate:self
                                                              entity:[GroupEntity entityName]
                                                           predicate:[NSPredicate predicateWithFormat:@"loginid == %@ && name CONTAINS[cd] %@", YUCLOUD_ACCOUNT_USERID, keywords]
                                                     sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                                                  sectionNameKeyPath:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [self.contactsDataSource numberOfItems:self.contactsResultsController inSection:section];
    }
    
    return [self.groupDataSource numberOfItems:self.groupsResultsController inSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[MessageForwardCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(MessageForwardCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        ContactData *contact = [self.contactsDataSource contactAtIndexPath:indexPath controller:self.contactsResultsController];
        [cell setName:contact.name
             portrail:contact.portraitUri
                 type:@"我的好友"];
        return;
    }
    
    GroupData *group = [self.groupDataSource groupAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                 inSection:0]
                                                   controller:self.groupsResultsController];
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
                                                controller:self.contactsResultsController];
    } else {
        data = [self.groupDataSource groupAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                         inSection:0]
                                           controller:self.groupsResultsController];
    }
    
    if(self.delegate) {
        [self.delegate searchResultChooseTarget:data];
    }
}

#pragma mark - LYDataSourceDelegate

- (void)didChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
