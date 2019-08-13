//
//  MeSettingCell.m
//  hiChat
//
//  Created by Polly polly on 06/02/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "MeSettingCell.h"

@interface MeSettingCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;

@end

@implementation MeSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(12);
            make.centerY.equalTo(CONTENT_VIEW);
            make.size.mas_equalTo(CGSizeMake(30, 30));
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

- (void)setIcon:(UIImage *)icon
           name:(NSString *)name {
    self.iconView.image = icon;
    self.nameLabel.text = name;
}

@end
