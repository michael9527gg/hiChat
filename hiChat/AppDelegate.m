//
//  AppDelegate.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "GuideViewController.h"
#import "UniManager.h"
#import "RCDataSource.h"
#import "RCCustomMessage.h"
#import <WXApi.h>
#import "VersionView.h"
#import "ConversationSettingDataSource.h"
#import "ReactiveWebViewController.h"
#import <SafariServices/SafariServices.h>
#import "NotificationDataSource.h"
#import "NotificationDetailViewController.h"
#import <sqlite3.h>
#import "NotificationView.h"

NSString *databaseKey       = @"1030";
NSString *defaultStartupKey = @"80808";

@interface AppDelegate () < GuideViewDelegate, RCIMConnectionStatusDelegate, RCIMReceiveMessageDelegate, UITabBarControllerDelegate >

@property (nonatomic, strong) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

@property (nonatomic, assign) BOOL                          rcAccountInitFlag;
@property (nonatomic, strong) NSDateFormatter               *formatter;

@end

@implementation AppDelegate

+ (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#if !defined(DEBUG) && !defined(ENV_DEV)
    [self setupBugly];
#endif //
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self themeInit];
    
    sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    
    [self initDataSource];
    
    // 先展示中间画面
    [self showLoginScreen:YES];
    
    [[AccountManager manager] addObserver:self
                               forKeyPath:ACCOUNT_STATUS_KEYPATH
                                  options:NSKeyValueObservingOptionNew
                                  context:nil];
    
    [self rongCloudInit];
    
    return YES;
}

- (void)initDataSource {
    [ContactsDataSource sharedClient];
    [UserDataSource sharedClient];
    [GroupDataSource sharedClient];
    [ConversationSettingDataSource sharedClient];
    [NotificationDataSource sharedClient];
}

- (void)themeInit {
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    if (@available(iOS 9.0, *)) {
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTintColor:[UIColor whiteColor]];
    }
    else {
        // Fallback on earlier versions
    }
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorFromHex:0x0099ff]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ic_navi_bg"]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTranslucent:NO];
}

- (void)showLoginScreen:(BOOL)withStartup {
    GuideViewController *guide = [[GuideViewController alloc] initWithMask:withStartup?GuideStartup:GuideLogin];
    guide.delegate = self;
    
    self.window.rootViewController = guide;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)rongCloudInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:RCKitDispatchMessageNotification
                                               object:nil];
    
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    
    [[RCIM sharedRCIM] registerMessageType:[RCCustomMessage class]];
    
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    
    [RCIM sharedRCIM].enableTypingStatus = YES;
    
    [RCIM sharedRCIM].enableSyncReadStatus = YES;
    
    [RCIM sharedRCIM].enableMessageMentioned = YES;
    
    [RCIM sharedRCIM].enableMessageRecall = YES;
    
    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    
    [RCIM sharedRCIM].userInfoDataSource = RCCDataSource;
    
    [RCIM sharedRCIM].groupInfoDataSource = RCCDataSource;
    
    [RCIM sharedRCIM].groupMemberDataSource = RCCDataSource;
    
    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Error;
    
    NSLog(@"RCIMClient version: %@", [[RCIMClient sharedRCIMClient] getSDKVersion]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:ACCOUNT_STATUS_KEYPATH]) {
        if ([[AccountManager manager] isServerSignin]) {
            
            [[ContactsManager manager] requestFriendBlackListWithCompletion:nil];
            
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge |
                                                                                                 UIUserNotificationTypeSound |
                                                                                                 UIUserNotificationTypeAlert)
                                                                                     categories:nil];
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            
            if(!self.rcAccountInitFlag) {
                [[RCIM sharedRCIM] initWithAppKey:[AccountManager manager].rcKey];
            }
            
            self.rcAccountInitFlag = NO;
            
            [[RCIM sharedRCIM] connectWithToken:[AccountManager manager].rcToken
                                        success:^(NSString *userId) {
                                            NSLog(@"融云登录成功 userId: %@", userId);
                                        }
                                          error:^(RCConnectErrorCode status) {
                                              NSLog(@"融云登录错误: %ld", (long)status);
                                          }
                                 tokenIncorrect:^{
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         NSLog(@"融云 token 错误");
                                         
                                         [YuAlertViewController showAlertWithTitle:@"严重错误"
                                                                           message:@"消息服务错误，请联系平台客服"
                                                                    viewController:[UniManager manager].topViewController
                                                                           okTitle:YUCLOUD_STRING_OK
                                                                          okAction:nil
                                                                       cancelTitle:nil
                                                                      cancelAction:nil
                                                                        completion:nil];
                                     });
                                 }];
        }
        else {
            [[RCIM sharedRCIM] disconnect:NO];
        }
    }
}

