//
//  MessageHistoryViewController.m
//  hiChat
//
//  Created by Polly polly on 28/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "MessageHistoryViewController.h"
#import "HistorySearchCell.h"

@interface MessageHistoryViewController () < UISearchBarDelegate >

@property (nonatomic, strong) NSArray<RCMessage *> *dataSource;

@end

@implementation MessageHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天记录";
    
    if(!self.keywords) {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 56)];
        searchBar.placeholder = @"搜索";
        searchBar.delegate = self;
        self.tableView.tableHeaderView = searchBar;
    }
    
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:[HistorySearchCell class]
           forCellReuseIdentifier:[HistorySearchCell reuseIdentifier]];

    [self refreshDataSourceWithKeywords:self.keywords];
}

- (void)refreshDataSourceWithKeywords:(NSString *)keywords {
    self.dataSource = [[RCIMClient sharedRCIMClient] searchMessages:self.conversationType
                                                           targetId:self.targetid
                                                            keyword:keywords
                                                              count:20
                                                          startTime:0];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HistorySearchCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    HistorySearchCell *hCell = (HistorySearchCell *)cell;
    hCell.data = self.dataSource[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HistorySearchCell *cell = (HistorySearchCell *)[tableView cellForRowAtIndexPath:indexPath];
    RCMessage *message = self.dataSource[indexPath.row];
    
    ConversationViewController *conversationVC = [[ConversationViewController alloc] init];
    conversationVC.conversationType = message.conversationType;
    conversationVC.targetId = message.targetId;
    conversationVC.title = cell.nameLabel.text;
    conversationVC.locatedMessageSentTime = message.sentTime;
    [[UniManager manager].topNavigationController pushViewController:conversationVC animated:YES];
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
