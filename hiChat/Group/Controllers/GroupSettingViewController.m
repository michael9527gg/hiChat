//
//  GroupSettingViewController.m
//  hiChat
//
//  Created by Polly polly on 16/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupSettingViewController.h"
#import "GroupManager.h"
#import "GroupMemberCell.h"
#import "ContactsSelectViewController.h"
#import "GroupMemberListViewController.h"
#import "GroupMemberSelectViewController.h"
#import "GroupAnnounceViewController.h"
#import "ContactDetailViewController.h"
#import "MessageHistoryViewController.h"
#import "MessageSendManager.h"
#import <LYCocoaDevKit/UICollectionViewCell+LYCocoaDevKit.h>

@interface GroupSettingViewController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LYDataSourceDelegate, ContactsSelectDelegate, GroupMemberSelectDelegate, GroupAnnounceControllerDelegate >

@property (nonatomic, copy)   NSString            *groupId;
@property (nonatomic, strong) GroupData           *groupInfo;
@property (nonatomic, strong) GroupMemberData     *currentMember;
@property (nonatomic, assign) BOOL                isTop;
@property (nonatomic, assign) BOOL                isSilent;

@property (nonatomic, strong) UICollectionView    *membersView;
@property (nonatomic, weak)   GroupDataSource     *dataSource;
@property (nonatomic, strong)   NSFetchedResultsController            *fetchedResultsController;

@end

@implementation GroupSettingViewController

- (instancetype)initWithGroupId:(NSString *)groupId {
    if(self = [self initWithStyle:UITableViewStylePlain]) {
        self.groupId = groupId;
        
        // 数据库读取群组信息
        self.groupInfo = [[GroupDataSource sharedInstance] groupWithGroupid:self.groupId];
        
        self.currentMember = [[GroupDataSource sharedInstance] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                          groupid:self.groupId];
        
        // 查询当前会话置顶状态
        [self checkConversationIsTop];
        
        // 查询群组消息免打扰状态
        [self checkConversationNotificationStatus];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"群组信息";
    self.tableView.backgroundColor = [UIColor colorFromString:@"0xf0f0f6"];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    self.membersView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                          collectionViewLayout:flowLayout];
    self.membersView.delegate = self;
    self.membersView.dataSource = self;
    self.membersView.scrollEnabled = NO;
    self.membersView.backgroundColor = [UIColor whiteColor];
    [self.membersView registerClass:[GroupMemberCell class]
         forCellWithReuseIdentifier:[GroupMemberCell reuseIdentifier]];
    
    self.tableView.tableHeaderView = self.membersView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
    UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissBtn.backgroundColor = [UIColor redColor];
    if([self.groupInfo.creatorid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
        [dismissBtn setTitle:@"解散群组" forState:UIControlStateNormal];
    } else {
        [dismissBtn setTitle:@"退出群组" forState:UIControlStateNormal];
    }
    [dismissBtn addTarget:self
                   action:@selector(touchDismiss)
         forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:dismissBtn];
    [dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView).offset(24);
        make.right.equalTo(footerView).offset(-24);
        make.height.equalTo(@44);
        make.centerY.equalTo(footerView);
    }];
    self.tableView.tableFooterView = footerView;
    
    // 绑定群成员列表到数据库
    [self registerDataBase];
}

- (void)registerDataBase {
    self.dataSource = [GroupDataSource sharedInstance];
    
    self.fetchedResultsController = [self.dataSource addDelegate:self
                                                          entity:[GroupMemberEntity entityName]
                                                       predicate:[NSPredicate predicateWithFormat:@"groupid == %@", self.groupId]
                                                 sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"groupRole" ascending:NO],
                                                                                                                                                                                                         [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]
                                              sectionNameKeyPath:nil];
    
    [self refreshMembersView];
}

