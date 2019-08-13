//
//  MainNavigationController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "MainNavigationController.h"

@implementation MainNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if(self.viewControllers.count >= 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:nil];
    [super pushViewController:viewController animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
