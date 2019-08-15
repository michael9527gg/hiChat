//
//  ContactDetailController.m
//  hiChat
//
//  Created by Polly polly on 19/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "ContactDetailCell.h"
#import "ConversationSettingDataSource.h"
#import "PhotoViewer.h"

/*
 * 好友、陌生人、群成员好友、群成员陌生人
 */

@interface ContactDetailViewController () < ContactDetailCellDelegate >

@property (nonatomic, copy)   NSString        *userid;
@property (nonatomic, copy)   NSString        *groupid;

@property (nonatomic, strong) GroupMemberData *member;
@property (nonatomic, strong) UserData        *user; // 陌生人数据
@property (nonatomic, strong) ContactData     *contact; // 好友数据

@property (nonatomic, strong) UIButton        *adminBtn;
@property (nonatomic, strong) UIButton        *bannedBtn;

@property (nonatomic, copy)   NSString        *platformName;

@end

@implementation ContactDetailViewController

- (instancetype)initWithUserid:(NSString *)userid
                          user:(UserData *)user
                       groupid:(NSString *)groupid {
    if(self = [super init]) {
        self.userid = userid;
        
        self.user = user;
        
        self.contact = [[ContactsDataSource sharedClient] contactWithUserid:self.userid];
        
        AccountInfo *info = [AccountManager manager].accountInfo;
        if ([userid isEqualToString:info.loginid]) {
            self.contact = [ContactData new];
            self.contact.uid = info.loginid;
            self.contact.portraitUri = info.portraitUri;
            self.contact.nickname = info.nickname;
        }
        
        if(groupid) {
            self.groupid = groupid;
            self.member = [[GroupDataSource sharedClient] groupMemberWithUserd:self.userid
                                                                       groupid:self.groupid];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"用户详情";
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorFromString:@"0xf0f0f6"];
    
    [self.tableView registerClass:[ContactDetailCell class]
           forCellReuseIdentifier:[ContactDetailCell reuseIdentifier]];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    
    // 自己就展示下信息就可以了
    if([self.userid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
        self.tableView.tableFooterView = [UIView new];
        return;
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 220)];
    self.tableView.tableFooterView = footerView;
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.layer.cornerRadius = 8;
    addBtn.layer.masksToBounds = YES;
    [addBtn setBackgroundColor:[UIColor colorFromHex:0x0099ff]];
    [addBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHex:0x0099ff]
                                                  size:CGSizeMake(1, 1)]
                      forState:UIControlStateNormal];
    [addBtn addTarget:self
               action:@selector(addFriend)
     forControlEvents:UIControlEventTouchUpInside];
    [addBtn setTitle:self.contact?@"发起会话":@"添加好友"
            forState:UIControlStateNormal];
    [footerView addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView).offset(12);
        make.right.equalTo(footerView).offset(-12);
        make.top.equalTo(footerView).offset(10);
        make.height.equalTo(@44);
    }];
    
    GroupMemberData *curMember = [[GroupDataSource sharedClient] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                              groupid:self.groupid];
    // 非特殊会员不能加好友
    if(self.groupid && ![curMember.role isSpecialUser] && !self.contact) {
        addBtn.hidden = YES;
    }
    
    // 确定是好友关系
    if(self.contact) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_contacts_more"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(touchMore)];
    }
    
    if(self.groupid) {
        // 群主和管理员才能添加和移除管理员且只有特殊会员才能被设置为管理员
        if((curMember.isLord || curMember.isAdmin) && [self.member.role isSpecialUser]) {
            UIButton *adminBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            adminBtn.layer.cornerRadius = 8;
            adminBtn.layer.masksToBounds = YES;
            [adminBtn addTarget:self
                         action:@selector(changeAdmin)
               forControlEvents:UIControlEventTouchUpInside];
            
            if(self.member.isAdmin) {
                [adminBtn setTitle:@"撤销管理员"
                          forState:UIControlStateNormal];
                [adminBtn setBackgroundColor:[UIColor redColor]];
            } else {
                [adminBtn setTitle:@"添加管理员"
                          forState:UIControlStateNormal];
                [adminBtn setBackgroundColor:[UIColor colorFromHex:0x0099ff]];
            }
            
            [footerView addSubview:adminBtn];
            [adminBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(footerView).offset(12);
                make.right.equalTo(footerView).offset(-12);
                make.top.equalTo(addBtn.mas_bottom).offset(24);
                make.height.equalTo(@44);
            }];
            
            self.adminBtn = adminBtn;
        }
        
        // 群主和管理员具备禁言功能且被禁言人只能是普通会员
        if((curMember.isLord || curMember.isAdmin) &&
           ![self.member.role isSpecialUser]) {
            UIButton *adminBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            adminBtn.layer.cornerRadius = 8;
            adminBtn.layer.masksToBounds = YES;
            [adminBtn addTarget:self
                         action:@selector(changeMessageAbility)
               forControlEvents:UIControlEventTouchUpInside];
            
            if(self.member.isgag) {
                [adminBtn setTitle:@"取消禁言"
                          forState:UIControlStateNormal];
                [adminBtn setBackgroundColor:[UIColor colorFromHex:0x0099ff]];
            } else {
                [adminBtn setTitle:@"禁言"
                          forState:UIControlStateNormal];
                [adminBtn setBackgroundColor:[UIColor redColor]];
            }
            
            [footerView addSubview:adminBtn];
            [adminBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(footerView).offset(12);
                make.right.equalTo(footerView).offset(-12);
                if(self.adminBtn) {
                    make.top.equalTo(self.adminBtn.mas_bottom).offset(24);
                } else {
                    make.top.equalTo(addBtn.mas_bottom).offset(24);
                }
                make.height.equalTo(@44);
            }];
            
            self.bannedBtn = adminBtn;
        }
    }
    
    // 陌生人的情况
    if(!self.user && !self.contact && !self.member) {
        [[UserManager manager] requesUserInfoWithUserid:self.userid
                                             completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                 if(success) {
                                                     self.user = info[@"data"];
                                                     self.platformName = self.user.platformName;
                                                     [self.tableView reloadData];
                                                 } else {
                                                     [MBProgressHUD showMessage:[info msg]
                                                                         onView:APP_DELEGATE_WINDOW
                                                                         result:success
                                                                     completion:nil];
                                                 }
                                             }];
    }
    
    [[UserManager manager] refreshRCUserInfoCacheWithUserid:self.userid
                                                   userInfo:nil
                                                 completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                     if(success) {
                                                         UserData *userData = [info valueForKey:@"data"];
                                                         if(self.member) {
                                                             self.member.nickname = userData.nickname;
                                                             self.member.displayName = userData.displayName;
                                                             [[GroupDataSource sharedClient] addObject:self.member
                                                                                            entityName:[GroupMemberEntity entityName]];
                                                         }
                                                         if(self.contact) {
                                                             self.contact.nickname = userData.nickname;
                                                             self.contact.displayName = userData.displayName;
                                                             [[ContactsDataSource sharedClient] addObject:self.contact
                                                                                               entityName:[ContactEntity entityName]];
                                                         }
                                                         
                                                         self.platformName = userData.platformName;
                                                         
                                                         [self.tableView reloadData];
                                                     }
                                                 }];
}

