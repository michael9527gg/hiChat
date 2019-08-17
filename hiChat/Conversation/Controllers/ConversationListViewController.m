//
//  ConversationListViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "ConversationListViewController.h"
#import "ConversationViewController.h"
#import "PopoverView.h"
#import "ContactsDataSource.h"
#import "FriendSearchViewController.h"
#import "ConversationSearchResultViewController.h"
#import "GroupSelectViewController.h"
#import "GroupCategoriesViewController.h"
#import "STPopup.h"
#import "OneKeyAlertViewController.h"
#import "CheckinData.h"
#import "STPopupController.h"

typedef enum : NSUInteger {
    MenuTypeNewFriend,
    MenuTypeNewGroup,
    MenuTypeOneKey,
    MenuTypeCount
} MenuType;

@interface ConversationListViewController () < PopoverDatasource, PopoverDelegate, UISearchResultsUpdating, ConversationResultDelegate, LYDataSourceDelegate >

@property (nonatomic, strong) STPopupController                         *alertVC;
@property (nonatomic, strong) UISearchController                        *searchController;
@property (nonatomic, strong) ConversationSearchResultViewController    *resultsController;
@property (nonatomic, strong) ConversationSettingDataSource             *dataSource;
@property (nonatomic, strong) NSFetchedResultsController                *conversationSettingResultsController;

@property (nonatomic, copy)   NSArray                       *menuData;
@property (nonatomic, strong) UIView                        *checkinView;
@property (nonatomic, strong) CheckinData                   *checkinData;

@end

@implementation ConversationListViewController

- (instancetype)init {
    if(self = [super init]) {
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                            @(ConversationType_GROUP)]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.isShowNetworkIndicatorView = YES;
    self.showConnectingStatusOnNavigatorBar = YES;
    
    self.resultsController = [[ConversationSearchResultViewController alloc] init];
    self.resultsController.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"搜索好友、群组、聊天记录";
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;

    self.conversationListTableView.tableFooterView = [UIView new];
    
    self.conversationListTableView.tableHeaderView = self.searchController.searchBar;
    
    if (@available(iOS 11.0, *)) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *menuImage = [[UIImage imageNamed:@"ic_navi_menu"] imageMaskedWithColor:[UIColor whiteColor]];
        [btn setImage:menuImage forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn addTarget:self
                action:@selector(touchMenuButton:)
      forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self
                                                                                               action:@selector(touchMenuItem:)];
    }
    
    [self registerDataBase];
    
    [self checkCheckin];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AccountInfo *info = [AccountManager manager].accountInfo;
    if ([info.role isSpecialUser]) {
        self.menuData = @[@(MenuTypeNewFriend), @(MenuTypeNewGroup), @(MenuTypeOneKey)];
    }
    else if (info.isStaff) {
        self.menuData = @[@(MenuTypeNewFriend), @(MenuTypeOneKey)];
    }
    else {
        self.menuData = @[@(MenuTypeNewFriend)];
    }
    
    [self updateBadgeValue];
}

- (void)checkCheckin {
    [[AccountManager manager] requestCheckinWithAction:YuCloudDataList
                                                taskId:nil
                                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                if(success) {
                                                    NSDictionary *result = [info valueForKey:@"result"];
                                                    self.checkinData = [CheckinData checkinWithDic:result];
                                                    NSDate *lastCheckinDate = [NSUserDefaults lastCheckinDateForUser:YUCLOUD_ACCOUNT_USERID];
                                                    if(!self.checkinData.checkinToday &&
                                                       (!lastCheckinDate || ![lastCheckinDate sameDayTo:[NSDate date]])) {
                                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                            [self showCheckinWithImageUrl:self.checkinData.imageUrl];
                                                        });
                                                    }
                                                }
                                            }];
}

- (void)showCheckinWithImageUrl:(NSString *)imageUrl {
    UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    [APP_DELEGATE_WINDOW addSubview:bgView];
    
    UIImageView *centerView = [[UIImageView alloc] init];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(touchCheckin)];
    [centerView addGestureRecognizer:tap];
    [bgView addSubview:centerView];
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bgView);
        make.centerY.equalTo(bgView);
        make.height.equalTo(bgView).multipliedBy(.5);
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"ic_checkin_close"]
                        forState:UIControlStateNormal];
    [closeBtn addTarget:self
                 action:@selector(touchClose)
       forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bgView).offset(-32);
        make.bottom.equalTo(centerView.mas_top).offset(-32);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    centerView.userInteractionEnabled = NO;
    [centerView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                  placeholderImage:nil
                           options:SDWebImageRetryFailed | SDWebImageProgressiveLoad | SDWebImageHighPriority
                          progress:nil
                         completed:^(UIImage * _Nullable image,
                                     NSError * _Nullable error,
                                     SDImageCacheType cacheType,
                                     NSURL * _Nullable imageURL) {
                             centerView.userInteractionEnabled = YES;
                         }];
    
    self.checkinView = bgView;
}

- (void)touchCheckin {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW message:@"签到中..."];
    [[AccountManager manager] requestCheckinWithAction:YuCloudDataAdd
                                                taskId:self.checkinData.uid
                                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                [MBProgressHUD finishLoading:hud
                                                                      result:success
                                                                        text:[info msg]
                                                                  completion:^{
                                                                      if(success) {
                                                                          [self touchClose];
                                                                      }
                                                                  }];
                                            }];
}

- (void)touchClose {
    [self.checkinView removeFromSuperview];
    self.checkinView = nil;
    
    [NSUserDefaults saveLastCheckinDate:[NSDate date]
                                forUser:YUCLOUD_ACCOUNT_USERID];
}

