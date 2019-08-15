//
//  MeViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "MeViewController.h"
#import "MeInfoCell.h"
#import "UniManager.h"
#import "MeInfoViewController.h"
#import "MeSettingsViewController.h"
#import "ReactiveWebViewController.h"
#import "MeAboutCell.h"
#import "NotificationCenterViewController.h"
#import "NotificationDataSource.h"
#import "CheckinData.h"

typedef enum : NSUInteger {
    MeSettings,
    MeAbout
} MeItemType;

@interface MeViewController () < VIDataSourceDelegate >

@property (nonatomic, strong) RCMessageBubbleTipView *bubbleView;
@property (nonatomic, assign) BOOL        versionNew;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;

@property (nonatomic, strong) UILabel     *checkinLabel;
@property (nonatomic, strong) UIButton    *checkinButton;
@property (nonatomic, strong) CheckinData *checkinData;

@property (nonatomic, weak)   NotificationDataSource      *dataSource;
@property (nonatomic, copy)   NSString                    *dataKey;

@end

@implementation MeViewController

- (instancetype)init {
    if(self = [super init]) {
        self.dataSource = [NotificationDataSource sharedClient];
        self.dataKey = NSStringFromClass(self.class);
        [self.dataSource registerDelegate:self
                                   entity:[NotificationEntity entityName]
                                predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]
                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]
                       sectionNameKeyPath:nil
                                      key:self.dataKey];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = @[@[@(MeSettings), @(MeAbout)]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 30);
    UIImage *menuImage = [[UIImage imageNamed:@"ic_me_message"]
                          imageMaskedWithColor:[UIColor whiteColor]];
    [btn setImage:menuImage forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(touchMessageButton)
  forControlEvents:UIControlEventTouchUpInside];
    self.bubbleView = [[RCMessageBubbleTipView alloc] initWithParentView:btn
                                                               alignment:RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_TOP_RIGHT];
    self.bubbleView.isShowNotificationNumber = YES;
    [self.bubbleView setBubbleTipNumber:0];
    self.bubbleView.bubbleTipPositionAdjustment = CGPointMake(-6, 0);
    self.bubbleView.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self reloadHeaderWithCheckin:NO];
    
    [self.tableView registerClass:[MeInfoCell class]
           forCellReuseIdentifier:[MeInfoCell reuseIdentifier]];
    
    [self.tableView registerClass:[MeAboutCell class]
           forCellReuseIdentifier:[MeAboutCell reuseIdentifier]];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    
    self.tableView.tableFooterView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [self refreshVersionInfo];
    
    [self updateBadgeValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    [self requestCheckin];
}   

- (void)reloadHeaderWithCheckin:(BOOL)checkin {
    NSInteger height = 220;
    if(checkin) {
        height = 250;
    }
    UIView *headerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, height)];
    
    UIImageView *headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_me_header"]];
    [headerBgView addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(headerBgView);
        if(checkin) {
            make.bottom.equalTo(headerBgView).offset(-44);
        } else {
            make.bottom.equalTo(headerBgView);
        }
    }];
    
    if(checkin) {
        UIImageView *checkinBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_signup_navi"]];
        checkinBgView.layer.cornerRadius = 8;
        checkinBgView.layer.masksToBounds = YES;
        checkinBgView.userInteractionEnabled = YES;
        [headerBgView addSubview:checkinBgView];
        [checkinBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(headerBgView);
            make.height.equalTo(@64);
            make.left.equalTo(headerBgView).offset(32);
            make.right.equalTo(headerBgView).offset(-32);
        }];
        
        self.checkinLabel = [[UILabel alloc] init];
        [checkinBgView addSubview:self.checkinLabel];
        [self.checkinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(checkinBgView).offset(16);
            make.centerY.equalTo(checkinBgView);
        }];
        
        self.checkinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.checkinButton.layer.cornerRadius = 20;
        self.checkinButton.layer.masksToBounds = YES;
        [checkinBgView addSubview:self.checkinButton];
        [self.checkinButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(checkinBgView).offset(-16);
            make.centerY.equalTo(checkinBgView);
            make.size.mas_equalTo(CGSizeMake(120, 40));
        }];
    }
    
    self.iconView = [[UIImageView alloc] init];
    self.iconView.layer.cornerRadius = 40;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.borderWidth = 1.5;
    self.iconView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(touchHeader)];
    [headerView addGestureRecognizer:tap];
    [headerView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(16);
        make.centerX.equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    [headerView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView);
        make.top.equalTo(self.iconView.mas_bottom).offset(8);
    }];
    
    self.tableView.tableHeaderView = headerBgView;
}