- (void)setupBugly {
    BuglyConfig * config = [[BuglyConfig alloc] init];
    
    // Open the customized log record and report, BuglyLogLevelWarn will report Warn, Error log message.
    // Default value is BuglyLogLevelSilent that means DISABLE it.
    // You could change the value according to you need.
    //    config.reportLogLevel = BuglyLogLevelWarn;
    
    // Open the STUCK scene data in MAIN thread record and report.
    // Default value is NO
    config.blockMonitorEnable = NO;
    
    // Set the STUCK THRESHOLD time, when STUCK time > THRESHOLD it will record an event and report data when the app launched next time.
    // Default value is 3.5 second.
    config.blockMonitorTimeout = 3.5;
    
#if APP_STORE
    config.channel = @"App Store";
#else
    config.channel = @"Enterprise";
#endif //
    
    config.consolelogEnable = NO;
    config.viewControllerTrackingEnable = NO;
    
    // NOTE:Required
    // Start the Bugly sdk with APP_ID and your config
    [Bugly startWithAppId:@"73ee2162f6"
        developmentDevice:NO
                   config:config];
    
    [Bugly setUserIdentifier:[NSString stringWithFormat:@"User: %@", [UIDevice currentDevice].name]];
    
    [Bugly setUserValue:[NSProcessInfo processInfo].processName forKey:@"Process"];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken deviceToken: %@", deviceToken);
    
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                                             withString:@""]
                        stringByReplacingOccurrencesOfString:@">"
                        withString:@""]
                       stringByReplacingOccurrencesOfString:@" "
                       withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationCacheDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    if (status != ConnectionStatus_SignUp) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),
                                                                             @(ConversationType_GROUP)]];
        NSInteger unreadNotificationCount = [[NotificationDataSource sharedClient] unReadNotificationsCount];
        application.applicationIconBadgeNumber = unreadMsgCount + unreadNotificationCount;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkVersion];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (void)checkVersion {
    NSDate *date = [NSUserDefaults checkVersionDate];
    if (date == nil || [date timeIntervalToNow] > 15 * 60) {
        // 15 分钟后检查
        [[AccountManager manager] requestVersionWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                NSString *force = YUCLOUD_VALIDATE_STRING(info[@"is_force"]);
                if (![NSUserDefaults versionShouldSkip:info[@"versionNum"]] || [force isEqualToString:@"2"]) {
                    [VersionView showVersionViewWithData:info];
                }
            }
        }];
    }
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [self accountHandleOpenUrl:url];
    
    NSURLComponents *comps = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    for (NSURLQueryItem *item in comps.queryItems) {
        if ([item.name isEqualToString:@"q"]) {
            [NSUserDefaults saveInvitationCode:item.value];
            break;
        }
    }
    
    return YES;
}

- (void)accountHandleOpenUrl:(NSURL *)url {
    NSString *string = url.absoluteString;
    if ([string containsString:WECHAT_APP_ID]) {
        [WXApi handleOpenURL:url delegate:[AccountManager manager]];
    }
}

#pragma mark - GuideViewDelegate

- (void)guideViewDidFinished:(GuideViewController *)viewController {
    self.window.backgroundColor = [UIColor whiteColor];
    MainTabBarController *tabController = [MainTabBarController new];
    tabController.delegate = self;
    self.window.rootViewController = tabController;
    [self.window makeKeyAndVisible];
}

