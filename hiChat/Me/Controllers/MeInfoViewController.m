//
//  MeInfoViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "MeInfoViewController.h"
#import "UniManager.h"
#import "InfoPortraitCell.h"
#import "InfoDetailCell.h"
#import "AppDelegate.h"

typedef enum : NSUInteger {
    InfoPhone,
    InfoAccount,
    InfoPlatformName,
    InfoInvitationCode
} InfoItemType;

@interface MeInfoViewController ()

@property (nonatomic, copy) NSString    *portraitUri;
@property (nonatomic, copy) NSString    *nickname;
@property (nonatomic, copy) NSString    *account;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;

@property (nonatomic, assign) BOOL      modified;

@end

@implementation MeInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人账户";
    
    self.view.backgroundColor = self.tableView.backgroundColor = [UIColor colorFromString:@"0xF7F7F7"];
    
    UIImageView *headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_me_personal_bg"]];
    headerView.userInteractionEnabled = YES;
    headerView.frame = CGRectMake(0, 0, 0, 220);
    self.iconView = [[UIImageView alloc] init];
    self.iconView.layer.cornerRadius = 40;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.borderWidth = 1.5;
    self.iconView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iconView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(touchIcon)];
    [self.iconView addGestureRecognizer:tap];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorFromString:@"0xF7F7F7"];
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(headerView);
        make.bottom.equalTo(headerView);
        make.height.equalTo(@5);
    }];
    
    UIImageView *whiteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_me_header_white"]];
    [headerView addSubview:whiteView];
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView);
        make.bottom.equalTo(lineView.mas_top);
        make.height.equalTo(@90);
        make.width.equalTo(headerView).multipliedBy(.9);
    }];
    
    [headerView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(whiteView.mas_top);
        make.centerX.equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor colorFromHex:0x37c4ff];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.userInteractionEnabled = YES;
    self.nameLabel.layer.borderWidth = 1.0;
    self.nameLabel.layer.borderColor = [UIColor colorFromString:@"0xF7F7F7"].CGColor;
    UITapGestureRecognizer *tapp = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(touchName)];
    [self.nameLabel addGestureRecognizer:tapp];
    [headerView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView);
        make.top.equalTo(self.iconView.mas_bottom).offset(8);
        make.width.mas_greaterThanOrEqualTo(100);
        make.height.mas_greaterThanOrEqualTo(26);
    }];
    self.tableView.tableHeaderView = headerView;
    
    NSMutableArray *mulArr = [NSMutableArray array];
    [mulArr addObject:@[@(InfoPhone)]];
    [mulArr addObject:@[@(InfoAccount)]];
    
    AccountInfo *info = [AccountManager manager].accountInfo;
    if([info.role isSpecialUser] && info.platformName.length) {
        [mulArr addObject:@[@(InfoPlatformName)]];
    }
    
    if ([info.role isSpecialUser] && info.invitationCode.length) {
        [mulArr addObject:@[@(InfoInvitationCode)]];
    }
    
    self.data = mulArr;
    
    self.portraitUri = info.portraitUri;
    self.nickname = info.nickname;
    self.account = info.account;
    
    [self refreshPersonalInfo];
    
    [self.tableView registerClass:[InfoDetailCell class]
           forCellReuseIdentifier:[InfoDetailCell reuseIdentifier]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
}

- (NSString *)reuseIdentifierOfRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self typeOfRowAtIndexPath:indexPath]) {
        default:
            return [InfoDetailCell reuseIdentifier];
    }
}

- (void)touchIcon {
    [[UniManager manager] selectImageWithLimit:1
                                          type:PHAssetMediaTypeImage
                                viewController:self
                                       squared:YES
                                        upload:YES
                                withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                    if (success) {
                                        NSArray *arr = info[@"images"];
                                        self.portraitUri = arr.firstObject;
                                        self.modified = YES;
                                        [self refreshPersonalInfo];
                                    }
                                }];
}

- (void)touchName {
    [[UniManager manager] startTextEdit:self.nickname
                            placeholder:@"请输入昵称"
                              maxLength:12
                             completion:^(BOOL success, NSDictionary * _Nullable info) {
                                 if (success){
                                     self.nickname = info[@"text"];
                                     self.modified = YES;
                                     [self refreshPersonalInfo];
                                 }
                             }];
}

- (void)setModified:(BOOL)modified {
    if (modified) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(touchSave)];
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)refreshPersonalInfo {
    self.nameLabel.text = self.nickname;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[self.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:[UIImage defaultAvatar]
                            completed:nil];
    
    [self.tableView reloadData];
}

- (void)touchSave {
    AccountInfo *info = [AccountInfo new];
    info.portraitUri = self.portraitUri;
    info.nickname = self.nickname;
    info.account = self.account;
    
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    
    [[AccountManager manager] requestMeInfoWithAction:YuCloudDataEdit
                                                 user:[AccountManager manager].loginid
                                                 info:info
                                           completion:^(BOOL success, NSDictionary * _Nullable info) {
                                               if(success) {
                                                   [[UserManager manager] refreshCurrentUserInfo];
                                               }
                                               
                                               [MBProgressHUD finishLoading:hud
                                                                     result:success
                                                                       text:[info msg]
                                                                 completion:^{
                                                                     if (success) {
                                                                         [self.navigationController popViewControllerAnimated:YES];
                                                                     }
                                                                 }];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierOfRowAtIndexPath:indexPath]
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(InfoDetailCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryNone;
    AccountInfo *info = [AccountManager manager].accountInfo;
    
    switch ([self typeOfRowAtIndexPath:indexPath]) {
        case InfoPhone:
            [cell setIcon:[UIImage imageNamed:@"ic_me_phone"]
                     name:@"手机"
                   detail:info.phone];
            
            break;
            
        case InfoAccount:
            [cell setIcon:[UIImage imageNamed:@"ic_me_account"]
                     name:@"账号"
                   detail:self.account];
            break;
            
        case InfoInvitationCode:
            [cell setIcon:[UIImage imageNamed:@"ic_me_invitecode"]
                     name:@"我的邀请码"
                   detail:info.invitationCode];
            break;
            
        case InfoPlatformName:
            [cell setIcon:[UIImage imageNamed:@"ic_me_platform"]
                     name:@"我的平台"
                   detail:info.platformName];
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([self typeOfRowAtIndexPath:indexPath]) {
        case InfoAccount: {
            [[UniManager manager] startTextEdit:self.account
                                    placeholder:@"请输入账号"
                                      maxLength:30
                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                         if (success){
                                             self.account = info[@"text"];
                                             self.modified = YES;
                                             [self refreshPersonalInfo];
                                         }
                                     }];
        }
            break;
            
        case InfoInvitationCode: {
            NSString *code = [AccountManager manager].accountInfo.invitationCode;
            if (code.length) {
                [UIPasteboard generalPasteboard].string = code;
                [MBProgressHUD showMessage:@"邀请码已复制"
                                    onView:APP_DELEGATE_WINDOW
                                    result:YES
                                completion:nil];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
