//
//  NotificationCenterViewController.m
//  hiChat
//
//  Created by Polly polly on 27/02/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "NotificationCenterViewController.h"
#import "NotificationDetailViewController.h"
#import "NotificationDataSource.h"
#import "NotificationCell.h"

@interface NotificationCenterViewController () < UITableViewDataSource, UITableViewDelegate, LYDataSourceDelegate >

@property (nonatomic, strong) UITableView                 *tableView;
@property (nonatomic, weak)   NotificationDataSource      *dataSource;
@property (nonatomic, strong)   NSFetchedResultsController                    *fetchedResultsController;

@end

@implementation NotificationCenterViewController

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorFromString:@"0xf0f0f6"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[NotificationCell class]
           forCellReuseIdentifier:[NotificationCell reuseIdentifier]];
    
    [view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"系统通知";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_contacts_more"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(touchMore)];
    
    self.dataSource = [NotificationDataSource sharedInstance];
    self.fetchedResultsController = [self.dataSource addDelegate:self
                                                          entity:[NotificationEntity entityName]
                                                       predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]
                                              sectionNameKeyPath:nil];
}

- (void)touchMore {
    UIAlertControllerStyle alertControllerStyle = UIAlertControllerStyleActionSheet;
    if([[UniManager manager] currentDeviceType] == UIUserInterfaceIdiomPad) {
        alertControllerStyle = UIAlertControllerStyleAlert;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"清空系统通知"
                                                            preferredStyle:alertControllerStyle];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"清空"
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [[NotificationDataSource sharedInstance] clearAllNotifications];
                                               }];
    [alert addAction:ok];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = [self.dataSource numberOfItems:self.fetchedResultsController
                                         inSection:section];
    
    if(!num) {
        tableView.backgroundView = [self emptyViewWithTitle:@"暂无系统通知"];
    } else {
        tableView.backgroundView = nil;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[NotificationCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(NotificationCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.data = [self.dataSource notificationAtIndexPath:indexPath
                                              controller:self.fetchedResultsController];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NotificationDetailViewController *detailVC = [[NotificationDetailViewController alloc] init];
    detailVC.data = [self.dataSource notificationAtIndexPath:indexPath
                                                  controller:self.fetchedResultsController];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - LYDataSourceDelegate

- (void)didChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