#pragma mark - RCIMConnectionStatusDelegate

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    NSLog(@"Rong cloud status changed: %ld", (long)status);
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        [[AccountManager manager] logoutWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                [YuAlertViewController showAlertWithTitle:@"提示"
                                                  message:@"您的帐号在别的设备上登录，您被迫下线！"
                                           viewController:[UniManager manager].topViewController
                                                  okTitle:@"知道了"
                                                 okAction:^(UIAlertAction * _Nonnull action) {
                                                     [self showLoginScreen:NO];
                                                 }
                                              cancelTitle:nil
                                             cancelAction:nil
                                               completion:nil];
            }
        }];
    }
    else if (status == ConnectionStatus_DISCONN_EXCEPTION) {
        [[AccountManager manager] logoutWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                [YuAlertViewController showAlertWithTitle:@"提示"
                                                  message:@"账号异常，请重新登录！"
                                           viewController:[UniManager manager].topViewController
                                                  okTitle:@"知道了"
                                                 okAction:^(UIAlertAction * _Nonnull action) {
                                                     [self showLoginScreen:NO];
                                                 }
                                              cancelTitle:nil
                                             cancelAction:nil
                                               completion:nil];
            }
        }];
    }
    else if(status == ConnectionStatus_Connected) {
        NSLog(@"Rong cloud connect success !!!");
        
        // 防止单账号重复初始化
        if(!self.rcAccountInitFlag) {
            // 融云本地数据库连接成功之后才会打开
            [[RCManager manager] refreshDataForConversationListCompletion:nil];
            
            // 个人信息是异步获取的，这里要判断下
            if(YUCLOUD_ACCOUNT_NAME) {
                RCUserInfo *curUser = [[RCUserInfo alloc] initWithUserId:YUCLOUD_ACCOUNT_USERID
                                                                    name:YUCLOUD_ACCOUNT_NAME
                                                                portrait:YUCLOUD_ACCOUNT_PORTRAIT];
                [[RCIM sharedRCIM] setCurrentUserInfo:curUser];
            }
            
            self.rcAccountInitFlag = YES;
        }
    }
    else {
        
    }
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [NSDateFormatter new];
    }
    
    return _formatter;
}