- (void)changeMessageAbility {
    if(self.member.isgag) {
        [self cancelGag];
    } else {
        YuAlertViewController *alert = [YuAlertViewController alertWithTitle:@"禁言时长"
                                                                     message:@"请输入禁言时间，可设置最长43200分钟, 不填或者为0表示永久禁言"
                                                             textPlaceHolder:@"请输入分钟数"
                                                                        text:@"0"
                                                               textMaxLength:5
                                                               textMinLength:0
                                                                keyboardType:UIKeyboardTypeDefault
                                                                     okTitle:YUCLOUD_STRING_OK
                                                                    okAction:^(UIAlertAction * _Nonnull action, NSString * _Nonnull text) {
                                                                        [self addGagWithMinute:text.integerValue];
                                                                    }
                                                                 cancelTitle:YUCLOUD_STRING_CANCEL
                                                                cancelAction:nil
                                                                  completion:nil];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)addGagWithMinute:(NSInteger)minute {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[GroupManager manager] addGagForGroup:self.groupid
                                   userids:@[self.member.userid]
                                    minute:minute
                                completion:^(BOOL success, NSDictionary * _Nullable info) {
                                    if(success) {
                                        self.member.isgag = YES;
                                        [[GroupDataSource sharedClient] addObject:self.member
                                                                       entityName:[GroupMemberEntity entityName]];
                                        
                                        [self refreshBannedBtn];
                                    }
                                    
                                    [MBProgressHUD finishLoading:hud
                                                          result:success
                                                            text:[info msg]
                                                      completion:nil];
                                }];
}

