//
//  FriendSearchController.m
//  hiChat
//
//  Created by Polly polly on 18/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "ContactDetailViewController.h"
#import "ContactDetailCell.h"

@interface FriendSearchResultController : UITableViewController

@property (nonatomic, strong) NSMutableArray      *dataSource;
@property (nonatomic, copy)   NSString            *searchText;

@end

@implementation FriendSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:[ContactDetailCell class]
           forCellReuseIdentifier:[ContactDetailCell reuseIdentifier]];
    
    self.dataSource = [NSMutableArray array];
}

- (void)setSearchText:(NSString *)searchText {
    _searchText = searchText.copy;
    
    if(searchText.length) {
        MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
        
        [[ContactsManager manager] searchUserWithPhone:searchText
                                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                if(success) {
                                                    [hud hideAnimated:YES];
                                                    [self.dataSource removeAllObjects];
                                                    
                                                    UserData *user = [info valueForKey:@"data"];
                                                    [self.dataSource addObject:user];
                                                    [self.tableView reloadData];
                                                } else {
                                                    [MBProgressHUD finishLoading:hud
                                                                          result:success
                                                                            text:[info msg]
                                                                      completion:nil];
                                                }
                                            }];
    } else {
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[ContactDetailCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(ContactDetailCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    UserData *user = self.dataSource[indexPath.row];
    [cell setNickname:user.nickname
          displayName:user.displayName
             portrait:user.portrait
                phone:user.phone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserData *user = self.dataSource[indexPath.row];
    if([user.uid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
        [MBProgressHUD showMessage:@"您不能添加自己到通讯录"
                            onView:APP_DELEGATE_WINDOW
                            result:NO
                        completion:nil];
        
        return;
    }
    
    ContactDetailViewController *vc = [[ContactDetailViewController alloc] initWithUserid:user.uid
                                                                             user:user
                                                                          groupid:nil];
    [[[UniManager manager] topNavigationController] pushViewController:vc animated:YES];
}

@end

@interface FriendSearchViewController () < UISearchBarDelegate >

@property (nonatomic, strong) UITableView        *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) FriendSearchResultController *resultController;

@property (nonatomic, strong) UIView *bgView;

@end

@implementation FriendSearchViewController

- (UIView *)bgView {
    if(!_bgView) {
        UIView *bgView = [[UIView alloc] init];
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.text = @"点击上方开始搜索新朋友";
        label1.textColor = [UIColor lightGrayColor];
        label1.font = [UIFont systemFontOfSize:16];
        label1.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bgView);
            make.top.equalTo(bgView).offset(88+88);
        }];
        
//        UILabel *label2 = [[UILabel alloc] init];
//        label2.text = @"「添加好友」";
//        label2.textColor = [UIColor blackColor];
//        label2.font = [UIFont boldSystemFontOfSize:20];
//        label2.textAlignment = NSTextAlignmentCenter;
//        [bgView addSubview:label2];
//        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(bgView);
//            make.top.equalTo(label1.mas_bottom).offset(16);
//        }];
        
//        UILabel *label3 = [[UILabel alloc] init];
//        label3.numberOfLines = 0;
//        NSString *str = @"手机号\n账号\n昵称";
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.alignment = NSTextAlignmentCenter;
//        paragraphStyle.lineSpacing = 16;
//        [attributedString addAttribute:NSParagraphStyleAttributeName
//                                 value:paragraphStyle
//                                 range:NSMakeRange(0, [str length])];
//        label3.attributedText = attributedString;
//        [bgView addSubview:label3];
//        [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(bgView);
//            make.top.equalTo(label2.mas_bottom).offset(32);
//        }];
        
        _bgView = bgView;
    }
    
    return _bgView;
}

- (void)loadView {
    UIView *view = [UIView new];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    [view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加好友";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.resultController = [[FriendSearchResultController alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.tableView.backgroundView = self.bgView;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.resultController.searchText = searchBar.text;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.resultController.searchText = searchBar.text;
}

@end
