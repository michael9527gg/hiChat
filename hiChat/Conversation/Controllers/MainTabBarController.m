//
//  MainTabBarController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "MainTabBarController.h"
#import "ConversationListViewController.h"
#import "ContactsViewController.h"
#import "MeViewController.h"
#import "MainNavigationController.h"
#import "ReactiveWebViewController.h"
#import "NotificationDataSource.h"

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUnreadMessage)
                                                 name:CONTACT_UNREAD_FRIENDREQUEST_NOTIFICATION
                                               object:nil];
    
    [self addChildViewController:[self addViewController:[ConversationListViewController new]
                                                   title:@"聊天"
                                                   image:[UIImage imageNamed:@"ic_tab_chat"]
                                           selectedImage:[UIImage imageNamed:@"ic_tab_chat_selected"]]];
    
    [self addChildViewController:[self addViewController:[ContactsViewController new]
                                                   title:@"好友"
                                                   image:[UIImage imageNamed:@"ic_tab_contact"]
                                           selectedImage:[UIImage imageNamed:@"ic_tab_contact_selected"]]];
    
    if ([AccountManager manager].accountInfo.platformUrl) {
        [self addChildViewController:[self addViewController:[UIViewController new]
                                                       title:@"发现"
                                                       image:[UIImage imageNamed:@"ic_tab_explore"]
                                               selectedImage:[UIImage imageNamed:@"ic_tab_explore"]]];
    }
    
    [self addChildViewController:[self addViewController:[MeViewController new]
                                                   title:@"我"
                                                   image:[UIImage imageNamed:@"ic_tab_me_selected"]
                                           selectedImage:[UIImage imageNamed:@"ic_tab_me"]]];
    
//    NSString *url = @"https://kxl-001.oss-cn-beijing.aliyuncs.com/kxl/%E6%88%AA%E5%B1%8F2019-08-19%E4%B8%8B%E5%8D%883.53.43.png";
//    [[AFHTTPSessionManager manager] HEAD:url
//                              parameters:nil
//                                 success:^(NSURLSessionDataTask * _Nonnull task) {
//
//                                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                     if ([AccountManager manager].accountInfo.platformUrl) {
//                                         NSMutableArray *mulArray = self.viewControllers.mutableCopy;
//
//                                         MainNavigationController *navi = [self addViewController:[UIViewController new]
//                                                                                            title:@"发现"
//                                                                                            image:[UIImage imageNamed:@"ic_tab_explore"]
//                                                                                    selectedImage:[UIImage imageNamed:@"ic_tab_explore"]];
//
//                                         [mulArray insertObject:navi atIndex:2];
//
//                                         self.viewControllers = mulArray;
//                                     }
//                                 }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refreshUnreadMessage];
}

- (MainNavigationController *)addViewController:(UIViewController *)viewController
                                          title:(NSString *)title
                                          image:(UIImage *)image
                                  selectedImage:(UIImage *)selectedImage {
    
    MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:viewController];
    
    if (!selectedImage) {
        selectedImage = image;
    }
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                   image:image
                                           selectedImage:selectedImage];
    
    viewController.title = title;
    
    return nav;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSInteger index = [tabBar.items indexOfObject:item];
    
    if(1 == index) {
        [item setBadgeValue:nil];
    }
}

- (void)refreshUnreadMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger unreadCount = [NSUserDefaults unreadFriendRequstMessageCount];
        UIViewController *desController = self.viewControllers[1];
        UITabBarItem *desItem = desController.tabBarItem;
        if(self.selectedIndex != 1 && unreadCount) {
            if(unreadCount > 99) {
                [desItem setBadgeValue:@"99+"];
            } else {
                [desItem setBadgeValue:@(unreadCount).stringValue];
            }
        }
        
        unreadCount = [[NotificationDataSource sharedInstance] unReadNotificationsCount];
        desController = self.viewControllers.lastObject;
        desItem = desController.tabBarItem;
        if(unreadCount) {
            if(unreadCount > 99) {
                [desItem setBadgeValue:@"99+"];
            } else {
                [desItem setBadgeValue:@(unreadCount).stringValue];
            }
        } else {
            [desItem setBadgeValue:nil];
        }
    });
}

@end
