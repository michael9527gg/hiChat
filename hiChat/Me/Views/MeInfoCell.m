//
//  MeInfoCell.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "MeInfoCell.h"
#import "UIImageView+WebCache.h"

@interface MeInfoCell ()

@property (nonatomic, strong) UIImageView       *iconView;
@property (nonatomic, strong) UILabel           *nameLabel;

@end

@implementation MeInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        NSInteger padding = 8;
        self.iconView = [UIImageView new];
        self.iconView.contentMode = UIViewContentModeScaleAspectFill;
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(padding);
            make.top.equalTo(CONTENT_VIEW).offset(padding);
            make.bottom.equalTo(CONTENT_VIEW).offset(-padding);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.nameLabel = [UILabel new];
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(padding);
            make.right.equalTo(CONTENT_VIEW).offset(-padding);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setAccountInfo:(AccountInfo *)accountInfo {
    if (accountInfo) {
        self.nameLabel.text = accountInfo.nickname?:[NSUserDefaults nameOfUser:YUCLOUD_ACCOUNT_USERID];
        NSString *portrait = accountInfo.portraitUri?:[NSUserDefaults portraitUriOfUser:YUCLOUD_ACCOUNT_USERID];
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                         placeholderImage:[UIImage defaultAvatar]
                                completed:nil];
    }
    else {
        self.nameLabel.text = @"点击登录";
    }
}

@end
