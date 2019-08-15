//
//  MeSettingsViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "MeSettingsViewController.h"
#import "AppDelegate.h"
#import "PasswordViewController.h"
#import "MePrivacyViewController.h"
#import "MeSettingCell.h"

typedef enum : NSUInteger {
    SettingsChangePass,
    SettingsPrivacy,
    SettingsClearCache,
    SettingsLogout
} SettingsItemType;

@interface MeSettingsViewController ()

@end

@implementation MeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"账号设置";
    
    self.view.backgroundColor = self.tableView.backgroundColor = [UIColor colorFromString:@"0xF7F7F7"];
    
    self.data = @[@(SettingsChangePass),
                  @(SettingsPrivacy),
                  @(SettingsClearCache)];
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    UIImage *image = [UIImage imageNamed:@"ic_signup_signup"];
    [logoutBtn setBackgroundImage:[image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2]
                         forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
    [logoutBtn addTarget:self
                  action:@selector(touchLogout)
        forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
    [footerView addSubview:logoutBtn];
    [logoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@49);
        make.width.equalTo(footerView).multipliedBy(.8);
        make.center.equalTo(footerView);
    }];
    
    self.tableView.tableFooterView = footerView;
    
    [self.tableView registerClass:[MeSettingCell class]
           forCellReuseIdentifier:[MeSettingCell reuseIdentifier]];
}

- (void)touchLogout {
    [YuAlertViewController showAlertWithTitle:@"退出"
                                      message:@"是否退出登录？退出后将不再接收到聊天消息"
                               viewController:self
                                      okTitle:YUCLOUD_STRING_OK
                                     okAction:^(UIAlertAction * _Nonnull action) {
                                         MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
                                         
                                         [[AccountManager manager] logoutWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                             if (success) {
                                                 [NSUserDefaults saveToken:nil];
                                             }
                                             
                                             [MBProgressHUD finishLoading:hud
                                                                   result:success
                                                                     text:[info msg]
                                                               completion:^{
                                                                   [[AppDelegate appDelegate] showLoginScreen:NO];
                                                               }];
                                         }];
                                     }
                                  cancelTitle:YUCLOUD_STRING_CANCEL
                                 cancelAction:nil
                                   completion:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[MeSettingCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MeSettingCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SettingsChangePass:
            [cell setIcon:[UIImage imageNamed:@"ic_me_resetpass"]
                     name:@"密码修改"];
            break;
            
        case SettingsPrivacy:
            [cell setIcon:[UIImage imageNamed:@"ic_me_private"]
                     name:@"隐私"];
            break;
            
        case SettingsClearCache:
            [cell setIcon:[UIImage imageNamed:@"ic_me_clearcache"]
                     name:@"清除缓存"];
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case SettingsChangePass: {
            PasswordViewController *pass = [PasswordViewController new];
            [self.navigationController pushViewController:pass animated:YES];
        }
            
            break;
            
        case SettingsPrivacy: {
            MePrivacyViewController *privacy = [[MePrivacyViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:privacy animated:YES];
        }
            break;
            
        case SettingsClearCache:
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                [MBProgressHUD showMessage:@"清除缓存成功"
                                    onView:APP_DELEGATE_WINDOW
                                    result:YES
                                completion:nil];
            }];
            break;
            
        default:
            break;
    }
}

@end
