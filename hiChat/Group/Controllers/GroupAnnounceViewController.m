//
//  GroupAnnounceController.m
//  hiChat
//
//  Created by Polly polly on 21/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupAnnounceViewController.h"
#import "OnkeyTextEditView.h"

@interface GroupAnnounceViewController ()

@property (nonatomic, strong) OnkeyTextEditView *textView;

@end

@implementation GroupAnnounceViewController

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = HICHAT_MAIN_BGCOLOR;
    
    self.textView = [[OnkeyTextEditView alloc] init];
    self.textView.maxLength = 65535;
    self.textView.hasBorder = NO;
    [view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"群公告";
    
    self.textView.userInteractionEnabled = self.isAdmin;
    self.textView.placeHolder = @"群组暂未发布公告";
    self.textView.text = self.announcement;
    if(self.isAdmin) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self
                                                                                               action:@selector(touchSave)];
    }
}

- (void)touchSave {
    if(!self.textView.text.length) {
        [MBProgressHUD showMessage:@"公告内容不能为空"
                            onView:APP_DELEGATE_WINDOW];
        
        return;
    }
    
    if(self.delegate) {
        [self.delegate editGroupWithAnnouncement:self.textView.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