- (void)refreshCheckinWithCheckinToday:(BOOL)checkin
                                  days:(NSString *)days {
    if(checkin) {
        [self.checkinButton setBackgroundColor:[UIColor whiteColor]];
        [self.checkinButton setTitle:@"今日已签到" forState:UIControlStateNormal];
        [self.checkinButton setTitleColor:[UIColor colorFromHex:0x3c98fd] forState:UIControlStateNormal];
    } else {
        [self.checkinButton setBackgroundColor:[UIColor colorFromHex:0x3c98fd]];
        [self.checkinButton setTitle:@"立即签到" forState:UIControlStateNormal];
        [self.checkinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.checkinButton addTarget:self
                               action:@selector(touchCheckin)
                     forControlEvents:UIControlEventTouchUpInside];
    }
    NSString *str = [NSString stringWithFormat:@"已连续签到  %@  天", days];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, str.length)];
    
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:26] range:NSMakeRange(7, 3)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(7, 3)];
    
    self.checkinLabel.attributedText = attrStr;
}

- (void)requestCheckin {
    [[AccountManager manager] requestCheckinWithAction:YuCloudDataList
                                                taskId:nil
                                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                if(success) {
                                                    NSDictionary *result = [info valueForKey:@"result"];
                                                    
                                                    self.checkinData = [CheckinData checkinWithDic:result];
                                                    
                                                    [self reloadHeaderWithCheckin:YES];
                                                    
                                                    [self refreshCheckinWithCheckinToday:self.checkinData.checkinToday
                                                                                    days:self.checkinData.checkinDays];
                                                }
                                                
                                                 [self refreshPersonalInfo];
                                            }];
}

- (void)touchCheckin {
    if(self.checkinData.checkinToday) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:APP_DELEGATE_WINDOW
                                              animated:YES];
    [[AccountManager manager] requestCheckinWithAction:YuCloudDataAdd
                                                taskId:self.checkinData.uid
                                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                [MBProgressHUD finishLoading:hud
                                                                      result:success
                                                                        text:[info msg]
                                                                  completion:^{
                                                                      if(success) {
                                                                          NSDictionary *result = [info valueForKey:@"result"];
                                                                          self.checkinData = [CheckinData checkinWithDic:result];
                                                                          self.checkinData.checkinToday = YES;
                                                                          [self refreshCheckinWithCheckinToday:self.checkinData.checkinToday
                                                                                                          days:self.checkinData.checkinDays];
                                                                      }
                                                                  }];
                                            }];
}

- (void)updateBadgeValue {
    NSInteger count = [[NotificationDataSource sharedClient] unReadNotificationsCount];
    [self.bubbleView setBubbleTipNumber:@(count).intValue];
    
    UIViewController *desController = self.tabBarController.viewControllers.lastObject;
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
}

- (void)touchMessageButton {
    NotificationCenterViewController *vc = [[NotificationCenterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refreshPersonalInfo {
    AccountInfo *accountInfo = [AccountManager manager].accountInfo;
    if (accountInfo) {
        self.nameLabel.text = accountInfo.nickname?:[NSUserDefaults nameOfUser:YUCLOUD_ACCOUNT_USERID];
        
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[accountInfo.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                         placeholderImage:[UIImage defaultAvatar]
                                completed:nil];
    }
    else {
        self.nameLabel.text = @"点击登录";
    }
}

- (void)touchHeader {
    MeInfoViewController *info = [MeInfoViewController new];
    info.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:info animated:YES];
}

- (NSString *)reuseIdentifierOfRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self typeOfRowAtIndexPath:indexPath]) {
        case MeAbout:
            return [MeAboutCell reuseIdentifier];
            
        default:
            return [UITableViewCell reuseIdentifier];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self refreshVersionInfo];
}

- (void)refreshVersionInfo {
    [[AccountManager manager] requestVersionWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        self.versionNew = success;
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.data[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self typeOfRowAtIndexPath:indexPath]) {
        default:
            return 68;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierOfRowAtIndexPath:indexPath]
                                                            forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self typeOfRowAtIndexPath:indexPath]) {
        case MeSettings:
            cell.imageView.image = [[UIImage imageNamed:@"ic_me_setup"] imageResized:40];
            cell.textLabel.text = @"账号设置";
            break;
            
        case MeAbout: {
            MeAboutCell *aCell = (MeAboutCell *)cell;
            aCell.imageView.image = [[UIImage imageNamed:@"ic_me_about"] imageResized:40];
            aCell.textLabel.text = @"关于";
            aCell.versionNew = self.versionNew;
        }
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([self typeOfRowAtIndexPath:indexPath]) {
        case MeSettings: {
            MeSettingsViewController *settings = [MeSettingsViewController new];
            settings.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settings animated:YES];
        }
            break;
            
        case MeAbout: {
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"];
            ReactiveWebViewController *web = [[ReactiveWebViewController alloc] initWithUrl:url];
            web.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:web animated:YES];
        }
            break;
    }
}

#pragma mark - VIDataSourceDelegate

- (void)dataSource:(id<VIDataSource>)dataSource didChangeContentForKey:(NSString *)key {
    [self updateBadgeValue];
}

@end