- (void)cancelGag {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[GroupManager manager] removeGagFromGroup:self.groupid
                                       userids:@[self.member.userid]
                                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                                        if(success) {
                                            self.member.isgag = NO;
                                            [[GroupDataSource sharedClient] addObject:self.member
                                                                           entityName:[GroupMemberEntity entityName]];
                                            
                                            [self refreshBannedBtn];
                                        }
                                        [MBProgressHUD finishLoading:hud
                                                              result:success
                                                                text:[info msg]
                                                          completion:nil];
                                    }];
}

- (void)refreshBannedBtn {
    if(self.member.isgag) {
        [self.bannedBtn setTitle:@"取消禁言"
                       forState:UIControlStateNormal];
        [self.bannedBtn setBackgroundColor:[UIColor colorFromHex:0x0099ff]];
    } else {
        [self.bannedBtn setTitle:@"禁言"
                       forState:UIControlStateNormal];
        [self.bannedBtn setBackgroundColor:[UIColor redColor]];
    }
}

- (void)refreshAdminBtn {
    if(self.member.isAdmin) {
        [self.adminBtn setTitle:@"撤销管理员"
                  forState:UIControlStateNormal];
        [self.adminBtn setBackgroundColor:[UIColor redColor]];
    } else {
        [self.adminBtn setTitle:@"添加管理员"
                  forState:UIControlStateNormal];
        [self.adminBtn setBackgroundColor:[UIColor colorFromHex:0x0099ff]];
    }
}

- (void)deleteFriend {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[ContactsManager manager] deleteFriendWithUserid:self.userid
                                           completion:^(BOOL success, NSDictionary * _Nullable info) {
                                               if(success) {
                                                   ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:self.userid];
                                                   
                                                   [[ContactsDataSource sharedClient] deleteObject:contact];
                                                   
                                                   [[UserManager manager] refreshRCUserInfoCacheWithUserid:self.userid
                                                                                                  userInfo:nil
                                                                                                completion:nil];
                                                   [[RCManager manager] removeConversation:ConversationType_PRIVATE
                                                                                  targetId:self.userid];
                                               }
                                               [MBProgressHUD finishLoading:hud
                                                                     result:success
                                                                       text:success?@"删除成功":info[@"msg"]
                                                                 completion:^{
                                                                     if(success) {
                                                                         [self.navigationController popViewControllerAnimated:YES];
                                                                     }
                                                                 }];
                                           }];
}

- (void)addBlackList {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[ContactsManager manager] addBlackListWithFriendid:self.userid
                                             completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                 if(success) {
                                                     FriendBlackData *black = [[FriendBlackData alloc] init];
                                                     black.userid = self.contact.uid;
                                                     black.nickname = self.contact.nickname;
                                                     black.portraitUri = self.contact.portraitUri;
                                                     [[ContactsDataSource sharedClient] addObject:black
                                                                                       entityName:[FriendBlackEntity entityName]];
                                                     
                                                     // 消息能力
                                                     ConversationSettingData *setting = [ConversationSettingData conversationSettingWithType:ConversationType_PRIVATE
                                                                                                                                    targetId:self.userid];
                                                     setting.canMessage = NO;
                                                     setting.messageError = @"您已将对方列入黑名单";
                                                     [[ConversationSettingDataSource sharedClient] addObject:setting
                                                                                                  entityName:[ConversationSettingEntity entityName]];
                                                 }
                                                 
                                                 [MBProgressHUD finishLoading:hud
                                                                       result:success
                                                                         text:success?@"拉黑成功":info[@"msg"]
                                                                   completion:nil];
                                             }];
}

