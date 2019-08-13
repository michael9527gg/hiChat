//
//  GuidePageViewController.h
//  Kaixin
//
//

#import <UIKit/UIKit.h>
#import "YuTextField.h"

@protocol GuidePageViewControllerDelegate < NSObject >

- (void)loginWithResult:(BOOL)success;

- (void)continueWithCurrent:(UIViewController *)viewController;

- (void)showSignup;

- (void)showLogin:(NSString *)phone;

- (void)showReset;

- (void)showBind:(NSDictionary *)info;

- (void)loginSuccess;

@end

@interface GuidePageViewController : UIViewController

@property (nonatomic, weak) id<GuidePageViewControllerDelegate>     delegate;

- (void)touchContinue;

@end