#pragma mark - RCIMReceiveMessageDelegate

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - message.sentTime / 1000;
    NSString *string = [self.formatter shortTimeStringFromTimeInterval:interval];
    
    NSLog(@"New msg, type: %lu, sender: %@, targetId: %@, objectName: %@, left: %d, %@ 前发送的消息", (unsigned long)message.conversationType, message.senderUserId, message.targetId, message.objectName, left, string);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([message.content isKindOfClass:[RCCustomMessage class]]) {
            RCCustomMessage *custom = (RCCustomMessage *)message.content;
            NSLog(@"operation : %@", custom.operation);

            NSDictionary *data = custom.data;
            if ([custom.operation isEqualToString:@"UsersRefresh"]) {
                NSString *uid = YUCLOUD_VALIDATE_STRING(data[@"id"]);
                if (!uid.length) {
                    return;
                }
                ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:uid];
                if (contact) {
                    contact.nickname = data[@"nickname"];
                    contact.portraitUri = data[@"portraitUri"];
                    [[ContactsDataSource sharedClient] addObject:contact
                                                      entityName:[ContactEntity entityName]];

                    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:contact.uid
                                                                         name:contact.name
                                                                     portrait:contact.portraitUri];
                    [[UserManager manager] refreshRCUserInfoCacheWithUserid:nil
                                                                   userInfo:userInfo
                                                                 completion:nil];
                }
            }
            else if ([custom.operation isEqualToString:@"UsersAddblacklist"] ||
                     [custom.operation isEqualToString:@"UsersRemoveblacklist"]) {
                // 这里涉及到多端同步的问题，web端拉黑某好友，移动端要同步拉黑
                // 通知会发给被拉黑人和拉黑操作人，1.被拉黑人要立即检测会话能力，2.拉黑操作人要同步拉黑状态到数据库
                NSString *userid = YUCLOUD_VALIDATE_STRING(data[@"userid"]);
                if (!userid.length) {
                    return;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_UPDATE_BLACKLIST_NOTIFICATION
                                                                    object:nil
                                                                  userInfo:@{@"userid": userid}];
                [[ContactsManager manager] refreshFriendsListWithCompletion:nil];
                [[ContactsManager manager] requestFriendBlackListWithCompletion:nil];
            }
            else if([custom.operation isEqualToString:@"GroupsAddGagUser"] ||
                    [custom.operation isEqualToString:@"GroupsRollBackGagUser"]) {
                NSString *groupid = YUCLOUD_VALIDATE_STRING([data valueForKey:@"groupId"]);
                NSArray *userids = YUCLOUD_VALIDATE_ARRAY([data valueForKey:@"usersId"]);
                if(!userids) {
                    return;
                }
                NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:userids.count];
                for(id data in userids) {
                    if (YUCLOUD_VALIDATE_STRING(data)) {
                        [mulArr addObject:data];
                    }
                    else if (YUCLOUD_VALIDATE_NUMBER(data)) {
                        NSNumber *number = YUCLOUD_VALIDATE_NUMBER(data);
                        [mulArr addObject:number.stringValue];
                    }
                }

                if(groupid && userids.count) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_UPDATE_BLACKLIST_NOTIFICATION
                                                                        object:nil
                                                                      userInfo:@{@"groupid": groupid,
                                                                                 @"userids": mulArr}];
                    for(NSString *userid in mulArr) {
                        GroupMemberData *member = [[GroupDataSource sharedClient] groupMemberWithUserd:userid
                                                                                               groupid:groupid];
                        if(member) {
                            member.isgag = [custom.operation isEqualToString:@"GroupsAddGagUser"];
                            [[GroupDataSource sharedClient] addObject:member
                                                           entityName:[GroupMemberEntity entityName]];
                        }
                    }
                }
            }
            else if([custom.operation isEqualToString:@"FriendshipUpdatedisplayName"]) {
                id dataT = data[@"friendid"];
                NSString *friendid = nil;
                if (YUCLOUD_VALIDATE_STRING(dataT)) {
                    friendid = YUCLOUD_VALIDATE_STRING(dataT);
                }
                else if (YUCLOUD_VALIDATE_NUMBER(dataT)) {
                    NSNumber *number = YUCLOUD_VALIDATE_NUMBER(dataT);
                    friendid = number.stringValue;
                }
                if (!friendid.length) {
                    return;
                }
                NSString *displayName = data[@"displayname"];
                ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:friendid];
                if(contact) {
                    contact.displayName = displayName;
                    [[ContactsDataSource sharedClient] addObject:contact entityName:[ContactEntity entityName]];
                    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:contact.uid
                                                                         name:contact.name
                                                                     portrait:contact.portraitUri];
                    [[UserManager manager] refreshRCUserInfoCacheWithUserid:nil
                                                                   userInfo:userInfo
                                                                 completion:nil];
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_UPDATE_DISPALYNAME_NOTIFICATION
                                                                    object:nil
                                                                  userInfo:@{@"userid" : friendid,
                                                                             @"displayName" : displayName}];
            }
            else if([custom.operation isEqualToString:@"FriendshipRemoveFriend"]) {
                NSString *userid = YUCLOUD_VALIDATE_STRING(data[@"userid"]);
                if(!userid.length) {
                    return;
                }
                ContactData *contact = [[ContactsDataSource sharedClient] contactWithUserid:userid];
                if(contact) {
                    [[ContactsDataSource sharedClient] deleteObject:contact];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_UPDATE_FRIEND_NOTIFICATION
                                                                    object:nil
                                                                  userInfo:@{@"userid": userid}];
            }
            else if([custom.operation isEqualToString:@"GroupBanSetBan"]) {
                NSString *groupId = YUCLOUD_VALIDATE_STRING(data[@"groupId"]);
                NSNumber *stat = YUCLOUD_VALIDATE_NUMBER(data[@"stat"]);

                GroupData *data = [[GroupDataSource sharedClient] groupWithGroupid:groupId];
                if(data) {
                    data.banState = stat.stringValue;
                    [[GroupDataSource sharedClient] addObject:data
                                                   entityName:[GroupEntity entityName]];
                }
            }
            else if([custom.operation isEqualToString:@"AppNotification"]) {
                NotificationData *notification = [NotificationData notificationWithData:data];
                if(notification.alert) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [NotificationView show:notification];
                    });
                }
                [[NotificationDataSource sharedClient] addObject:notification
                                                      entityName:[NotificationEntity entityName]];
            }
            else if ([custom.operation isEqualToString:@"KickOut"]) {
                NSDate *lastPassLoginDate = [NSUserDefaults lastPassLoginDate];
                NSDate *sentDate = [NSDate dateWithTimeIntervalSince1970:message.sentTime / 1000];
                if (!lastPassLoginDate || [lastPassLoginDate compare:sentDate] == NSOrderedAscending) {
                    [[AccountManager manager] logoutWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                        if (success) {
                            [NSUserDefaults saveToken:nil];
                        }
                        
                        [YuAlertViewController showAlertWithTitle:nil
                                                          message:@"请重新登录"
                                                   viewController:[UniManager manager].topViewController
                                                          okTitle:YUCLOUD_STRING_OK
                                                         okAction:^(UIAlertAction * _Nonnull action) {
                                                             [self showLoginScreen:NO];
                                                         }
                                                      cancelTitle:nil
                                                     cancelAction:nil
                                                       completion:nil];
                    }];
                }
            }
        }
        else if([message.content isKindOfClass:[RCGroupNotificationMessage class]]) {
            RCGroupNotificationMessage *gnMessage = (RCGroupNotificationMessage *)message.content;

            NSLog(@"%@", gnMessage.operation);
            // 群组创建会有小灰条通知
            if([gnMessage.operation isEqualToString:@"Create"]) {

            }
            else if(([gnMessage.operation isEqualToString:@"Rename"])) {
                [[GroupManager manager] refreshRCGroupInfoCacheWithGroupid:message.targetId];
            }
            else if(([gnMessage.operation isEqualToString:@"Add"] ||
                     [gnMessage.operation isEqualToString:@"Kicked"] ||
                     [gnMessage.operation isEqualToString:@"Quit"])) {
                NSString *groupId = gnMessage.extra;
                if(groupId) {
                    // 只刷新当前会话页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_UPDATE_MEMBERSLIST_NOTIFICATION
                                                                        object:nil
                                                                      userInfo:@{@"groupId": groupId}];
                }
                if([gnMessage.operatorUserId isEqualToString:YUCLOUD_ACCOUNT_USERID] &&
                   [gnMessage.operation isEqualToString:@"Quit"]) {
                    GroupData *group = [[GroupDataSource sharedClient] groupWithGroupid:groupId];
                    if(group) {
                        [[GroupDataSource sharedClient] deleteObject:group];
                    }
                }
            }
            else if(([gnMessage.operation isEqualToString:@"Dismiss"])) {
                [[RCManager manager] removeConversation:ConversationType_GROUP
                                               targetId:message.targetId];
            }
        }
        else if([message.content isKindOfClass:[RCContactNotificationMessage class]]) {
            RCContactNotificationMessage *cnMessage = (RCContactNotificationMessage *)message.content;

            if ([cnMessage.operation isEqualToString:@"Request"]) {
                // 检查好友请求是不是已经在别的端被接受，不能从数据库查询，会有延时
                [[ContactsManager manager] checkFriendRelationBetweenUser:cnMessage.sourceUserId
                                                               completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                                   if(!success) {
                                                                       [[ContactsManager manager] increaseUnreadFriendRequstMessageCount];
                                                                   }
                                                               }];
            } else if ([cnMessage.operation isEqualToString:@"AcceptResponse"]) {
                [[ContactsManager manager] refreshFriendsListWithCompletion:nil];
            } else if ([cnMessage.operation isEqualToString:@"RejectResponse"]) {
                // 拒绝不用管
            }
        }
    });
}

