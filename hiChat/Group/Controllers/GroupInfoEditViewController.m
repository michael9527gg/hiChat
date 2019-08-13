//
//  GroupInfoEditViewController.m
//  hiChat
//
//  Created by Polly polly on 15/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupInfoEditViewController.h"
#import "GroupManager.h"
#import "YuTextField.h"

@interface GroupInfoEditViewController () < UITextFieldDelegate >

@property (nonatomic, strong) UIImageView    *portraitView;
@property (nonatomic, strong) YuTextField    *nameField;
@property (nonatomic, copy)   NSString       *portraitUrl;

@end

@implementation GroupInfoEditViewController

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *topLabel = [[UILabel alloc] init];
    topLabel.text = @"添加群头像(可选)";
    topLabel.textColor = [UIColor darkGrayColor];
    [view addSubview:topLabel];
    [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(view).offset(32);
    }];
    
    self.portraitView = [[UIImageView alloc] init];
    self.portraitView.userInteractionEnabled = YES;
    self.portraitView.image = [UIImage imageNamed:@"ic_add_photo"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAddPhoto)];
    [self.portraitView addGestureRecognizer:tap];
    [view addSubview:self.portraitView];
    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(topLabel.mas_bottom).offset(32);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    self.nameField = [YuTextField new];
    self.nameField.placeholder = @"输入群名称";
    self.nameField.textAlignment = NSTextAlignmentCenter;
    [self.nameField addTarget:self
                       action:@selector(textFieldChanged)
             forControlEvents:UIControlEventEditingChanged];
    [view addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portraitView.mas_bottom).offset(64);
        make.left.equalTo(view).offset(64);
        make.right.equalTo(view).offset(-64);
    }];
    
    UIView *sepLine = [[UIView alloc] init];
    sepLine.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:sepLine];
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameField.mas_bottom);
        make.left.equalTo(self.nameField);
        make.right.equalTo(self.nameField);
        make.height.equalTo(@.5);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"编辑群信息";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(touchFinish)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(touchCancel)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)touchCancel {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)touchFinish {
    if(self.nameField.text.length) {
        [self.view endEditing:YES];
        
        MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                                 mode:MBProgressHUDModeIndeterminate
                                                image:nil
                                              message:YUCLOUD_STRING_PLEASE_WAIT
                                            delayHide:NO
                                           completion:nil];
        GroupManager *manager = [GroupManager manager];
        [manager createGroupWithName:self.nameField.text
                            portrait:self.portraitUrl
                          completion:^(BOOL success, NSDictionary * _Nullable info) {
                              if(success) {
                                  NSNumber *groupid = YUCLOUD_VALIDATE_NUMBER([info valueForKey:@"groupid"]);
                                  [manager joinGroupWithGroupId:groupid.stringValue
                                                groupMemberList:self.contactsArray
                                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                         [MBProgressHUD finishHudWithResult:success
                                                                                        hud:hud
                                                                                  labelText:success ? @"群组创建成功" : @"群组创建失败"
                                                                                 completion:^{
                                                                                     [self dismissViewControllerAnimated:YES
                                                                                                              completion:^{
                                                                                                                  if(success) {
                                                                                                                      ConversationViewController *vc = [[ConversationViewController alloc] init];
                                                                                                                      vc.conversationType = ConversationType_GROUP;
                                                                                                                      vc.targetId = groupid.stringValue;
                                                                                                                      vc.title = self.nameField.text;
                                                                                                                      [[UniManager manager].topNavigationController pushViewController:vc animated:YES];
                                                                                                                  }
                                                                                                              }];
                                                                                 }];
                                                     }];
                              } else {
                                  [MBProgressHUD finishHudWithResult:success
                                                                 hud:hud
                                                           labelText:info[@"msg"]
                                                          completion:^{
                                                              [self dismissViewControllerAnimated:YES
                                                                                       completion:nil];
                                                          }];
                              }
                          }];
    } else {
        [MBProgressHUD showFinishHudOn:self.view
                            withResult:NO
                             labelText:@"请输入群名称"
                             delayHide:YES
                            completion:nil];
    }
}

- (void)touchAddPhoto {
    [[UniManager manager] selectImageWithLimit:1
                                          type:PHAssetMediaTypeImage
                                viewController:self
                                       squared:YES
                                        upload:YES
                                withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                    if (success) {
                                        NSArray *array = info[@"images"];
                                        self.portraitUrl = array.firstObject;
                                        
                                        [self.portraitView sd_setImageWithURL:[NSURL URLWithString:[self.portraitUrl ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                                                             placeholderImage:nil
                                                                    completed:nil];
                                    }
                                }];
}

- (void)textFieldChanged {
    
}

@end
