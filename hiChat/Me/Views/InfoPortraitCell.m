//
//  InfoAvatarTableViewCell.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/14.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "InfoPortraitCell.h"
#import "UniManager.h"

@interface InfoPortraitCell ()

@property (nonatomic, strong) UIImageView       *iconView;

@end

@implementation InfoPortraitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        NSInteger padding = 16;
        self.iconView = [UIImageView new];
        self.iconView.contentMode = UIViewContentModeScaleAspectFill;
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(CONTENT_VIEW).offset(padding);
            make.bottom.equalTo(CONTENT_VIEW).offset(-padding);
            make.right.equalTo(CONTENT_VIEW).offset(-padding);
            make.width.equalTo(self.iconView.mas_height);
        }];
    }
    
    return self;
}

- (void)setAvatarUrl:(NSString *)avatarUrl name:(nonnull NSString *)name {
    [CONTENT_VIEW bringSubviewToFront:self.iconView];
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[avatarUrl ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:[UIImage defaultAvatar]
                            completed:nil];
}

@end
