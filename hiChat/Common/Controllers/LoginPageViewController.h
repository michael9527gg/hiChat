//
//  LoginPageViewController.h
//  Kaixin
//
//

#import "GuidePageViewController.h"

@protocol LoginPageViewControllerDelgate <NSObject>

- (void)showAgree;

@end

@interface LoginPageViewController : GuidePageViewController

@property (nonatomic, assign) id <LoginPageViewControllerDelgate> loginDelegate;

@property (nonatomic, copy)   NSString      *phone;

@end
