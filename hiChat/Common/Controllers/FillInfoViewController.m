//
//  InfoBindViewController.h
//  hiChat
//
//  Created by Polly polly on 24/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "FillInfoViewController.h"
#import "AppDelegate.h"
#import "AccountManager.h"

@interface FillInfoViewController ()

@property (nonatomic, strong) YuTextField       *phoneView;
@property (nonatomic, strong) YuTextField       *codeView;
@property (nonatomic, strong) YuTextField       *inviteCodeView;
@property (nonatomic, strong) UIButton          *btnResend;
@property (nonatomic, strong) UIButton          *btnSignup;

@property (nonatomic, copy)   NSString          *code;
@property (nonatomic, strong) NSTimer           *timer;
@property (nonatomic, assign) NSInteger         timeCount;


@end

@implementation FillInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"完善信息";
    
    self.timeCount = 0;
    
    NSInteger padding = 16;
    UIView *view = self.view;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_resetpass_back"] imageResized:22]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(goBack)];
    
    self.phoneView = [YuTextField new];
    self.phoneView.placeholder = @"手机号";
    self.phoneView.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneView.text = [NSUserDefaults phone];
    [self.phoneView addTarget:self
                       action:@selector(textFieldChanged)
             forControlEvents:UIControlEventEditingChanged];
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
    self.codeView.keyboardType = UIKeyboardTypeNumberPad;
    [self.codeView addTarget:self
                      action:@selector(textFieldChanged)
            forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sepLine.mas_bottom).offset(1);
        make.left.equalTo(view).offset(padding);
        make.height.equalTo(@48);
    }];
    
    UIButton *btnResend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnResend setTitle:@"发送验证码" forState:UIControlStateNormal];
    btnResend.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnResend setBackgroundImage:[UIImage imageNamed:@"ic_signup_msg"]
                         forState:UIControlStateNormal];
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
    
    self.inviteCodeView = [YuTextField new];
    self.inviteCodeView.placeholder = @"邀请码";
    [self.inviteCodeView addTarget:self
                            action:@selector(textFieldChanged)
                  forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.inviteCodeView];
    [self.inviteCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.top.equalTo(self.inviteCodeView.mas_bottom).offset(1);
        make.height.equalTo(@.5);
    }];
    
    UIButton *btnSignup = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignup setBackgroundImage:[UIImage imageNamed:@"ic_resetpass_confirm"] forState:UIControlStateNormal];
    [btnSignup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSignup setTitle:@"确认" forState:UIControlStateNormal];
    [btnSignup addTarget:self
                  action:@selector(touchBind)
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.inviteCodeView.text = [NSUserDefaults invitationCode];
}

- (void)textFieldChanged {
    
}

- (void)goBack {
    [self.delegate showLogin:nil];
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
                                           reason:@"fill"
                                       completion:^(BOOL success, NSDictionary * _Nullable info) {
                                           NSDictionary *result = info[@"result"];
                                           self.codeView.text = YUCLOUD_VALIDATE_STRING(result[@"code"]);
                                           if (success) {
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

- (void)touchBind {
    NSString *phone = self.phoneView.text;
    NSString *code = self.codeView.text;
    NSString *inviteCode = self.inviteCodeView.text;
    
    if (phone.length == 0 || code.length == 0 || inviteCode.length == 0) {
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
    
    [self.view endEditing:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    [[AccountManager manager] fillInfoWithAccessToken:self.accessToken
                                                phone:self.phoneView.text
                                                 code:self.codeView.text
                                           inviteCode:self.inviteCodeView.text
                                           completion:^(BOOL success, NSDictionary * _Nullable info) {
                                               [MBProgressHUD finishHudWithResult:success
                                                                              hud:hud
                                                                        labelText:[info msg]
                                                                       completion:^{
                                                                           if (success) {
                                                                               [self.delegate showLogin:nil];
                                                                           }
                                                                       }];
                                           }];
}

@end
