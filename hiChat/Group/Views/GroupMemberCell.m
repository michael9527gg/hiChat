//
//  GroupMemberCell.m
//  hiChat
//
//  Created by Polly polly on 17/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupMemberCell.h"

@interface GroupMemberCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UIButton    *roleBtn;

@end

@implementation GroupMemberCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        self.nameLabel.textColor = [UIColor darkGrayColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(CONTENT_VIEW);
            make.left.equalTo(CONTENT_VIEW);
            make.right.equalTo(CONTENT_VIEW);
            make.height.equalTo(@20);
        }];
        
        self.iconView = [[UIImageView alloc] init];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(self.nameLabel.mas_top);
            make.width.equalTo(self.iconView.mas_height);
            make.centerX.equalTo(CONTENT_VIEW);
        }];
        
        self.roleBtn = [[UIButton alloc] init];
        self.roleBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.roleBtn setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
        [self.iconView addSubview:self.roleBtn];
        [self.roleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView).offset(0);
            make.top.equalTo(self.iconView).offset(0);
            make.size.mas_equalTo(CGSizeMake(40, 16));
        }];
    }
    
    return self;
}

- (void)setFunctionImage:(UIImage *)functionImage {
    self.iconView.image = nil;
    
    [self.iconView setImage:functionImage];
    self.nameLabel.text = @"";
    [self.roleBtn setTitle:@"" forState:UIControlStateNormal];
    [self.roleBtn setBackgroundColor:[UIColor clearColor]];
}

- (void)setGroupMember:(GroupMemberData *)groupMember {
    _groupMember = groupMember;
    
    self.iconView.image = nil;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[groupMember.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:[UIImage defaultAvatar]
                            completed:nil];
    
    self.nameLabel.text = groupMember.name;
    
    if(groupMember.isLord) {
        [self.roleBtn setTitle:@"群主" forState:UIControlStateNormal];
        [self.roleBtn setBackgroundColor:[UIColor redColor]];
    } else if(groupMember.isAdmin) {
        [self.roleBtn setTitle:@"管理员" forState:UIControlStateNormal];
        [self.roleBtn setBackgroundColor:[UIColor orangeColor]];
    } else {
        [self.roleBtn setTitle:@"" forState:UIControlStateNormal];
        [self.roleBtn setBackgroundColor:[UIColor clearColor]];
    }
}

@end
