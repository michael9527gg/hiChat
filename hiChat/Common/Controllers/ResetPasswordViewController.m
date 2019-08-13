//
//  ResetPasswordViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "ResetPasswordViewController.h"

@interface ResetPasswordViewController () < YuTextFieldDelegate >

@property (nonatomic, strong) YuTextField       *phoneView;
@property (nonatomic, strong) YuTextField       *codeView;
@property (nonatomic, strong) YuTextField       *passView1;
@property (nonatomic, strong) YuTextField       *passView2;

@property (nonatomic, strong) UIButton          *btnResend;
@property (nonatomic, strong) UIButton          *btnSignup;

@property (nonatomic, copy)   NSString          *code;
@property (nonatomic, strong) NSTimer           *timer;
@property (nonatomic, assign) NSInteger         timeCount;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_resetpass_back"] imageResized:22]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(touchBack)];
    
    self.timeCount = 0;
    
    self.title = @"忘记密码";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSInteger padding = 16;
    
    UIView *view = self.view;
    
    self.phoneView = [YuTextField new];
    self.phoneView.placeholder = @"手机号";
    self.phoneView.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneView.text = [NSUserDefaults phone];
    [self.phoneView setLeftImage:[[UIImage imageNamed:@"ic_resetpass_phone"] imageResized:20]
                         padding:0
                            mode:UITextFieldViewModeAlways];
    [self.phoneView setRightImage:[[UIImage imageNamed:@"ic_resetpass_delete"] imageResized:16]
                          padding:0
                             mode:UITextFieldViewModeAlways];
    self.phoneView.yuTextFieldDelegate = self;
    [self.phoneView addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.phoneView];
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(24);
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.height.equalTo(@48);
    }];
    
    UIView *sepLine = [UIView new];
    sepLine.backgroundColor = [UIColor grayColor];
    [view addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.top.equalTo(self.phoneView.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    self.codeView = [YuTextField new];
    self.codeView.placeholder = @"验证码";
    [self.codeView setLeftImage:[[UIImage imageNamed:@"ic_resetpass_sms"] imageResized:20]
                        padding:0
                           mode:UITextFieldViewModeAlways];
    self.codeView.keyboardType = UIKeyboardTypeNumberPad;
    [self.codeView addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.codeView];
    
    UIButton *btnResend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnResend setTitle:@"发送验证码" forState:UIControlStateNormal];
    btnResend.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnResend setBackgroundImage:[UIImage imageNamed:@"ic_signup_msg"]
                         forState:UIControlStateNormal];
    btnResend.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnResend setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
    [btnResend addTarget:self
                  action:@selector(touchResend)
        forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btnResend];
    self.btnResend = btnResend;
    
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(1);
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(self.btnResend.mas_left);
        make.height.equalTo(@48);
    }];
    
    [btnResend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codeView).offset(4);
        make.bottom.equalTo(self.codeView).offset(-4);
        make.right.equalTo(view).offset(-padding);
        make.width.equalTo(@100);
        make.left.equalTo(self.codeView.mas_right);
    }];
    
    sepLine = [UIView new];
    sepLine.backgroundColor = [UIColor grayColor];
    [view addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
        make.top.equalTo(self.codeView.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    self.passView1 = [YuTextField new];
    self.passView1.placeholder = @"密码（长度最少6位）";
    self.passView1.secureTextEntry = YES;
    [self.passView1 setLeftImage:[[UIImage imageNamed:@"ic_resetpass_pass"] imageResized:20]
                         padding:0
                            mode:UITextFieldViewModeAlways];
    [self.passView1 setRightImage:[[UIImage imageNamed:@"ic_resetpass_closeeye"] imageResized:20]
                          padding:0
                             mode:UITextFieldViewModeAlways];
    [self.passView1 addTarget:self
                       action:@selector(textFieldChanged)
             forControlEvents:UIControlEventEditingChanged];
    self.passView1.yuTextFieldDelegate = self;
    [view addSubview:self.passView1];
    [self.passView1 mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.top.equalTo(self.passView1.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    self.passView2 = [YuTextField new];
    self.passView2.placeholder = @"确认密码（长度最少6位）";
    self.passView2.secureTextEntry = YES;
    [self.passView2 setLeftImage:[[UIImage imageNamed:@"ic_resetpass_pass"] imageResized:20]
                         padding:0
                            mode:UITextFieldViewModeAlways];
    [self.passView2 setRightImage:[[UIImage imageNamed:@"ic_resetpass_closeeye"] imageResized:20]
                          padding:0
                             mode:UITextFieldViewModeAlways];
    [self.passView2 addTarget:self
                       action:@selector(textFieldChanged)
             forControlEvents:UIControlEventEditingChanged];
    self.passView2.yuTextFieldDelegate = self;
    [view addSubview:self.passView2];
    [self.passView2 mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.top.equalTo(self.passView2.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    UIButton *btnSignup = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignup setBackgroundImage:[UIImage imageNamed:@"ic_resetpass_confirm"] forState:UIControlStateNormal];
    [btnSignup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSignup setTitle:@"确认" forState:UIControlStateNormal];
    [btnSignup addTarget:self
                  action:@selector(touchReset)
        forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btnSignup];
    self.btnSignup = btnSignup;
    [btnSignup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(32);
        make.height.equalTo(@44);
        make.centerX.equalTo(view);
        make.width.equalTo(sepLine).multipliedBy(.8);
    }];
}

- (void)touchBack {
    [self touchLogin];
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
    
    MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:@"发送验证码中..."
                                        delayHide:NO
                                       completion:nil];
    
    [[AccountManager manager] requestSmsWithPhone:phone
                                           reason:@"repassword"
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

- (void)touchReset {
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
    
    if(!self.codeView.text.length) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"验证码不能为空"
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
    
    if(!self.passView1.text.length || !self.passView2.text.length) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"密码不能为空"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             
                                         }
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
        return;
    }
    
    if(![self.passView1.text isEqualToString:self.passView2.text]) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"两次密码输入不一致"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             
                                         }
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
    
    [[AccountManager manager] resetPassword:self.phoneView.text
                                       pass:self.passView1.text
                                       code:self.codeView.text
                                 completion:^(BOOL success, NSDictionary * _Nullable info) {
                                     [MBProgressHUD finishHudWithResult:success
                                                                    hud:hud
                                                              labelText:info[@"msg"]
                                                             completion:^{
                                                                 if (success) {
                                                                     [self.delegate showLogin:nil];
                                                                 }
                                                             }];
                                 }];
}

- (void)touchLogin {
    [self.delegate showLogin:nil];
}

#pragma mark - YuTextFieldDelegate

- (void)didTouchRightView:(YuTextField *)yuTextField {
    if(yuTextField == self.phoneView) {
        self.phoneView.text = @"";
    } else if(yuTextField == self.passView1) {
        if(self.passView1.secureTextEntry == YES) {
            [self.passView1 setRightImage:[[UIImage imageNamed:@"ic_resetpass_openeye"] imageResized:20]
                                  padding:0
                                     mode:UITextFieldViewModeAlways];
            self.passView1.secureTextEntry = NO;
        } else {
            [self.passView1 setRightImage:[[UIImage imageNamed:@"ic_resetpass_closeeye"] imageResized:20]
                                  padding:0
                                     mode:UITextFieldViewModeAlways];
            self.passView1.secureTextEntry = YES;
        }
    } else if(yuTextField == self.passView2) {
        if(self.passView2.secureTextEntry == YES) {
            [self.passView2 setRightImage:[[UIImage imageNamed:@"ic_resetpass_openeye"] imageResized:20]
                                  padding:0
                                     mode:UITextFieldViewModeAlways];
            self.passView2.secureTextEntry = NO;
        } else {
            [self.passView2 setRightImage:[[UIImage imageNamed:@"ic_resetpass_closeeye"] imageResized:20]
                                  padding:0
                                     mode:UITextFieldViewModeAlways];
            self.passView2.secureTextEntry = YES;
        }
    }
}

@end
