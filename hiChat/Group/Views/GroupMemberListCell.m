//
//  GroupMemberListCell.m
//  hiChat
//
//  Created by Polly polly on 17/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupMemberListCell.h"

@interface GroupMemberListCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *roleLabel;

@end

@implementation GroupMemberListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.iconView = [[UIImageView alloc] init];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(8);
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.roleLabel = [[UILabel alloc] init];
        [CONTENT_VIEW addSubview:self.roleLabel];
        [self.roleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(CONTENT_VIEW);
            make.right.equalTo(CONTENT_VIEW).offset(-1);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(8);
            make.right.lessThanOrEqualTo(self.roleLabel.mas_left).offset(-8);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setData:(GroupMemberData *)data {
    _data = data;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[data.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:[UIImage defaultAvatar]
                            completed:nil];
    
    self.nameLabel.text = data.name;
    
    NSString *infoStr = @"";
    if([data.groupRole isEqualToString:@"2"]) {
        infoStr = @"群主";
        self.nameLabel.textColor = [UIColor redColor];
        self.roleLabel.textColor = [UIColor redColor];
    } else if([data.groupRole isEqualToString:@"1"]) {
        infoStr = @"管理员";
        self.nameLabel.textColor = [UIColor orangeColor];
        self.roleLabel.textColor = [UIColor orangeColor];
    }
    else {
        infoStr = @"";
        self.nameLabel.textColor = [UIColor darkGrayColor];
        self.roleLabel.textColor = [UIColor darkGrayColor];
    }
    
    if([data.userid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
        infoStr = [infoStr stringByAppendingString:@"(我)"];
    }
    
    self.roleLabel.text = infoStr;
    self.separatorInset = UIEdgeInsetsMake(0, 8, 0, 0);
}

@end
