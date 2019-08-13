//
//  TextEditCell.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "TextEditCell.h"
#import "YuTextField.h"

@interface TextEditCell () < YuTextFieldDelegate >

@property (nonatomic, strong) UITextField   *textField;

@end

@implementation TextEditCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.textField = [UITextField new];
        self.textField.backgroundColor = [UIColor whiteColor];
        self.textField.delegate = self;
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        [CONTENT_VIEW addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(CONTENT_VIEW).inset(8);
        }];
    }
    
    return self;
}

- (void)setString:(NSString *)string {
    self.textField.text = string;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.textField.placeholder = placeholder;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.delegate textDidEdit:textField.text];
}

@end
