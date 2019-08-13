//
//  GroupIconCell.m
//  hiChat
//
//  Created by Polly polly on 28/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupIconCell.h"

@interface GroupIconCell()

@end

@implementation GroupIconCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.iconView = [[UIImageView alloc] init];
        self.iconView.layer.cornerRadius = 8;
        self.iconView.layer.masksToBounds = YES;
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(CONTENT_VIEW).insets(UIEdgeInsetsMake(2, 2, 2, 2));
        }];
    }
    
    return self;
}

@end
