//
//  AboutTableViewCell.m
//  hiChat
//
//  Created by zhangliyong on 24/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "MeAboutCell.h"

@interface MeAboutCell ()

@property (nonatomic, strong) UIView    *versionDot;

@end

@implementation MeAboutCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.versionDot = [UIView new];
        [CONTENT_VIEW addSubview:self.versionDot];
    }
    
    return self;
}

- (void)setVersionNew:(BOOL)versionNew {
    self.versionDot.hidden = !versionNew;
    
    [self.versionDot mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.textLabel);
        make.centerY.equalTo(self.textLabel);
        make.width.equalTo(@8);
        make.height.equalTo(self.versionDot.mas_width);
    }];
    
    [CONTENT_VIEW bringSubviewToFront:self.versionDot];
    self.versionDot.backgroundColor = [UIColor redColor];
    CALayer *layer = self.versionDot.layer;
    layer.cornerRadius = 4;
}

@end
