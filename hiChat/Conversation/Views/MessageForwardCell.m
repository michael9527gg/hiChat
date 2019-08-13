//
//  MessageForwardCell.m
//  hiChat
//
//  Created by Polly polly on 16/01/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "MessageForwardCell.h"

@interface MessageForwardCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *typeLabel;

@end

@implementation MessageForwardCell

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
        
        self.typeLabel = [[UILabel alloc] init];
        self.typeLabel.textColor = [UIColor lightGrayColor];
        self.typeLabel.font = [UIFont systemFontOfSize:14];
        [CONTENT_VIEW addSubview:self.typeLabel];
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(CONTENT_VIEW).offset(-12);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setName:(NSString *)name
       portrail:(NSString *)portrail
           type:(NSString *)type {
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[portrail ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:nil
                            completed:nil];
    
    self.nameLabel.text = name;
    self.typeLabel.text = type;
}

@end
