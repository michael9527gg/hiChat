//
//  MBProgressHUD+GF.m
//  GFCocoaTools
//
//  Created by zhangliyong on 2017/3/14.
//  Copyright © 2017年 zhangliyong@gmail.com. All rights reserved.
//

#import "MBProgressHUD+GF.h"
#import "NSBundle+GF.h"

@implementation MBProgressHUD (GF)

+ (MBProgressHUD *)showHudOn:(UIView *)view
                        mode:(MBProgressHUDMode)mode
                       image:(UIImage *)image
                     message:(NSString *)message
                   delayHide:(BOOL)delayHide
                  completion:(void (^)(void))completionBlock {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (image) {
        [hud setMode:MBProgressHUDModeCustomView];
        [hud setCustomView:[[UIImageView alloc] initWithImage:image]];
    }
    else {
        [hud setMode:mode];
    }
    hud.label.text = message;
    
    if (delayHide) {
        [hud hideAnimated:YES afterDelay:PROGRESS_DELAY_HIDE];
    }
    
    hud.completionBlock = completionBlock;
    
    return hud;
}

+ (MBProgressHUD *)showFinishHudOn:(UIView *)view
                        withResult:(BOOL)success
                         labelText:(NSString *)labelText
                         delayHide:(BOOL)delayHide
                        completion:(void (^)(void))completionBlock {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    UIImage *image = success?[UIImage imageNamed:@"ic_hud_success"]:[UIImage imageNamed:@"ic_hud_fail"];
    [hud setMode:MBProgressHUDModeCustomView];
    [hud setCustomView:[[UIImageView alloc] initWithImage:image]];
    
    NSString *message = labelText;
    if (!message) {
        message = success?@"成功":@"失败";
    }
    hud.label.text = message;
    
    if (delayHide) {
        [hud hideAnimated:YES afterDelay:PROGRESS_DELAY_HIDE];
    }
    
    hud.completionBlock = completionBlock;
    
    return hud;
}

+ (void)finishHudWithResult:(BOOL)success
                        hud:(MBProgressHUD *)hud
                  labelText:(NSString *)labelText
                 completion:(void (^)(void))completionBlock {
    if (success) {
        [hud setMode:MBProgressHUDModeCustomView];
        [hud setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_hud_success"]]];
        hud.label.text = labelText?:@"成功";
    }
    else {
        [hud setMode:MBProgressHUDModeCustomView];
        [hud setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_hud_fail"]]];
        hud.label.text = labelText?:@"失败";
    }
    [hud hideAnimated:YES afterDelay:PROGRESS_DELAY_HIDE];
    [hud setCompletionBlock:completionBlock];
}

@end
