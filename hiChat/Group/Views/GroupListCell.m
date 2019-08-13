//
//  GroupListCell.m
//  hiChat
//
//  Created by Polly polly on 18/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupListCell.h"

@interface GroupListCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;

@end

@implementation GroupListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        self.iconView = [[UIImageView alloc] init];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(12);
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

- (void)setData:(GroupData *)data {
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[data.portrait ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:[UIImage defaultAvatar]
                            completed:nil];
    
    self.nameLabel.text = data.name;
}

@end