- (void)registerDataBase {
    self.dataSource = [ConversationSettingDataSource sharedInstance];
    
    [self.dataSource addDelegate:self
                          entity:[ConversationSettingEntity entityName]
                       predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES]]
              sectionNameKeyPath:nil];
}

- (void)refreshHome {
    [[RCManager manager] refreshDataForConversationListCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        [self.conversationListTableView.mj_header endRefreshing];
    }];
}

- (void)updateBadgeValue {
    WEAK(self, sself);
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = [[RCIMClient sharedRCIMClient] getUnreadCount:sself.displayConversationTypeArray];
        [sself.tabBarItem setBadgeValue:@(count).stringValue];
        
        UIViewController *desController = self.tabBarController.viewControllers[0];
        UITabBarItem *desItem = desController.tabBarItem;
        if(count) {
            if(count > 99) {
                [desItem setBadgeValue:@"99+"];
            } else {
                [desItem setBadgeValue:@(count).stringValue];
            }
        } else {
            [desItem setBadgeValue:nil];
        }
    });
}

- (void)touchMenuButton:(UIButton *)btn {
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.showShade = YES;
    popoverView.dataSource = self;
    popoverView.delegate = self;
    [popoverView showToView:btn];
}

- (void)touchMenuItem:(UIBarButtonItem *)item {
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.showShade = YES;
    popoverView.dataSource = self;
    popoverView.delegate = self;
    
    UIView *view = [item valueForKey:@"view"];
    [popoverView showToView:view];
}

- (void)startConversation:(RCConversationModel *)model {
    [[RCManager manager] startConversationWithType:model.conversationType
                                          targetId:model.targetId
                                             title:model.conversationTitle];
}

- (void)showOneKeyAlert {
    // 群发暂不支持GIF，人数一多GIF太卡了
    OneKeyAlertViewController *alertVC = [[OneKeyAlertViewController alloc] init];
    self.alertVC = [[STPopupController alloc] initWithRootViewController:alertVC];
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.alertVC.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissAlert)];
    [self.alertVC.backgroundView addGestureRecognizer:tap];
    self.alertVC.style = STPopupStyleFormSheet;
    self.alertVC.navigationBar.backgroundColor = [UIColor colorFromHex:0x0099ff];
    self.alertVC.containerView.backgroundColor = [UIColor colorFromString:@"0xf0f0f6"];
    [self.alertVC presentInViewController:self];
}

- (void)dismissAlert {
    [self.alertVC dismiss];
}

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - 会话列表相关

- (NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource {
    return [[RCManager manager] sortConversationListDataSource:dataSource];
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    [self startConversation:model];
}

- (void)didTapCellPortrait:(RCConversationModel *)model {
    [self startConversation:model];
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    [super didReceiveMessageNotification:notification];
    NSDictionary *dic = notification.userInfo;
    NSNumber *left = [dic valueForKey:@"left"];
    // 单次会瞬间推送多条消息，最后一条消息时再刷新UI
    if(left.integerValue == 0) {
        [self updateBadgeValue];
    }
}

- (void)didDeleteConversationCell:(RCConversationModel *)model {
    [[RCManager manager] removeCacheIndexForConversation:model];
}

#pragma mark - PopoverDatasource, PopoverDelegate

- (NSInteger)numberOfRowsInMenu:(PopoverView *)view {
    return self.menuData.count;
}

- (PopoverAction *)actionForRow:(NSInteger)row {
    NSNumber *number = self.menuData[row];
    switch (number.integerValue) {
        case MenuTypeNewFriend:
            return [PopoverAction actionWithImage:[UIImage imageNamed:@"ic_add_friend"]
                                            title:@"添加好友"
                                          handler:nil];
        case MenuTypeNewGroup:
            return [PopoverAction actionWithImage:[UIImage imageNamed:@"ic_create_group"]
                                            title:@"创建群组"
                                          handler:nil];
        case MenuTypeOneKey:
            return [PopoverAction actionWithImage:[[UIImage imageNamed:@"ic_conversation_send"] imageMaskedWithColor:[UIColor colorFromHex:0x0099ff]]
                                            title:@"一键群发"
                                          handler:nil];
        default:
            return nil;
    }
}

- (void)popover:(PopoverView *)view didSelectRow:(NSInteger)row {
    NSNumber *number = self.menuData[row];
    switch (number.integerValue) {
        case MenuTypeNewGroup: {
            ContactsSelectViewController *contactVC = [[ContactsSelectViewController alloc] initWithPurpose:ContactSelectPurposeCreateGroup
                                                                                             allowMulSelect:YES
                                                                                                   delegate:self
                                                                                                    groupid:nil];
            [self presentViewController:[[MainNavigationController alloc] initWithRootViewController:contactVC]
                               animated:YES
                             completion:nil];
        }
            break;
        case MenuTypeNewFriend: {
            FriendSearchViewController *vc = [[FriendSearchViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MenuTypeOneKey: {
            [self showOneKeyAlert];
        }
            
        default:
            break;
    }
}

#pragma mark - ContactsSelectDelegate

- (void)selectWithContacts:(NSArray *)contacts
                   purpose:(ContactSelectPurpose)purpose
                 mulSelect:(BOOL)mulSelect {
    if(purpose == ContactSelectPurposeStartChat) {
        ContactData *contact = [[ContactsDataSource sharedInstance] contactWithUserid:contacts.firstObject];
        [[RCManager manager] startConversationWithType:ConversationType_PRIVATE
                                              targetId:contact.uid
                                                 title:contact.name];
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    self.resultsController.searchText = searchController.searchBar.text;
}

#pragma mark - LYDataSourceDelegate

- (void)didChangeContent:(NSFetchedResultsController *)controller {
    [self refreshConversationTableViewIfNeeded];
}

@end
