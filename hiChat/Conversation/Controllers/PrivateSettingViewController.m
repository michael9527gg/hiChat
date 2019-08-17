//
//  PrivateSettingViewController.m
//  hiChat
//
//  Created by Polly polly on 14/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "PrivateSettingViewController.h"
#import "PrivateUserInfoCell.h"
#import "AppDelegate.h"
#import "MessageHistoryViewController.h"
#import "ConversationSettingDataSource.h"
#import "ContactDetailViewController.h"

@interface PrivateSettingViewController ()

@property (nonatomic, copy)   NSString        *userId;
@property (nonatomic, strong) RCConversation  *currentConversation;
@property (nonatomic, assign) BOOL            unableNotification;
@property (nonatomic, strong) ContactData     *contact;
@property (nonatomic, strong) FriendBlackData *black;

@end

@implementation PrivateSettingViewController

- (instancetype)initWithUserId:(NSString *)userId {
    if(self = [self initWithStyle:UITableViewStylePlain]) {
        self.userId = userId;
        ContactData *contact = [[ContactsDataSource sharedInstance] contactWithUserid:self.userId];
        if(!contact) {
            // 说明被拉黑了
            self.black = [[ContactsDataSource sharedInstance] blackWithUserid:self.userId];
        }
        
        self.contact = contact;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"聊天详情";
    self.tableView.backgroundColor = [UIColor colorFromString:@"0xf0f0f6"];
    
    [self.tableView registerClass:[PrivateUserInfoCell class]
           forCellReuseIdentifier:[PrivateUserInfoCell reuseIdentifier]];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_contacts_more"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(touchMore)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkStatus];
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
                                                       [self deleteFriend];
                                                   }];
    [alert addAction:delete];
    
    UIAlertAction *black = nil;
    FriendBlackData *data = [[ContactsDataSource sharedInstance] blackWithUserid:self.userId];
    if(data) {
        black = [UIAlertAction actionWithTitle:@"取消拉黑"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * _Nonnull action) {
                                           [self deleteFromBlackList];
                                       }];
        [alert addAction:black];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addBlackList {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[ContactsManager manager] addBlackListWithFriendid:self.userId
                                             completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                 [MBProgressHUD finishLoading:hud
                                                                       result:success
                                                                         text:success?@"拉黑成功":info[@"msg"]
                                                                   completion:^{
                                                                       if(success) {
                                                                           // 拉黑
                                                                           FriendBlackData *black = [[FriendBlackData alloc] init];
                                                                           black.userid = self.contact.uid;
                                                                           black.nickname = self.contact.nickname;
                                                                           black.portraitUri = self.contact.portraitUri;
                                                                           [[ContactsDataSource sharedInstance] addObject:black];
                                                                           
                                                                           // 消息能力
                                                                           ConversationSettingData *setting = [ConversationSettingData conversationSettingWithType:ConversationType_PRIVATE
                                                                                                                                                          targetId:self.userId];
                                                                           setting.canMessage = NO;
                                                                           setting.messageError = @"您已将对方列入黑名单";
                                                                           [[ConversationSettingDataSource sharedInstance] addObject:setting];
                                                                       }
                                                                   }];
                                             }];
}

- (void)deleteFromBlackList {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[ContactsManager manager] deleteBlackListWithFriendid:self.userId
                                                completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                    [MBProgressHUD finishLoading:hud
                                                                          result:success
                                                                            text:success?@"取消成功":info[@"msg"]
                                                                      completion:^{
                                                                          if(success) {
                                                                              FriendBlackData *data = [[ContactsDataSource sharedInstance] blackWithUserid:self.userId];
                                                                              [[ContactsDataSource sharedInstance] deleteObject:data];
                                                                              
                                                                              [[ContactsManager manager] refreshFriendsListWithCompletion:nil];
                                                                              
                                                                              // 消息能力
                                                                              ConversationSettingData *setting = [ConversationSettingData conversationSettingWithType:ConversationType_PRIVATE
                                                                                                                                                             targetId:self.userId];
                                                                              setting.canMessage = YES;
                                                                              [[ConversationSettingDataSource sharedInstance] addObject:setting];
                                                                          }
                                                                      }];
                                                }];
}

- (void)deleteFriend {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[ContactsManager manager] deleteFriendWithUserid:self.userId
                                           completion:^(BOOL success, NSDictionary * _Nullable info) {
                                               [MBProgressHUD finishLoading:hud
                                                                     result:success
                                                                       text:success?@"删除成功":info[@"msg"]
                                                                 completion:^{
                                                                     if(success) {
                                                                         if(!self.black) {
                                                                             [[ContactsDataSource sharedInstance] deleteObject:self.contact];
                                                                         }
                                                                         
                                                                         [[UserManager manager] refreshRCUserInfoCacheWithUserid:self.userId
                                                                                                                        userInfo:nil
                                                                                                                      completion:nil];
                                                                         
                                                                         [[RCManager manager] removeConversation:ConversationType_PRIVATE
                                                                                                        targetId:self.userId];
                                                                         
                                                                         [self.navigationController popToRootViewControllerAnimated:YES];
                                                                     }
                                                                 }];
                                           }];
}

