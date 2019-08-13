//
//  InfoDetailCell.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "InfoDetailCell.h"

@interface InfoDetailCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *detailLabel;

@end

@implementation InfoDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = CONTENT_VIEW.backgroundColor = [UIColor colorFromString:@"0xF7F7F7"];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        [CONTENT_VIEW addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(CONTENT_VIEW);
            make.top.bottom.equalTo(CONTENT_VIEW);
            make.width.equalTo(CONTENT_VIEW).multipliedBy(.9);
        }];
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [bgView addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgView).offset(12);
            make.centerY.equalTo(bgView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [bgView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(12);
            make.centerY.equalTo(bgView);
        }];
        
        self.detailLabel = [[UILabel alloc] init];
        [bgView addSubview:self.detailLabel];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(bgView).offset(-8);
            make.centerY.equalTo(bgView);
        }];
        
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = [UIColor colorFromString:@"0xF7F7F7"];
        [bgView addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(bgView);
            make.bottom.equalTo(bgView);
            make.height.equalTo(@2);
        }];
    }
    
    return self;
}

- (void)setIcon:(UIImage *)icon
           name:(NSString *)name
         detail:(NSString *)detail {
    self.iconView.image = icon;
    self.nameLabel.text = name;
    self.detailLabel.text = detail;
}

@end
