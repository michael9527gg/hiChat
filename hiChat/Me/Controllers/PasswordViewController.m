//
//  PasswordViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/15.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "PasswordViewController.h"
#import "AccountManager.h"
#import "AppDelegate.h"

@interface PasswordViewController ()

@property (nonatomic, strong) UITextField   *newaPassField1;
@property (nonatomic, strong) UITextField   *newaPassField2;

@end

@implementation PasswordViewController

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorFromHex:0xf0f0f0];
    
    NSInteger padding = 8;
    
    UILabel *label1 = [UILabel new];
    label1.font = [UIFont systemFontOfSize:15];
    label1.text = @"新密码";
    [view addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(padding);
        make.left.equalTo(view).offset(padding);
    }];
    
    UITextField *textField1 = [UITextField new];
    textField1.backgroundColor = [UIColor whiteColor];
    textField1.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 8)];
    textField1.leftViewMode = UITextFieldViewModeAlways;
    textField1.secureTextEntry = YES;
    textField1.placeholder = @"请输入新密码";
    textField1.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view addSubview:textField1];
    [textField1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.top.equalTo(label1.mas_bottom).offset(padding);
        make.right.equalTo(view);
        make.height.equalTo(@38);
    }];
    self.newaPassField1 = textField1;
    
    UILabel *label2 = [UILabel new];
    label2.font = [UIFont systemFontOfSize:15];
    label2.text = @"确认新密码";
    [view addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField1.mas_bottom).offset(padding);
        make.left.equalTo(view).offset(padding);
    }];
    
    UITextField *textField2 = [UITextField new];
    textField2.backgroundColor = [UIColor whiteColor];
    textField2.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 8)];
    textField2.leftViewMode = UITextFieldViewModeAlways;
    textField2.secureTextEntry = YES;
    textField2.placeholder = @"请再次输入新密码";
    textField2.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view addSubview:textField2];
    [textField2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.top.equalTo(label2.mas_bottom).offset(padding);
        make.right.equalTo(view);
        make.height.equalTo(@38);
    }];
    self.newaPassField2 = textField2;
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_DONE
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(touchSave)];
}

- (void)touchSave {
    [self.view endEditing:YES];
    
    NSString *newPass1 = self.newaPassField1.text;
    NSString *newpass2 = self.newaPassField2.text;
    if (newPass1.length < 6 || newPass1.length > 20) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"新密码必须是6~20位字符"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             [self.newaPassField1 becomeFirstResponder];
                                         }
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
        
        return;
    }
    
    if(![newPass1 isEqualToString:newpass2]) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"两次密码输入不一致"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             [self.newaPassField1 becomeFirstResponder];
                                         }
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD startLoading:APP_DELEGATE_WINDOW];
    
    [[AccountManager manager] changePassword:newPass1
                                     oldPass:@""
                                  completion:^(BOOL success, NSDictionary * _Nullable info) {
                                      [MBProgressHUD finishLoading:hud
                                                            result:success
                                                              text:[info msg]
                                                        completion:^{
                                                            if (success) {
                                                                [self.navigationController popViewControllerAnimated:YES];
                                                            }
                                                        }];
                                  }];
}

@end