- (void)checkStatus {
    self.currentConversation = [[RCIMClient sharedRCIMClient] getConversation:ConversationType_PRIVATE
                                                                     targetId:self.userId];
    
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_PRIVATE
                                                            targetId:self.userId
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                 self.unableNotification = nStatus==NOTIFY?NO:YES;
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [self.tableView reloadData];
                                                                 });
                                                             }
                                                               error:nil];
}

- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    BOOL block = swch.on;
    
    [[RCManager manager] blockConversationNotificationWithType:ConversationType_PRIVATE
                                                      targetid:self.userId
                                                         block:swch.on
                                                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if(!success) {
                                                                [MBProgressHUD showMessage:[info msg]
                                                                                    onView:APP_DELEGATE_WINDOW
                                                                                    result:success
                                                                                completion:nil];
                                                                
                                                                swch.on = !swch.on;
                                                            }
                                                            
                                                            self.unableNotification = success?block:!block;
                                                        });
                                                    }];
}

- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    BOOL top = swch.on;
    
    [[RCManager manager] topConversationNotificationWithType:ConversationType_PRIVATE
                                                    targetid:self.userId
                                                         top:swch.on
                                                  completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          if(!success) {
                                                              [MBProgressHUD showMessage:[info msg]
                                                                                  onView:APP_DELEGATE_WINDOW
                                                                                  result:success
                                                                              completion:nil];
                                                              
                                                              swch.on = !swch.on;
                                                          }
                                                          
                                                          self.currentConversation.isTop = success?top:!top;
                                                          [self.tableView reloadData];
                                                      });
                                                  }];
}

- (void)clearHistoryMessage {
    RCIMClient *client = [RCIMClient sharedRCIMClient];
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [client clearRemoteHistoryMessages:ConversationType_PRIVATE
                              targetId:self.userId
                            recordTime:0
                               success:^{
                                   [client deleteMessages:ConversationType_PRIVATE
                                                 targetId:self.userId
                                                  success:^{
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [MBProgressHUD finishLoading:hud
                                                                                result:YES
                                                                                  text:@"聊天记录已清除"
                                                                            completion:nil];
                                                      });
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:CONVERSATION_CLEAR_MESSAGE_NOTIFIACTION
                                                                                                          object:nil
                                                                                                        userInfo:nil];
                                                  }
                                                    error:^(RCErrorCode status) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [MBProgressHUD finishLoading:hud
                                                                                  result:NO
                                                                                    text:@"消息记录清除失败"
                                                                              completion:nil];
                                                        });
                                                    }];
                               } error:^(RCErrorCode status) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [MBProgressHUD finishLoading:hud
                                                             result:NO
                                                               text:@"消息记录清除失败"
                                                         completion:nil];
                                   });
                               }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}       

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 4;
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        return 80;
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:[PrivateUserInfoCell reuseIdentifier]
                                               forIndexPath:indexPath];
    } else {
        return [tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]
                                               forIndexPath:indexPath];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(nonnull UITableViewCell *)cell
forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        PrivateUserInfoCell *pCell = (PrivateUserInfoCell *)cell;
        if(self.contact) {
            pCell.data = self.contact;
        } else {
            pCell.data = self.black;
        }
    } else if(indexPath.section == 1 && indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"消息免打扰";
        UISwitch *newSwitch = [UISwitch new];
        newSwitch.on = self.unableNotification;
        [newSwitch addTarget:self
                      action:@selector(clickNotificationBtn:)
            forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = newSwitch;
    } else if(indexPath.section == 1 && indexPath.row == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"会话置顶";
        UISwitch *newSwitch = [UISwitch new];
        newSwitch.on = self.currentConversation.isTop;
        [newSwitch addTarget:self
                      action:@selector(clickIsTopBtn:)
            forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = newSwitch;
    }
    else if(indexPath.section == 1 && indexPath.row == 2) {
        cell.textLabel.text = @"聊天记录";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.section == 1 && indexPath.row == 3) {
        cell.textLabel.text = @"清除聊天记录";
        cell.accessoryView = nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1 && indexPath.row == 3) {
        [YuAlertViewController showAlertWithTitle:@"温馨提示"
                                          message:@"确定清除聊天记录?"
                                   viewController:self.navigationController
                                          okTitle:@"确定"
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             [self clearHistoryMessage];
                                         }
                                      cancelTitle:@"取消"
                                     cancelAction:nil
                                       completion:nil];
    } else if(indexPath.section == 1 && indexPath.row == 2) {
        MessageHistoryViewController *vc = [[MessageHistoryViewController alloc] init];
        vc.conversationType = ConversationType_PRIVATE;
        vc.targetid = self.userId;
        vc.keywords = nil;
        [self.navigationController pushViewController:vc animated:YES];
    } else if(indexPath.section == 0 && indexPath.row == 0) {
        ContactDetailViewController *detail = [[ContactDetailViewController alloc] initWithUserid:self.userId
                                                                                             user:nil
                                                                                          groupid:nil];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

@end
