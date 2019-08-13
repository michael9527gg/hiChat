//
//  TextEditViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "TextEditViewController.h"
#import "TextEditCell.h"

@interface TextEditViewController () < TextEditCellDelegate >

@end

@implementation TextEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHex:0xeeeeee];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_CANCEL
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(touchCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_DONE
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(touchSave)];
    
    [self.tableView registerClass:[TextEditCell class]
           forCellReuseIdentifier:[TextEditCell reuseIdentifier]];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
}

- (void)touchCancel {
    [self.delegate textEditDidCancel:self];
}

- (void)touchSave {
    [self.view endEditing:YES];
    
    [self.delegate textEditDidSave:self];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[TextEditCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(TextEditCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.delegate = self;
    
    cell.string = self.text;
    cell.placeholder = self.placeholder;
}

- (void)textDidEdit:(NSString *)string {
    self.text = string;
}

@end
