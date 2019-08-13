//
//  PrivateUserInfoCell.m
//  hiChat
//
//  Created by Polly polly on 14/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "PrivateUserInfoCell.h"

@interface PrivateUserInfoCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;

@end

@implementation PrivateUserInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = CONTENT_VIEW.backgroundColor = [UIColor whiteColor];
        
        self.iconView = [[UIImageView alloc] init];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(8);
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(CONTENT_VIEW);
            make.left.equalTo(self.iconView.mas_right).offset(8);
        }];
    }
 
    return self;
}

- (void)setData:(id)data {
    _data = data;
    
    if([data isKindOfClass:[ContactData class]]) {
        ContactData *contact = (ContactData *)data;
        
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[contact.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                             placeholderImage:nil
                                    completed:nil];
        
        self.nameLabel.text = contact.name;
    }
    else if([data isKindOfClass:[FriendBlackData class]]) {
        FriendBlackData *black = (FriendBlackData *)data;
        
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[black.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                             placeholderImage:nil
                                    completed:nil];
        
        self.nameLabel.text = black.nickname;
    }
}

@end
