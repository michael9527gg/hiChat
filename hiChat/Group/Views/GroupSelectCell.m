//
//  GroupSelectCell.m
//  hiChat
//
//  Created by Polly polly on 30/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "GroupSelectCell.h"

@interface GroupSelectCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UIButton    *selectView;

@end

@implementation GroupSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.selectView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectView setImage:[UIImage imageNamed:@"ic_contact_unselect"]
                         forState:UIControlStateNormal];
        [self.selectView setImage:[UIImage imageNamed:@"ic_contact_select"]
                         forState:UIControlStateSelected];
        self.selectView.userInteractionEnabled = NO;
        [CONTENT_VIEW addSubview:self.selectView];
        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(CONTENT_VIEW);
            make.left.equalTo(CONTENT_VIEW).offset(16);
            make.size.mas_equalTo(CGSizeMake(20, 20));
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

- (void)setUserChoose:(BOOL)userChoose {
    _userChoose = userChoose;
    
    self.selectView.selected = userChoose;
}

- (void)setData:(GroupData *)data {
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[data.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:[UIImage defaultAvatar]
                            completed:nil];
    
    self.nameLabel.text = data.name;
}

@end
