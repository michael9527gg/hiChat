//
//  ContactDetailCell.m
//  hiChat
//
//  Created by Polly polly on 22/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "ContactDetailCell.h"

@interface ContactDetailCell ()

@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UILabel       *label;
@property (nonatomic, copy)   NSString      *portrait;

@end

@implementation ContactDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.iconView = [UIImageView new];
        NSInteger padding = 8;
        self.iconView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touchIcon)];
        [self.iconView addGestureRecognizer:tap];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(padding);
            make.top.equalTo(CONTENT_VIEW).offset(padding);
            make.bottom.equalTo(CONTENT_VIEW).offset(-padding);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.label = [UILabel new];
        self.label.numberOfLines = 3;
        self.label.userInteractionEnabled = YES;
        UITapGestureRecognizer *labelTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(makeCall)];
        [self.label addGestureRecognizer:labelTap];
        [CONTENT_VIEW addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(8);
            make.centerY.equalTo(CONTENT_VIEW);
            make.right.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)touchIcon {
    [self.delegate showIcon:self.portrait];
}

- (void)makeCall {
    [self.delegate makeCall];
}

- (void)setNickname:(NSString *)nickname
        displayName:(NSString *)displayName
           portrait:(NSString *)portrait
              phone:(NSString *)phone {
    self.portrait = [[portrait ossUrlStringResized:LARGE_ICON_SIZE] ossUrlStringJpegFormatted];
    
    self.iconView.userInteractionEnabled = self.delegate && portrait.length > 0;
    self.label.userInteractionEnabled = self.delegate && phone.length > 0;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:[UIImage defaultAvatar]
                            completed:nil];
    
    UIFont *fontTitle = [UIFont systemFontOfSize:17];
    UIFont *fontContent = [UIFont systemFontOfSize:17];
    UIColor *colorText = [UIColor colorFromHex:0x222];
    
    NSMutableAttributedString *string = [NSAttributedString attributedStringWithStrings:
                                         @"昵称 : ", fontTitle, colorText,
                                         nickname?:@"", fontTitle, colorText, nil].mutableCopy;
    
    if (displayName.length > 0) {
        [string appendAttributedString:[NSAttributedString attributedStringWithStrings:
                                        @"\n备注 : ", fontTitle, colorText,
                                        displayName, fontContent, colorText, nil]];
    }
    
    if (phone.length > 0) {
        [string appendAttributedString:[NSAttributedString attributedStringWithStrings:
                                        @"\n手机 : ", fontTitle, colorText,
                                        phone, fontContent, [UIColor blueColor], nil]];
    }
    
    NSRange range = [string.string rangeOfString:@"昵称 :"];
    if(range.length) {
        [string setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17],
                                NSForegroundColorAttributeName : [UIColor darkGrayColor]} range:range];
    }
    range = [string.string rangeOfString:@"备注 :"];
    if(range.length) {
        [string setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17],
                                NSForegroundColorAttributeName : [UIColor darkGrayColor]} range:range];
    }
    range = [string.string rangeOfString:@"手机 :"];
    if(range.length) {
        [string setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17],
                                NSForegroundColorAttributeName : [UIColor darkGrayColor]} range:range];
    }
    
    self.label.attributedText = string;
}

@end