- (void)deleteFromBlackList {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[ContactsManager manager] deleteBlackListWithFriendid:self.userid
                                                completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                    if(success) {
                                                        FriendBlackData *data = [[ContactsDataSource sharedClient] blackWithUserid:self.userid];
                                                        [[ContactsDataSource sharedClient] deleteObject:data];
                                                        
                                                        // 消息能力
                                                        ConversationSettingData *setting = [ConversationSettingData conversationSettingWithType:ConversationType_PRIVATE
                                                                                                                                       targetId:self.userid];
                                                        setting.canMessage = YES;
                                                        [[ConversationSettingDataSource sharedClient] addObject:setting
                                                                                                     entityName:[ConversationSettingEntity entityName]];

                                                        
                                                    }
                                                    
                                                    [MBProgressHUD finishLoading:hud
                                                                          result:success
                                                                            text:success?@"取消成功":info[@"msg"]
                                                                      completion:nil];
                                                }];
}

- (void)touchMore {
    UIAlertControllerStyle alertControllerStyle = UIAlertControllerStyleActionSheet;
    if([[UniManager manager] currentDeviceType] == UIUserInterfaceIdiomPad) {
        alertControllerStyle = UIAlertControllerStyleAlert;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:alertControllerStyle];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"删除好友"
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [YuAlertViewController showAlertWithTitle:nil
                                                                                     message:@"确定删除此好友？"
                                                                              viewController:self
                                                                                     okTitle:YUCLOUD_STRING_OK
                                                                                    okAction:^(UIAlertAction * _Nonnull action) {
                                                                                        [self deleteFriend];
                                                                                    }
                                                                                 cancelTitle:YUCLOUD_STRING_CANCEL
                                                                                cancelAction:nil
                                                                                  preferredStyle:UIAlertControllerStyleAlert
                                                                                  completion:nil];
                                               }];
    [alert addAction:delete];
    
    UIAlertAction *black = nil;
    FriendBlackData *data = [[ContactsDataSource sharedClient] blackWithUserid:self.userid];
    if(data) {
        black = [UIAlertAction actionWithTitle:@"取消拉黑"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self deleteFromBlackList];
                                                      }];
        [alert addAction:black];
    }
//    else {
//        black = [UIAlertAction actionWithTitle:@"加入黑名单"
//                                                        style:UIAlertActionStyleDefault
//                                                      handler:^(UIAlertAction * _Nonnull action) {
//                                                          [self addBlackList];
//                                                      }];
//    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)changeAdmin {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[GroupManager manager] editGroupAdminRoleWithGroupid:self.groupid
                                                  userids:@[self.member.userid]
                                                     role:self.member.isAdmin?@1:@0
                                               completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                   if(success) {
                                                       if(self.member.isAdmin) {
                                                           self.member.groupRole = @"0";
                                                       } else {
                                                           self.member.groupRole = @"1";
                                                       }
                                                       [[GroupDataSource sharedClient] addObject:self.member
                                                                                      entityName:[GroupMemberEntity entityName]];
                                                       
                                                       [self refreshAdminBtn];
                                                   }
                                                   
                                                   [MBProgressHUD finishLoading:hud
                                                                         result:success
                                                                           text:info[@"msg"]
                                                                     completion:nil];
                                               }];
}

- (void)addFriend {
    if(self.contact) {
        [[RCManager manager] startConversationWithType:ConversationType_PRIVATE
                                              targetId:self.userid
                                                 title:self.contact.name];
    } else {
        MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
        
        [[ContactsManager manager] addFriendByUserid:self.userid
                                          completion:^(BOOL success, NSDictionary * _Nullable info) {
                                              if(success) {
                                                  [self.navigationController popViewControllerAnimated:YES];
                                              }
                                              
                                              [MBProgressHUD finishLoading:hud
                                                                    result:success
                                                                      text:info[@"msg"]
                                                                completion:^{
                                                                    [self.navigationController popViewControllerAnimated:YES];
                                                                }];
                                          }];
    }
}

