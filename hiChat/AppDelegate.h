//
//  AppDelegate.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UniManager.h"
#import "AccountManager.h"
#import <Bugly/Bugly.h>

#define APP_DELEGATE_WINDOW         [AppDelegate appDelegate].window

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (AppDelegate *)appDelegate;

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;

- (NSURL *)applicationCacheDirectory;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (NSManagedObjectContext *)managedObjectContext;

- (void)showLoginScreen:(BOOL)withStartup;

@end