// 当App处于前台时，接收到消息并播放提示音的回调方法
- (BOOL)onRCIMCustomAlertSound:(RCMessage *)message {
    // 屏蔽自定义消息的提示
    if([message.content isKindOfClass:[RCCustomMessage class]]) {
        RCCustomMessage *custom = (RCCustomMessage *)message.content;
        if(![custom.operation isEqualToString:@"AppNotification"]) {
            return YES;
        }
    }
    
    return NO;
}

// 当App处于后台时，接收到消息并弹出本地通知的回调方法
- (BOOL)onRCIMCustomLocalNotification:(RCMessage *)message
                       withSenderName:(NSString *)senderName {
    // 屏蔽自定义消息的提示
    if([message.content isKindOfClass:[RCCustomMessage class]]) {
        RCCustomMessage *custom = (RCCustomMessage *)message.content;
        if(![custom.operation isEqualToString:@"AppNotification"]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)interceptMessage:(RCMessage *)message {
    return NO;
}

#pragma mark - RCKitDispatchMessageNotification

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    NSNumber *left = [notification.userInfo objectForKey:@"left"];
    if ([RCIMClient sharedRCIMClient].sdkRunningMode == RCSDKRunningMode_Background && 0 == left.integerValue) {
        dispatch_async(dispatch_get_main_queue(),^{
            int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),
                                                                                 @(ConversationType_GROUP)]];
            NSInteger unreadNotificationCount = [[NotificationDataSource sharedClient] unReadNotificationsCount];
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadMsgCount + unreadNotificationCount;
        });
    }
}

