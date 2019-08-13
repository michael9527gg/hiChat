//
//  OneKeyAlertViewController.m
//  hiChat
//
//  Created by Polly polly on 01/03/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "OneKeyAlertViewController.h"
#import "UIViewController+STPopup.h"
#import "GroupCategoriesViewController.h"
#import "ContactsSelectViewController.h"
#import "ConversationListViewController.h"

@interface OneKeyAlertViewController ()

@property (nonatomic, strong) UIButton *btn1;
@property (nonatomic, strong) UIButton *btn2;

@end

@implementation OneKeyAlertViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"选择群发对象";
        self.contentSizeInPopup = CGSizeMake(280, 280);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"好友" forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"ic_navi_bg"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(touchFriend) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [btn2 setTitle:@"群组" forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIImage imageNamed:@"ic_navi_bg"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(touchGroup) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn2];
    
    btn1.layer.masksToBounds = YES;
    btn2.layer.masksToBounds = YES;
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(24);
        make.right.equalTo(view).offset(-24);
        make.top.equalTo(view).offset(44);
        make.bottom.equalTo(btn2.mas_top).offset(-44);
        make.height.equalTo(btn2);
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(24);
        make.right.equalTo(view).offset(-24);
        make.top.equalTo(btn1.mas_bottom).offset(44);
        make.bottom.equalTo(view).offset(-44);
        make.height.equalTo(btn1);
    }];
    
    btn2.layer.cornerRadius = btn1.layer.cornerRadius = 8;
    
    self.btn2 = btn2;
    self.btn1 = btn1;
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)touchFriend {
    [self dismissViewControllerAnimated:YES completion:^{
        ConversationListViewController *listViewController = (ConversationListViewController *)[UniManager manager].topViewController;
        ContactsSelectViewController *vc = [[ContactsSelectViewController alloc] initWithPurpose:ContactSelectPurposeOneKey
                                                                                  allowMulSelect:YES
                                                                                        delegate:listViewController
                                                                                         groupid:nil];
        [[UniManager manager].topNavigationController presentViewController:[[MainNavigationController alloc]
                                                                             initWithRootViewController:vc]
                                                                   animated:YES
                                                                 completion:nil];
    }];
}

- (void)touchGroup {
    [self dismissViewControllerAnimated:YES completion:^{
        GroupCategoriesViewController *categories = [[GroupCategoriesViewController alloc] init];
        [[UniManager manager].topNavigationController presentViewController:[[MainNavigationController alloc] initWithRootViewController:categories]
                                                                   animated:YES
                                                                 completion:nil];
    }];
}

@end