- (void)touchDismiss {
    NSString *message = nil;
    NSString *actionTitle = nil;
    BOOL dismiss;
    
    if([self.groupInfo.creatorid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
        message = @"确定解散群组吗？";
        actionTitle = @"解散";
        dismiss = YES;
    } else {
        message = @"确定退出群组吗？";
        actionTitle = @"退出";
        dismiss = NO;
    }
    
    UIAlertControllerStyle alertControllerStyle = UIAlertControllerStyleActionSheet;
    if([[UniManager manager] currentDeviceType] == UIUserInterfaceIdiomPad) {
        alertControllerStyle = UIAlertControllerStyleAlert;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:alertControllerStyle];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:actionTitle
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   if(dismiss) {
                                                       [self dismissGroup];
                                                   } else {
                                                       [self quitGroup];
                                                   }
                                               }];
    [alert addAction:ok];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissGroup {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    
    [[GroupManager manager] dismissGroupWithGroupid:self.groupId
                                         completion:^(BOOL success, NSDictionary * _Nullable info) {
                                             [MBProgressHUD finishLoading:hud
                                                                   result:success
                                                                     text:[info msg]
                                                               completion:^{
                                                                   if (success) {
                                                                       GroupData *group = [[GroupDataSource sharedInstance] groupWithGroupid:self.groupId];
                                                                       [[GroupDataSource sharedInstance] deleteObject:group];
                                                                       
                                                                       [[RCManager manager] removeConversation:ConversationType_GROUP
                                                                                                      targetId:self.groupId];
                                                                       
                                                                       [self.navigationController popToRootViewControllerAnimated:YES];
                                                                   }
                                                               }];
                                         }];
}

- (void)quitGroup {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[GroupManager manager] quitGroupWithGroupid:self.groupId
                                      completion:^(BOOL success, NSDictionary * _Nullable info) {
                                          if(success) {
                                              [[RCManager manager] removeConversation:ConversationType_GROUP
                                                                             targetId:self.groupId];
                                              
                                              [self.navigationController popToRootViewControllerAnimated:YES];
                                          }
                                          
                                          [MBProgressHUD finishLoading:hud
                                                                result:success
                                                                  text:info[@"msg"]
                                                            completion:nil];
                                      }];
}

- (void)refreshMembersView {
    [self.membersView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.membersView.height = self.membersView.contentSize.height;
        self.tableView.tableHeaderView = self.membersView;
    });
}

- (void)checkConversationIsTop {
    ConversationSettingData *data = [[ConversationSettingDataSource sharedInstance] settingWithType:ConversationType_GROUP
                                                                                         targetId:self.groupId];
    
    self.isTop = data.isTop;
}

- (void)checkConversationNotificationStatus {
    ConversationSettingData *data = [[ConversationSettingDataSource sharedInstance] settingWithType:ConversationType_GROUP
                                                                                         targetId:self.groupId];
    self.isSilent = data.isSilent;
}

- (void)refreshGroupInfo {
    [[GroupManager manager] requesGroupInfoWithGroupId:self.groupId
                                            completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                if(success) {
                                                    self.groupInfo = (GroupData *)[info valueForKey:@"data"];
                                                    [self.tableView reloadData];
                                                } else {
                                                    [MBProgressHUD showMessage:info[@"msg"]
                                                                        onView:APP_DELEGATE_WINDOW
                                                                        result:success
                                                                    completion:nil];
                                                }
                                            }];
}

- (void)refreshGroupMembers {
    [[GroupManager manager] requesGroupMembersWithGroupId:self.groupId
                                               completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                   
                                               }];
}

- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    BOOL block = swch.on;
    
    [[RCManager manager] blockConversationNotificationWithType:ConversationType_GROUP
                                                      targetid:self.groupId
                                                         block:block
                                                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if(!success) {
                                                                [MBProgressHUD showMessage:info[@"msg"]
                                                                                    onView:APP_DELEGATE_WINDOW
                                                                                    result:success
                                                                                completion:nil];
                                                            }
                                                            
                                                            self.isSilent = success?block:!block;
                                                            [self.tableView reloadData];
                                                        });
                                                    }];
}

- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    BOOL top = swch.on;
    
    [[RCManager manager] topConversationNotificationWithType:ConversationType_GROUP
                                                    targetid:self.groupId
                                                         top:swch.on
                                                  completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          if(!success) {
                                                              [MBProgressHUD showMessage:info[@"msg"]
                                                                                  onView:APP_DELEGATE_WINDOW
                                                                                  result:success
                                                                              completion:nil];
                                                          }
                                                          self.isTop = success?top:!top;
                                                          [self.tableView reloadData];
                                                      });
                                                  }];
}

- (void)clearHistoryMessage {
    RCIMClient *client = [RCIMClient sharedRCIMClient];
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [client clearRemoteHistoryMessages:ConversationType_GROUP
                              targetId:self.groupId
                            recordTime:0
                               success:^{
                                   [client deleteMessages:ConversationType_GROUP
                                                 targetId:self.groupId
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

- (void)updateGroupInfoWithName:(NSString *)groupName
                       portrait:(NSString *)portrait
                   announcement:(NSString *)announcement {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[GroupManager manager] editGroupInfoWithGroupid:self.groupId
                                                name:groupName
                                            portrait:portrait
                                        announcement:announcement
                                          completion:^(BOOL success, NSDictionary * _Nullable info) {
                                              if(success) {
                                                  if(groupName) {
                                                      self.groupInfo.name = groupName;
                                                  }
                                                  if(announcement) {
                                                      self.groupInfo.introduce = announcement;
                                                      
                                                      [[MessageSendManager manager] sendMentionAllToGroup:self.groupId
                                                                                                  message:announcement];
                                                  }
                                                  if(portrait) {
                                                      self.groupInfo.portrait = portrait;
                                                  }
                                                  [[GroupDataSource sharedInstance] addObject:self.groupInfo];
                                                  
                                                  [self.tableView reloadData];
                                              }
                                              
                                              [MBProgressHUD finishLoading:hud
                                                                    result:success
                                                                      text:info[@"msg"]
                                                                completion:nil];
                                          }];
}

- (void)touchBanAll:(UISwitch *)swch {
    BOOL ban = swch.on;
    
    [[GroupManager manager] banGroupWithGroupid:self.groupId
                                            ban:@(ban).stringValue
                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if(success) {
                                                 self.groupInfo.banState = @(ban).stringValue;
                                                 [[GroupDataSource sharedInstance] addObject:self.groupInfo];
                                             } else {
                                                 [MBProgressHUD showMessage:[info msg]
                                                                     onView:APP_DELEGATE_WINDOW
                                                                     result:YES
                                                                 completion:nil];
                                             }
                                             
                                             [self.tableView reloadData];
                                         });
                                     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 4;
        case 2: {
            GroupMemberData *member = [[GroupDataSource sharedInstance] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                                   groupid:self.groupId];
            if(member.isLord || member.isAdmin) {
                return 4;
            } else {
                return 3;
            }
        }
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    for(UIView *subView in cell.contentView.subviews) {
        if(subView.tag == 101 || subView.tag == 100) {
            [subView removeFromSuperview];
        }
    }
    
    if((indexPath.section == 3 && indexPath.row == 0) ||
       (indexPath.section == 3 && indexPath.row == 1)) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    GroupData *group = self.groupInfo;
    
    if(indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"全部群成员(%@)", group.memberCount];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = @"群组头像";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.tag = 101;
        [iconView sd_setImageWithURL:[NSURL URLWithString:[group.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                    placeholderImage:nil
                           completed:nil];
        
        [cell.contentView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell).offset(-36);
            make.top.equalTo(cell).offset(4);
            make.bottom.equalTo(cell).offset(-4);
            make.width.equalTo(iconView.mas_height);
        }];
    }
    else if(indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = @"群组名称";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.tag = 100;
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.text = group.name;
        [cell.contentView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView).offset(0);
            make.centerY.equalTo(cell.contentView);
        }];
    }
    else if(indexPath.section == 1 && indexPath.row == 2) {
        cell.textLabel.text = @"群公告";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.section == 1 && indexPath.row == 3) {
        cell.textLabel.text = @"聊天记录";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.section == 2 && indexPath.row == 0) {
        cell.textLabel.text = @"消息免打扰";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UISwitch *newSwitch = [UISwitch new];
        newSwitch.on = self.isSilent;
        [newSwitch addTarget:self
                      action:@selector(clickNotificationBtn:)
            forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = newSwitch;
    }
    else if(indexPath.section == 2 && indexPath.row == 1) {
        cell.textLabel.text = @"会话置顶";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UISwitch *newSwitch = [UISwitch new];
        newSwitch.on = self.isTop;
        [newSwitch addTarget:self
                      action:@selector(clickIsTopBtn:)
            forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = newSwitch;
    }
    else if(indexPath.section == 2 && indexPath.row == 2) {
        cell.textLabel.text = @"清除聊天记录";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
    }
    else if(indexPath.section == 2 && indexPath.row == 3) {
        cell.textLabel.text = @"群组禁言";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UISwitch *newSwitch = [UISwitch new];
        newSwitch.on = self.groupInfo.banState.boolValue;
        [newSwitch addTarget:self
                      action:@selector(touchBanAll:)
            forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = newSwitch;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0) {
        GroupMemberListViewController *vc = [[GroupMemberListViewController alloc] init];
        vc.groupid = self.groupId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.section == 1 && indexPath.row == 0) {
        GroupMemberData *curMember = [[GroupDataSource sharedInstance] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                                  groupid:self.groupId];
        if(curMember.isLord || curMember.isAdmin) {
            [[UniManager manager] selectImageWithLimit:1
                                                  type:PHAssetMediaTypeImage
                                        viewController:self
                                               squared:YES
                                                upload:YES
                                        withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                            if (success) {
                                                NSArray *arr = info[@"images"];
                                                [self updateGroupInfoWithName:nil
                                                                     portrait:arr.firstObject
                                                                 announcement:nil];
                                            }
                                        }];
        }
    }
    else if(indexPath.section == 1 && indexPath.row == 1) {
        GroupMemberData *curMember = [[GroupDataSource sharedInstance] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                                  groupid:self.groupId];
        if(curMember.isLord || curMember.isAdmin) {
            [[UniManager manager] startTextEdit:self.groupInfo.name
                                    placeholder:@"请输入群组名称"
                                      maxLength:12
                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                         if (success){
                                             [self updateGroupInfoWithName:info[@"text"]
                                                                  portrait:nil
                                                              announcement:nil];
                                         }
                                     }];
        }
    }
    else if(indexPath.section == 1 && indexPath.row == 2) {
        GroupMemberData *member = [[GroupDataSource sharedInstance] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                               groupid:self.groupId];
        GroupAnnounceViewController *vc = [[GroupAnnounceViewController alloc] init];
        vc.isAdmin = (member.isAdmin || member.isLord);
        vc.announcement = self.groupInfo.introduce;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.section == 1 && indexPath.row == 3) {
        MessageHistoryViewController *vc = [[MessageHistoryViewController alloc] init];
        vc.conversationType = ConversationType_GROUP;
        vc.targetid = self.groupId;
        vc.keywords = nil;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.section == 2 && indexPath.row == 0) {
        
    }
    else if(indexPath.section == 2 && indexPath.row == 1) {
        
    }
    else if(indexPath.section == 2 && indexPath.row == 2) {
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
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger num = [self.dataSource numberOfItems:self.fetchedResultsController
                                         inSection:section];
    if(!num) {
        return num;
    }
    
    if(!self.currentMember) {
        self.currentMember = [[GroupDataSource sharedInstance] groupMemberWithUserd:YUCLOUD_ACCOUNT_USERID
                                                                            groupid:self.groupId];
    }
    
    if(self.currentMember.isLord || self.currentMember.isAdmin) {
        return MIN(num+2, 19);
    }
    
    return MIN(num, 19);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[GroupMemberCell reuseIdentifier]
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(GroupMemberCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger total = [self collectionView:collectionView numberOfItemsInSection:0];
    
    if(self.currentMember.isLord || self.currentMember.isAdmin) {
        if(indexPath.item == total-1) {
            cell.functionImage = [UIImage imageNamed:@"ic_delete_member"];
        } else if(indexPath.item == total-2) {
            cell.functionImage = [UIImage imageNamed:@"ic_add_member"];
        } else {
            cell.groupMember = [self.dataSource groupMemberAtIndexPath:indexPath
                                                            controller:self.fetchedResultsController];
        }
    } else {
        cell.groupMember = [self.dataSource groupMemberAtIndexPath:indexPath
                                                        controller:self.fetchedResultsController];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(width/5.0, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger total = [self collectionView:collectionView numberOfItemsInSection:0];
    
    if(self.currentMember.isLord || self.currentMember.isAdmin) {
        // 删除群成员
        if(indexPath.item == total-1) {
            GroupMemberSelectViewController *vc = [[GroupMemberSelectViewController alloc] initWithGroupid:self.groupId];
            vc.delegate = self;
            vc.allowMulSelect = YES;
            vc.purpose = ContactSelectPurposeInviteGroupMember;
            [self presentViewController:[[MainNavigationController alloc] initWithRootViewController:vc]
                               animated:YES
                             completion:nil];
        }
        // 添加群成员
        else if(indexPath.item == total-2) {
            ContactsSelectViewController *vc = [[ContactsSelectViewController alloc] initWithPurpose:ContactSelectPurposeInviteGroupMember
                                                                                      allowMulSelect:YES
                                                                                            delegate:self
                                                                                             groupid:self.groupId];
            [self presentViewController:[[MainNavigationController alloc] initWithRootViewController:vc]
                               animated:YES
                             completion:nil];
        }
        else {
            GroupMemberData *data = [self.dataSource groupMemberAtIndexPath:indexPath controller:self.fetchedResultsController];
            ContactDetailViewController *vc = [[ContactDetailViewController alloc] initWithUserid:data.userid
                                                                                     user:nil
                                                                                  groupid:self.groupId];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        GroupMemberData *data = [self.dataSource groupMemberAtIndexPath:indexPath
                                                             controller:self.fetchedResultsController];
        ContactDetailViewController *vc = [[ContactDetailViewController alloc] initWithUserid:data.userid
                                                                                 user:nil
                                                                              groupid:self.groupId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - LYDataSourceDelegate

- (void)didChangeContent:(NSFetchedResultsController *)controller {
    [self refreshMembersView];
}

#pragma mark - ContactsSelectDelegate

- (void)selectWithContacts:(NSArray *)contacts
                   purpose:(ContactSelectPurpose)purpose
                 mulSelect:(BOOL)mulSelect {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    
    [[GroupManager manager] joinGroupWithGroupId:self.groupId
                                 groupMemberList:contacts
                                      completion:^(BOOL success, NSDictionary * _Nullable info) {
                                          if(success) {
                                              [self refreshGroupMembers];
                                              [self refreshGroupInfo];
                                          }
                                          
                                          [MBProgressHUD finishLoading:hud
                                                                result:success
                                                                  text:[info msg]
                                                            completion:nil];
                                      }];
}

#pragma mark - GroupMemberSelectDelegate

- (void)selectWithMembers:(NSArray *)contacts {
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    [[GroupManager manager] kickUsersByGroupId:self.groupId
                                       usersId:contacts
                                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                                        if(success) {
                                            [self refreshGroupMembers];
                                            [self refreshGroupInfo];
                                        }
                                        
                                        [MBProgressHUD finishLoading:hud
                                                              result:success
                                                                text:[info msg]
                                                          completion:nil];
                                    }];
}

#pragma mark - GroupAnnounceControllerDelegate

- (void)editGroupWithAnnouncement:(NSString *)announcement {
    [self updateGroupInfoWithName:nil
                         portrait:nil
                     announcement:announcement];
}

@end
