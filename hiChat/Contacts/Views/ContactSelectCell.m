//
//  ContactSelectCell.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "ContactSelectCell.h"

@interface ContactSelectCell()

@property (nonatomic, strong) UIImageView *selectView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;

@end

@implementation ContactSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.selectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_contact_unselect"]];
        [CONTENT_VIEW addSubview:self.selectView];
        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(CONTENT_VIEW);
            make.left.equalTo(CONTENT_VIEW).offset(16);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        self.iconView = [[UIImageView alloc] init];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectView.mas_right).offset(12);
            make.top.equalTo(CONTENT_VIEW).offset(4);
            make.bottom.equalTo(CONTENT_VIEW).offset(-4);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(12);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setData:(id)data {
    _data = data;
    
    if([data isKindOfClass:[ContactData class]]) {
        ContactData *contact = (ContactData *)data;
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[contact.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                         placeholderImage:[UIImage defaultAvatar]
                                completed:nil];
        
        self.nameLabel.text = contact.name;
    } else if([data isKindOfClass:[GroupMemberData class]]) {
        GroupMemberData *groupMember = (GroupMemberData *)data;
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[groupMember.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                         placeholderImage:[UIImage defaultAvatar]
                                completed:nil];
        
        self.nameLabel.text = groupMember.name;
    } else if([data isKindOfClass:[GroupData class]]) {
        GroupData *group = (GroupData *)data;
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[group.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                         placeholderImage:[UIImage defaultAvatar]
                                completed:nil];
        
        self.nameLabel.text = group.name;
    }
}

- (NSString *)userid {
    if([self.data isKindOfClass:[ContactData class]]) {
        ContactData *contact = (ContactData *)self.data;
        return contact.uid;
    } else if([self.data isKindOfClass:[GroupMemberData class]]) {
        GroupMemberData *groupMember = (GroupMemberData *)self.data;
        return groupMember.userid;
    }
    return nil;
}

- (void)setStatus:(SelectCellStatus)status {
    _status = status;
    
    switch (status) {
        case SelectCellStatusNotSelected:
            self.selectView.image = [UIImage imageNamed:@"ic_contact_unselect"];
            break;
        case SelectCellStatusBeSelected:
            self.selectView.image = [UIImage imageNamed:@"ic_contact_select"];
            break;
        case SelectCellStatusNotEnable:
            self.selectView.image = [UIImage imageNamed:@"ic_disable_select"];
            break;
        case SelectCellStatusHidden: {
            self.selectView.hidden = YES;
            [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(CONTENT_VIEW).offset(12);
                make.top.equalTo(CONTENT_VIEW).offset(4);
                make.bottom.equalTo(CONTENT_VIEW).offset(-4);
                make.width.equalTo(self.iconView.mas_height);
            }];
        }
            break;
            
        default:
            break;
    }
}

@end
