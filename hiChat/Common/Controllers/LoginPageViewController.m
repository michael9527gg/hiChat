//
//  LoginPageViewController.m
//  Kaixin
//
//

#import "LoginPageViewController.h"
#import "UniManager.h"
#import "AccountManager.h"
#import "AppDelegate.h"
#import "TSAuthViewController.h"
#import "VersionView.h"

@interface LoginPageViewController () < TSAuthViewControllerDelegate >

@property (nonatomic, strong) YuTextField       *phoneView;
@property (nonatomic, strong) YuTextField       *codeView;
@property (nonatomic, strong) UIButton          *btnLogin;
@property (nonatomic, strong) UIButton          *wechatBtn;

@property (nonatomic, copy)   NSString          *auth2stepToken;

@end

@implementation LoginPageViewController

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_login_bg"]];
    imageView.userInteractionEnabled = YES;
    [view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    UIImageView *centerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_login_center"]];
    centerView.contentMode = UIViewContentModeScaleAspectFill;
    centerView.userInteractionEnabled = YES;
    [view addSubview:centerView];
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view).offset(-24);
        make.centerX.equalTo(view);
        make.width.equalTo(view).multipliedBy(.8);
        make.height.equalTo(view).multipliedBy(9.0/16.0);
    }];
    
    self.phoneView = [YuTextField new];
    self.phoneView.placeholder = @"输入手机号";
    self.phoneView.text = [NSUserDefaults phone];
    self.phoneView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.phoneView.layer.cornerRadius = 24;
    self.phoneView.layer.borderWidth = .5;
    [self.phoneView setLeftImage:[[UIImage imageNamed:@"ic_login_user"] imageResized:20]
                         padding:0
                            mode:UITextFieldViewModeAlways];
    self.phoneView.keyboardType = UIKeyboardTypeNumberPad;
    [self.phoneView addTarget:self
                       action:@selector(textFieldChanged)
             forControlEvents:UIControlEventEditingChanged];
    [centerView addSubview:self.phoneView];
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(centerView).offset(-44);
        make.centerX.equalTo(centerView);
        make.width.equalTo(centerView).multipliedBy(.8);
        make.height.equalTo(@49);
    }];
    
    self.codeView = [YuTextField new];
    self.codeView.placeholder = @"输入密码";
    self.codeView.secureTextEntry = YES;
    self.codeView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.codeView.layer.cornerRadius = 24;
    self.codeView.layer.borderWidth = .5;
    [self.codeView setLeftImage:[[UIImage imageNamed:@"ic_login_pass"] imageResized:20]
                        padding:0
                           mode:UITextFieldViewModeAlways];
    [self.codeView addTarget:self
                      action:@selector(textFieldChanged)
            forControlEvents:UIControlEventEditingChanged];
    [centerView addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneView.mas_bottom).offset(8);
        make.centerX.equalTo(centerView);
        make.width.equalTo(centerView).multipliedBy(.8);
        make.height.equalTo(@49);
    }];
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"ic_login_login"];
    [btnLogin setBackgroundImage:[image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2]
                        forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [btnLogin addTarget:self
                 action:@selector(touchLogin)
       forControlEvents:UIControlEventTouchUpInside];
    btnLogin.enabled = NO;
    [centerView addSubview:btnLogin];
    self.btnLogin = btnLogin;
    [btnLogin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codeView.mas_bottom).offset(16);
        make.centerX.equalTo(centerView);
        make.width.equalTo(centerView).multipliedBy(.8);
        make.height.equalTo(@49);
    }];
    
    UIButton *btnSignup = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignup setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnSignup setTitle:@"注册账号" forState:UIControlStateNormal];
    [btnSignup setTitleColor:[UIColor colorFromString:@"0x37c4ff"]
                    forState:UIControlStateNormal];
    btnSignup.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnSignup addTarget:self
                  action:@selector(touchSignup)
        forControlEvents:UIControlEventTouchUpInside];
    
    [centerView addSubview:btnSignup];
    [btnSignup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnLogin);
        make.top.equalTo(btnLogin.mas_bottom).offset(24);
    }];
    
    UIButton *btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnReset setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnReset setTitle:@"找回密码" forState:UIControlStateNormal];
    [btnReset setTitleColor:[UIColor colorFromString:@"0x37c4ff"]
                   forState:UIControlStateNormal];
    btnReset.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnReset addTarget:self
                 action:@selector(touchReset)
       forControlEvents:UIControlEventTouchUpInside];
    
    [centerView addSubview:btnReset];
    [btnReset mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btnLogin);
        make.top.equalTo(btnLogin.mas_bottom).offset(24);
    }];
    
    if([WXApi isWXAppInstalled]) {
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_login_third_line"]];
        line.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view);
            make.top.equalTo(centerView.mas_bottom).offset(44);
            make.height.equalTo(@13);
            make.width.equalTo(view).multipliedBy(.8);
        }];
        
        self.wechatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.wechatBtn setBackgroundImage:[UIImage imageNamed:@"ic_wechat"]
                                  forState:UIControlStateNormal];
        [self.wechatBtn addTarget:self
                           action:@selector(touchWeChatLogin)
                 forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:self.wechatBtn];
        [self.wechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line.mas_bottom).offset(32);
            make.centerX.equalTo(view);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
    }

    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchWeChatLogin {
    [[AccountManager manager] showWechatAuthWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        if (success) {
            MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
            [[AccountManager manager] loginWithPhone:nil
                                                pass:nil
                                               token:nil
                                                code:info[@"code"]
                                          completion:^(BOOL success, NSDictionary * _Nullable info) {
                                              if (success) {
                                                  [MBProgressHUD finishLoading:hud
                                                                        result:success
                                                                          text:[info msg]
                                                                    completion:^{
                                                                        [self.delegate loginSuccess];
                                                                    }];
                                              }
                                              else {
                                                  NSNumber *code = info[@"code"];
                                                  if (code.integerValue == 201) {
                                                      [hud hideAnimated:YES];
                                                      
                                                      // 需要完善信息
                                                      [self.delegate showBind:info];
                                                  }
                                                  else if (info.code == 666) {
                                                      // 需要两步验证
                                                      [hud hideAnimated:NO];
                                                      NSDictionary *result = info[@"result"];
                                                      self.auth2stepToken = result[@"auth2stepToken"];
                                                      
                                                      TSAuthViewController *ts = [[TSAuthViewController alloc] initWithMsg:info[@"msg"]];
                                                      ts.delegate = self;
                                                      [ts popupOnViewController:self
                                                                   cornerRadius:8
                                                                transitionStyle:STPopupTransitionStyleSlideVertical
                                                                          style:STPopupStyleFormSheet
                                                                     completion:nil];
                                                  }
                                                  else {
                                                      // 未知错误
                                                      [MBProgressHUD finishLoading:hud
                                                                            result:success
                                                                              text:[info msg]
                                                                        completion:nil];
                                                  }
                                              }
                                          }];
        }
        else {
            [YuAlertViewController showAlertWithTitle:nil
                                              message:@"微信授权失败"
                                       viewController:self
                                              okTitle:YUCLOUD_STRING_OK
                                             okAction:nil
                                          cancelTitle:nil
                                         cancelAction:nil
                                           completion:nil];
        }
    }];
}