- (void)updateDisplayName:(NSString *)displayName {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[ContactsManager manager] updateFriendDisplayNameByUserid:self.userid
                                                   displayName:displayName
                                                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                        if(success) {
                                                            [hud hideAnimated:YES];
                                                            
                                                            self.contact.displayName = displayName;
                                                            [[ContactsDataSource sharedClient] addObject:self.contact
                                                                                              entityName:[ContactEntity entityName]];
                                                            [self.tableView reloadData];
                                                            
                                                            // 刷新融云缓存
                                                            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:self.contact.uid
                                                                                                                 name:self.contact.name
                                                                                                             portrait:self.contact.portraitUri];
                                                            
                                                            [[UserManager manager] refreshRCUserInfoCacheWithUserid:nil
                                                                                                           userInfo:userInfo
                                                                                                         completion:nil];
                                                            
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_UPDATE_DISPALYNAME_NOTIFICATION
                                                                                                                object:nil
                                                                                                              userInfo:@{@"userid" : userInfo.userId,
                                                                                                                         @"displayName" : displayName}];
                                                        } else {
                                                            [MBProgressHUD finishLoading:hud
                                                                                  result:success
                                                                                    text:info[@"msg"]
                                                                              completion:^{
                                                                                  
                                                                              }];
                                                        }
                                                    }];
}

- (NSInteger)numberOfRows {
    NSInteger num = 1;
    if(self.contact && ![self.contact.uid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
        num++;
    }
    
    if(self.platformName.length) {
        num++;
    }
    
    return num;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:[ContactDetailCell reuseIdentifier]
                                               forIndexPath:indexPath];
    }
    
    return [tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"";
    
    switch (indexPath.row) {
        case 0: {
            ContactDetailCell *cCell = (ContactDetailCell *)cell;
            cCell.delegate = self;
            
            if(self.contact) {
                [cCell setNickname:self.contact.nickname
                       displayName:self.contact.displayName
                          portrait:self.contact.portraitUri
                             phone:self.contact.phone];
            } else if(self.member) {
                [cCell setNickname:self.member.nickname
                       displayName:self.member.displayName
                          portrait:self.member.portraitUri
                             phone:self.member.phone];
            } else if(self.user) {
                [cCell setNickname:self.user.nickname
                       displayName:self.user.displayName
                          portrait:self.user.portrait
                             phone:nil];
            } else {
                [cCell setNickname:@"用户已注销"
                       displayName:nil
                          portrait:nil
                             phone:nil];
            }
        }
            break;
        case 1: {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if(self.platformName.length) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = self.platformName;
            } else if(self.contact.displayName.length) {
                cell.textLabel.text = @"修改备注";
            } else {
                cell.textLabel.text = @"添加备注";
            }
        }
            break;
        case 2: {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if(self.contact.displayName.length) {
                cell.textLabel.text = @"修改备注";
            } else {
                cell.textLabel.text = @"添加备注";
            }
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 76;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.textLabel.text containsString:@"备注"]) {
        [[UniManager manager] startTextEdit:self.contact.displayName
                                placeholder:@"输入备注名（长度32个字符内）"
                                  maxLength:32
                                 completion:^(BOOL success, NSDictionary * _Nullable info) {
                                     if(success) {
                                         NSString *text = info[@"text"];
                                         [self updateDisplayName:text];
                                     }
                                 }];
    }
}

#pragma mark - ContactDetailCellDelegate

- (void)makeCall {
    NSString *phone = self.contact.phone;
    if (phone.length == 0) {
        phone = self.user.phone;
    }
    
    if (phone.length > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", phone]]];
    }
}

- (void)showIcon:(NSString *)icon {
    [PhotoViewer showImage:icon];
}

@end
