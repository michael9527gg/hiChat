//
//  ContactCell.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "ContactCell.h"

@interface ContactCell ()

@property (nonatomic, strong) UIImageView            *iconView;
@property (nonatomic, strong) UILabel                *labelView;
@property (nonatomic, strong) RCMessageBubbleTipView *tipView;

@end

@implementation ContactCell

+ (NSString *)staticReuseIdentifier {
    return [NSString stringWithFormat:@"%@-static", NSStringFromClass(self)];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.iconView = [UIImageView new];
        self.iconView.contentMode = UIViewContentModeScaleAspectFill;
        NSInteger padding = 8;
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(padding);
            make.top.equalTo(CONTENT_VIEW).offset(padding);
            make.bottom.equalTo(CONTENT_VIEW).offset(-padding);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.labelView = [UILabel new];
        [CONTENT_VIEW addSubview:self.labelView];
        [self.labelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(padding);
            make.right.equalTo(CONTENT_VIEW).offset(-padding);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
        
        self.separatorInset = UIEdgeInsetsMake(0, padding, 0, 0);
        
        self.tipView = [[RCMessageBubbleTipView alloc] initWithParentView:CONTENT_VIEW
                                                                alignment:RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_CENTER_RIGHT];
        self.tipView.bubbleTipPositionAdjustment = CGPointMake(-20, 0);
        self.tipView.isShowNotificationNumber = YES;
    }
    
    return self;
}

- (void)setIcon:(UIImage *)icon {
    self.iconView.image = icon;
}

- (void)setPortraitUri:(NSString *)portraitUri {
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:[UIImage defaultAvatar]
                            completed:nil];
}

- (void)setString:(NSString *)string {
    self.labelView.text = string;
}

- (void)setBadgeNum:(NSInteger)badgeNum {
    _badgeNum = badgeNum;
    
    [self.tipView setBubbleTipNumber:@(badgeNum).intValue];
}

@end