#pragma mark - Core Data

- (NSURL *)storeUrl {
#if ENV_DEV
    NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"data_dev.sqlite"];
#else
    NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"data.sqlite"];
#endif
    
    NSLog(@"Data base location: %@", url);
    return url;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSManagedObjectModel *model = [self managedObjectModel];
        NSDictionary *hashs = model.entityVersionHashesByName;
        NSUInteger hash = 0;
        for (NSData *item in hashs.objectEnumerator) {
            NSString *md5 = [item MD5];
            hash += md5.hash;
        }
        
        hash += databaseKey.hash;
        
        if ([NSUserDefaults databaseHash] != hash) {
            [[NSFileManager defaultManager] removeItemAtURL:[self storeUrl] error:nil];
            [NSUserDefaults saveDatabaseHash:hash];
        }
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSError *error;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeUrl] options:nil error:&error]) {
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(MainTabBarController *)tabBarController shouldSelectViewController:(MainNavigationController *)nav {
    if ([[nav.topViewController class] isEqual:[UIViewController class]]) {
        [[AccountManager manager] requestPlatformInfoWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            NSURL *url = [AccountManager manager].accountInfo.platformUrl;
            if (success) {
                NSString *string = info[@"platform_url"];
                
                string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (string.length > 0) {
                    if (![string containsString:@"http://"] && ![string containsString:@"https://"]) {
                        string = [@"http://" stringByAppendingString:string];
                    }
                    
                    url = [NSURL URLWithString:string];
                }
            }
            
            if (url) {
                if (@available(iOS 9.0, *)) {
                    SFSafariViewController *web = [[SFSafariViewController alloc] initWithURL:url];
                    
                    [[UniManager manager].topViewController presentViewController:web
                                                                         animated:YES
                                                                       completion:nil];
                }
                else {
                    ReactiveWebViewController *web = [[ReactiveWebViewController alloc] initWithUrl:url];
                    
                    MainNavigationController *current = (MainNavigationController *)tabBarController.selectedViewController;
                    [current pushViewController:web animated:YES];
                }
            }
        }];
        
        return NO;
    }
    
    return YES;
}

@end
