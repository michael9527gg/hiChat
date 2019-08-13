//
//  SignupViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "SignupViewController.h"
#import "AppDelegate.h"
#import "AccountManager.h"

@interface SignupViewController ()

@property (nonatomic, strong) YuTextField       *nameView;
@property (nonatomic, strong) YuTextField       *phoneView;
@property (nonatomic, strong) YuTextField       *codeView;
@property (nonatomic, strong) YuTextField       *passView;
@property (nonatomic, strong) YuTextField       *invitationCodeView;

@property (nonatomic, strong) UIButton          *btnResend;
@property (nonatomic, strong) UIButton          *btnSignup;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeCount;


@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"立即注册";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIView *view = self.view;
    
    NSInteger padding = 16;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_resetpass_back"] imageResized:22]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(touchLogin)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    self.nameView = [YuTextField new];
    self.nameView.placeholder = @"请输入昵称";
    [view addSubview:self.nameView];
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.top.equalTo(view).offset(24);
        make.height.equalTo(@48);
    }];
    
    UIView *sepLine = [UIView new];
    sepLine.backgroundColor = [UIColor grayColor];
    [view addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.top.equalTo(self.nameView.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    self.phoneView = [YuTextField new];
    self.phoneView.placeholder = @"请输入手机号";
    self.phoneView.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneView.text = [NSUserDefaults phone];
    [self.phoneView addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.phoneView];
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(1);
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.height.equalTo(@48);
    }];
    
    sepLine = [UIView new];
    sepLine.backgroundColor = [UIColor grayColor];
    [view addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.top.equalTo(self.phoneView.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    self.codeView = [YuTextField new];
    self.codeView.placeholder = @"请输入验证码";
    self.codeView.keyboardType = UIKeyboardTypeNumberPad;
    [self.codeView addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(1);
        make.left.equalTo(view).offset(padding);
        make.height.equalTo(@48);
    }];
    
    UIButton *btnResend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnResend setTitle:@"发送验证码" forState:UIControlStateNormal];
    [btnResend setBackgroundImage:[UIImage imageNamed:@"ic_signup_msg"]
                         forState:UIControlStateNormal];
    btnResend.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnResend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnResend addTarget:self
                  action:@selector(touchResend)
        forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btnResend];
    [btnResend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codeView).offset(4);
        make.bottom.equalTo(self.codeView).offset(-4);
        make.right.equalTo(view).offset(-padding);
        make.width.equalTo(@100);
    }];
    self.btnResend = btnResend;
    
    sepLine = [UIView new];
    sepLine.backgroundColor = [UIColor grayColor];
    [view addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.top.equalTo(self.codeView.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    // 密码框
    self.passView = [YuTextField new];
    self.passView.placeholder = @"请输入密码";
    self.passView.secureTextEntry = YES;
    [self.passView addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.passView];
    [self.passView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(1);
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.height.equalTo(@48);
    }];
    
    sepLine = [UIView new];
    sepLine.backgroundColor = [UIColor grayColor];
    [view addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.top.equalTo(self.passView.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    // 邀请码
    self.invitationCodeView = [YuTextField new];
    self.invitationCodeView.placeholder = @"请输入邀请码";
    self.invitationCodeView.lowerCase = YES;
    [self.invitationCodeView addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.invitationCodeView];
    [self.invitationCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(1);
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.height.equalTo(@48);
    }];
    
    sepLine = [UIView new];
    sepLine.backgroundColor = [UIColor grayColor];
    [view addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.top.equalTo(self.invitationCodeView.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
//    UIButton *btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnAgree setAttributedTitle:[NSAttributedString attributedStringWithStrings:@"登录即同意 ", [UIFont systemFontOfSize:12], [UIColor blackColor], @"用户使用协议", [UIFont systemFontOfSize:12], [UIColor colorFromHex:0x1064FA], nil]
//                        forState:UIControlStateNormal];
//    [btnAgree addTarget:self
//                 action:@selector(touchAgree)
//       forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:btnAgree];
//    btnAgree.hidden = YES;
//    [btnAgree mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(sepLine).offset(1);
//        make.top.equalTo(sepLine).offset(8);
//    }];
    
    UIButton *btnSignup = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignup setBackgroundImage:[UIImage imageNamed:@"ic_signup_signup"]
                         forState:UIControlStateNormal];
    [btnSignup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSignup setTitle:@"注册" forState:UIControlStateNormal];
    [btnSignup addTarget:self
                  action:@selector(touchSignup)
        forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btnSignup];
    self.btnSignup = btnSignup;
    [btnSignup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(32);
        make.height.equalTo(@44);
        make.centerX.equalTo(view);
        make.width.equalTo(sepLine).multipliedBy(.8);
    }];
    
    self.timeCount = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.invitationCodeView.text = [NSUserDefaults invitationCode];
}

- (void)applicationDidBecomeActive:(NSNotification *)noti {
    self.invitationCodeView.text = [NSUserDefaults invitationCode];
}

- (void)textFieldChanged {
    
}

- (void)timeCountAction {
    self.timeCount--;
    
    if (self.timeCount > 0) {
        self.btnResend.enabled = NO;
        [self.btnResend setTitle:[NSString stringWithFormat:@"倒计时(%lds)", (long)self.timeCount] forState:UIControlStateNormal];
        [self.btnResend setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    else {
        self.timeCount = 0;
        [self.timer invalidate];
        self.timer = nil;
        self.btnResend.enabled = YES;
        [self.btnResend setTitle:@"发送验证码" forState:UIControlStateNormal];
        [self.btnResend setTitleColor:[UIColor colorFromHex:0x1064FA] forState:UIControlStateNormal];
    }
    
}

- (void)touchResend {
    [self.view endEditing:YES];
    
    NSString *phone = self.phoneView.text;
    if (![phone isValidMobileNumber]) {
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
    
    MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:@"发送验证码中..."
                                        delayHide:NO
                                       completion:nil];
    
    [[AccountManager manager] requestSmsWithPhone:phone
                                           reason:@"register"
                                       completion:^(BOOL success, NSDictionary * _Nullable info) {
                                           if (success) {
                                               NSDictionary *result = info[@"result"];
                                               self.codeView.text = YUCLOUD_VALIDATE_STRING(result[@"code"]);
                                               [MBProgressHUD finishHudWithResult:success
                                                                              hud:hud
                                                                        labelText:success?@"验证码已发送":[info msg]
                                                                       completion:^{
                                                                           if (success) {
                                                                               self.timeCount = 60;
                                                                               
                                                                               self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                                                                             target:self
                                                                                                                           selector:@selector(timeCountAction)
                                                                                                                           userInfo:nil
                                                                                                                            repeats:YES];
                                                                               
                                                                               [self.codeView becomeFirstResponder];
                                                                           }
                                                                       }];
                                           }
                                           else {
                                               [MBProgressHUD finishHudWithResult:NO
                                                                              hud:hud
                                                                        labelText:info[@"msg"]
                                                                       completion:nil];
                                           }
                                       }];
    
}

- (void)touchAgree {
    
}

- (void)touchSignup {
    NSString *name = self.nameView.text;
    NSString *phone = self.phoneView.text;
    NSString *code = self.codeView.text;
    NSString *pass = self.passView.text;
    
    [self.view endEditing:YES];
    
    if (name.length == 0 || phone.length == 0 || code.length == 0 || pass.length == 0) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"请输入有效内容"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:nil
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    [[AccountManager manager] registerWithName:name
                                         phone:phone
                                          pass:pass
                                       smsCode:code
                                invitationCode:self.invitationCodeView.text
                                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                                        if (success) {
                                            [MBProgressHUD finishHudWithResult:YES
                                                                           hud:hud
                                                                     labelText:@"注册成功，现在登录吧"
                                                                    completion:^{
                                                                        [NSUserDefaults savePhone:phone];
                                                                        [self.delegate showLogin:phone];
                                                                    }];
                                        }
                                        else {
                                            [MBProgressHUD finishHudWithResult:NO
                                                                           hud:hud
                                                                     labelText:info[@"msg"]
                                                                    completion:nil];
                                        }
                                    }];
}

- (void)touchLogin {
    [self.delegate showLogin:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
