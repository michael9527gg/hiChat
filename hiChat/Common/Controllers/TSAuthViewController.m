//
//  TSAuthViewController.m
//  hiChat
//
//  Created by zhangliyong on 21/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "TSAuthViewController.h"

@interface TSAuthViewController () < VIPinFieldDelegate >

@property (nonatomic, copy)   NSString      *msg;
@property (nonatomic, strong) VIPinField    *pinField;

@end

@implementation TSAuthViewController

- (instancetype)initWithMsg:(NSString *)msg {
    if (self = [super init]) {
        self.msg = msg;
        
        CGRect rect = [UIScreen mainScreen].bounds;
        self.contentSizeInPopup = CGSizeMake(CGRectGetWidth(rect) - 64, 136);
    }
    
    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    NSInteger padding = 8;
    
    UIButton *btnClose = [UIButton buttonWithTitleColor:[UIColor whiteColor]
                                        backgroundColor:[UIColor grayColor]
                                            cornerRadii:CGSizeMake(8, 8)];
    [btnClose setImage:[UIImage imageNamed:@"ic_login_close"] forState:UIControlStateNormal];
    [btnClose addTarget:self
                 action:@selector(touchCancel)
       forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btnClose];
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@16);
        make.height.equalTo(btnClose.mas_width);
        make.top.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
    }];
    
    UILabel *label = [UILabel new];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.msg;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnClose.mas_bottom).offset(padding);
        make.left.equalTo(view).offset(padding);
        make.right.equalTo(view).offset(-padding);
    }];
    
    VIPinField *pinField = [[VIPinField alloc] initWithFrame:CGRectZero digitCount:6];
    pinField.delegate = self;
    
    [view addSubview:pinField];
    [pinField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@48);
        make.left.equalTo(view).offset(padding * 2);
        make.right.equalTo(view).offset(-padding * 2);
        make.bottom.equalTo(view).offset(-padding * 2);
    }];
    self.pinField = pinField;
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.pinField becomeFirstResponder];
}

- (void)touchCancel {
    [self.delegate authViewControllerDidCancel:self];
}

- (void)setCode:(NSString *)code {
    self.pinField.text = code;
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    
    [self.pinField becomeFirstResponder];
    
    return YES;
}

#pragma mark - VIPinFieldDelegate

- (void)pinTextDidChange:(VIPinField *)pinField {
    if (pinField.text.length == pinField.digitCount) {
        [self.pinField resignFirstResponder];
        
        [self.delegate authViewController:self didFinishWithText:pinField.text];
    }
}

@end
