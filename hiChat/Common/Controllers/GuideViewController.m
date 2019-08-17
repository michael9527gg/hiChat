//
//  GuideViewController.m
//  Kaixin
//
//

#import "GuideViewController.h"
#import "StartupPageViewController.h"
#import "LoginPageViewController.h"
#import "SignupViewController.h"
#import "ResetPasswordViewController.h"
#import "UniManager.h"
#import "FillInfoViewController.h"
#import "VideoPlayerView.h"

extern NSString *defaultStartupKey;

@interface GuideViewController () < UIPageViewControllerDataSource, UIPageViewControllerDelegate, GuidePageViewControllerDelegate, LoginPageViewControllerDelgate >

@property (nonatomic, strong) UIPageViewController      *pageViewController;
@property (nonatomic, strong) NSMutableArray            *arrPages;

@property (nonatomic, assign) NSUInteger                guideMask;

@end

@implementation GuideViewController

- (instancetype)initWithMask:(NSUInteger)guideMask {
    if (self = [self init]) {
        self.guideMask = guideMask;
    }
    
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    
    if (self.guideMask == GuideStartup) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [UIImage imageNamed:@"loading_iOS.png"];
        [view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.guideMask == GuideStartup) {
        [[AccountManager manager] startAutoLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                [self loginSuccess];
            }
            else {
                [self prepairGuideViews];
            }
        }];
    }
    else {
        [self prepairGuideViews];
    }
}

- (void)prepairGuideViews {
    StartupPageViewController *start = [StartupPageViewController new];
    start.delegate = self;
    
    self.arrPages = [NSMutableArray array];
    
//    if ([NSUserDefaults firstTimeStartup] && (self.guideMask & GuideOpening)) {
//        [self.arrPages addObject:start];
//    }
    
    if (![[AccountManager manager] isServerSignin] && (self.guideMask & GuideLogin)) {
        LoginPageViewController *login = [LoginPageViewController new];
        login.delegate = self;
        login.loginDelegate = self;
        [self.arrPages addObject:login];
        
        ResetPasswordViewController *reset = [ResetPasswordViewController new];
        MainNavigationController *resetNavi = [[MainNavigationController alloc] initWithRootViewController:reset];
        reset.delegate = self;
        [self.arrPages addObject:resetNavi];
        
        SignupViewController *signup = [SignupViewController new];
        MainNavigationController *signupNavi = [[MainNavigationController alloc] initWithRootViewController:signup];
        signup.delegate = self;
        [self.arrPages addObject:signupNavi];
        
        FillInfoViewController *bind = [[FillInfoViewController alloc] init];
        MainNavigationController *bindNavi = [[MainNavigationController alloc] initWithRootViewController:bind];
        bind.delegate = self;
        [self.arrPages addObject:bindNavi];
    }
    
    if (self.arrPages.count == 0) {
        [self hideAnimated:YES];
        return;
    }
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    [self.pageViewController setViewControllers:@[self.arrPages.firstObject]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            scrollView.scrollEnabled = NO;
        }
    }
    
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)hideAnimated:(BOOL)animated {
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideViewDidFinished:)]) {
        [self.delegate guideViewDidFinished:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIPageViewControllerDataSource, UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.arrPages indexOfObject:viewController];
    if (index != NSNotFound && index > 0) {
        return self.arrPages[index - 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.arrPages indexOfObject:viewController];
    if (index != NSNotFound && index < self.arrPages.count - 1) {
        return self.arrPages[index + 1];
    }
    
    return nil;
}

#pragma mark - GuidePageViewControllerDelegate

- (void)loginWithResult:(BOOL)success {
    if ([self.delegate respondsToSelector:@selector(loginWithResult:)]) {
        [self.delegate loginWithResult:success];
    }
}

- (void)continueWithCurrent:(UIViewController *)viewController {
    NSUInteger index = [self.arrPages indexOfObject:viewController];
    if (index != NSNotFound) {
        index++;
        
        if (index < self.arrPages.count) {
            UIViewController *next = self.arrPages[index];
            if (next) {
                [self.pageViewController setViewControllers:@[next]
                                                  direction:UIPageViewControllerNavigationDirectionForward
                                                   animated:NO
                                                 completion:nil];
                
                return;
            }
        }
    }
    
    [self hideAnimated:YES];
}

- (void)skipWithCurrent:(UIViewController *)viewController {
    NSUInteger index = [self.arrPages indexOfObject:viewController];
    if (index != NSNotFound) {
        index++;
        
        if (index < self.arrPages.count) {
            UIViewController *next = self.arrPages[index];
            if (next) {
                [self.pageViewController setViewControllers:@[next]
                                                  direction:UIPageViewControllerNavigationDirectionForward
                                                   animated:YES completion:nil];
                
                return;
            }
        }
    }
    
    [self hideAnimated:YES];
}

- (void)showSignup {
    [self showViewOfClass:[SignupViewController class]];
}

- (void)showLogin:(NSString *)phone {
    LoginPageViewController *login = (LoginPageViewController *)[self showViewOfClass:[LoginPageViewController class]];
    login.phone = phone;
}

- (void)showReset {
    [self showViewOfClass:[ResetPasswordViewController class]];
}

- (void)showBind:(NSDictionary *)info {
    FillInfoViewController *fill = [self showViewOfClass:[FillInfoViewController class]];
    fill.accessToken = info[@"access_token"];
}

- (__kindof GuidePageViewController *)showViewOfClass:(Class)class {
    for (UIViewController *item in self.arrPages) {
        
        UIViewController *desItem = item;
        if([item isKindOfClass:[UINavigationController class]]) {
            desItem = ((UINavigationController *)item).topViewController;
        }
        
        if ([desItem isKindOfClass:class]) {
            [item viewWillAppear:YES];
            
            [self.pageViewController setViewControllers:@[item]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:nil];
            
            [item viewDidAppear:YES];
            
            return (GuidePageViewController *)desItem;
        }
    }
    
    return nil;
}

- (void)loginSuccess {
    [self.delegate guideViewDidFinished:self];
}

#pragma mark - LoginPageViewControllerDelegate

- (void)showAgree {
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