- (void)setPhone:(NSString *)phone {
    self.phoneView.text = phone;
    
    [NSUserDefaults savePhone:phone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchAgree {
    if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(showAgree)]) {
        [self.loginDelegate showAgree];
    }
}

- (void)touchLogin {
    [self.view endEditing:YES];
    
    NSString *phone = self.phoneView.text;
    if (![phone isValidPhoneNumber]) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"请输入11位手机号码"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             [self.phoneView becomeFirstResponder];
                                         }
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
        
        return;
    }
    
    NSString *pass = self.codeView.text;
    if (pass.length == 0) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"请输入密码"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             [self.codeView becomeFirstResponder];
                                         }
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
        return;
    }
    
    [NSUserDefaults saveLastPassLoginDate:[NSDate date]];
    
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    
    [[AccountManager manager] loginWithPhone:phone
                                        pass:pass
                                       token:nil
                                        code:nil
                                  completion:^(BOOL success, NSDictionary * _Nullable info) {
                                      if (success) {
                                          [MBProgressHUD finishLoading:hud
                                                                result:success
                                                                  text:[info msg]
                                                            completion:^{
                                                                [self.delegate loginSuccess];
                                                            }];
                                      }
                                      else if (info.code == 666) {
                                          // 需要两步验证
                                          [hud hideAnimated:NO];
                                          NSDictionary *result = info[@"result"];
                                          self.auth2stepToken = result[@"auth2stepToken"];
                                          
                                          TSAuthViewController *ts = [[TSAuthViewController alloc] initWithMsg:info[@"msg"]];
                                          ts.delegate = self;
                                          [ts popupOnViewController:self
                                                       cornerRadius:8
                                                    transitionStyle:STPopupTransitionStyleSlideVertical
                                                              style:STPopupStyleFormSheet
                                                         completion:nil];
                                      }
                                      else if (info.code == 6000) {
                                          // 版本太低，提示更新版本
                                          [[AccountManager manager] requestVersionWithCompletion:^(BOOL success, NSDictionary * _Nullable info2) {
                                              [hud hideAnimated:NO];
                                              if (success) {
                                                  [VersionView showVersionViewWithData:info2];
                                              }
                                              else {
                                                  [YuAlertViewController showAlertWithTitle:nil
                                                                                    message:info.msg
                                                                             viewController:self
                                                                                    okTitle:YUCLOUD_STRING_OK
                                                                                   okAction:nil
                                                                                cancelTitle:nil
                                                                               cancelAction:nil
                                                                                 completion:nil];
                                              }
                                          }];
                                      }
                                      else {
                                          [MBProgressHUD finishLoading:hud
                                                                result:success
                                                                  text:[info msg]
                                                            completion:nil];
                                      }
                                  }];
}

- (void)textFieldChanged {
    if ((self.phoneView.text.length == 11) && self.codeView.text.length) {
        self.btnLogin.enabled = YES;
    }
    else {
        self.btnLogin.enabled = NO;
    }
}

- (void)touchSignup {
    [self.delegate showSignup];
}

- (void)touchReset {
    [self.delegate showReset];
}

#pragma mark - TSAuthViewControllerDelegate

- (void)authViewControllerDidCancel:(TSAuthViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)authViewController:(TSAuthViewController *)viewController didFinishWithText:(NSString *)text {
    if (text.length == 6) {
        // 开始校验
        MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
        
        [[AccountManager manager] twoStepVerify:self.auth2stepToken
                                           code:text
                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                         [MBProgressHUD finishLoading:hud
                                                               result:success
                                                                 text:[info msg]
                                                           completion:^{
                                                               if (success) {
                                                                   [viewController hidePopup:YES completion:^{
                                                                       [self.delegate loginSuccess];
                                                                   }];
                                                               }
                                                               else {
                                                                   [viewController hidePopup:YES completion:nil];
                                                               }
                                                           }];
                                     }];
    }
    else {
        // do nothing
    }
}

@end
