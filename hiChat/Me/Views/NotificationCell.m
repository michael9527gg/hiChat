//
//  NotificationCell.m
//  hiChat
//
//  Created by Polly polly on 27/02/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "NotificationCell.h"
#import "NSDate+HiChat.h"

@interface NotificationCell()

@property (nonatomic, strong) UILabel                *titleLabel;
@property (nonatomic, strong) UILabel                *detailLabel;
@property (nonatomic, strong) UILabel                *dateLabel;
@property (nonatomic, strong) UILabel                *readLabel;

@end

@implementation NotificationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = CONTENT_VIEW.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 8;
        bgView.layer.shadowOffset = CGSizeMake(1,1);
        bgView.layer.shadowOpacity = 0.3;
        bgView.layer.shadowColor = [UIColor blackColor].CGColor;
        [CONTENT_VIEW addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(16);
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.right.equalTo(CONTENT_VIEW).offset(-16);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        self.titleLabel.textColor = [UIColor blackColor];
        [bgView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgView).offset(12);
            make.right.equalTo(bgView).offset(-12);
            make.top.equalTo(bgView).offset(12);
        }];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.textColor = [UIColor blackColor];
        self.detailLabel.font = [UIFont systemFontOfSize:14];
        self.detailLabel.numberOfLines = 2;
        [bgView addSubview:self.detailLabel];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(bgView).offset(-12);
        }];
        
        UIView *lineVieww = [[UIView alloc] init];
        lineVieww.backgroundColor = [UIColor lightGrayColor];
        [bgView addSubview:lineVieww];
        [lineVieww mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgView).offset(12);
            make.right.equalTo(bgView).offset(-12);
            make.top.equalTo(self.detailLabel.mas_bottom).offset(12);
            make.height.equalTo(@.5);
        }];
        
        self.readLabel = [[UILabel alloc] init];
        self.readLabel.text = @"查看详情";
        self.readLabel.font = [UIFont systemFontOfSize:16];
        self.readLabel.textColor = [UIColor blackColor];
        [bgView addSubview:self.readLabel];
        [self.readLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineVieww.mas_bottom).offset(8);
            make.left.equalTo(self.titleLabel);
            make.bottom.equalTo(bgView).offset(-12);
        }];
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.textColor = [UIColor blackColor];
        self.dateLabel.font = [UIFont systemFontOfSize:16];
        [bgView addSubview:self.dateLabel];
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.readLabel);
            make.right.equalTo(bgView).offset(-12);
        }];
    }
    
    return self;
}

- (void)setData:(NotificationData *)data {
    _data = data;
    
    self.titleLabel.text = data.title;
    self.detailLabel.text = data.content;
    self.dateLabel.text = [data.time toFormatString];
    
    if(data.read) {
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.detailLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.readLabel.textColor = [UIColor lightGrayColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
        self.detailLabel.textColor = [UIColor blackColor];
        self.dateLabel.textColor = [UIColor blackColor];
        self.readLabel.textColor = [UIColor blackColor];
    }
}

@end
