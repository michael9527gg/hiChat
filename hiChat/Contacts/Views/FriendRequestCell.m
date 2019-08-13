//
//  FriendRequestCell.m
//  hiChat
//
//  Created by Polly polly on 20/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "FriendRequestCell.h"

@interface FriendRequestCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UIButton    *acceptBtn;
@property (nonatomic, strong) UIButton    *rejectBtn;
@property (nonatomic, strong) UILabel     *statusLabel;

@end

@implementation FriendRequestCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.iconView = [[UIImageView alloc] init];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(8);
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(8);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
        
        self.statusLabel = [[UILabel alloc] init];
        self.statusLabel.textColor = [UIColor lightGrayColor];
        [CONTENT_VIEW addSubview:self.statusLabel];
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(CONTENT_VIEW).offset(-24);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
        
        self.rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rejectBtn setBackgroundImage:[UIImage imageWithColor:[UIColor redColor] size:CGSizeMake(1, 1)]
                                  forState:UIControlStateNormal];
        [self.rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        [self.rejectBtn addTarget:self
                           action:@selector(touchReject)
                 forControlEvents:UIControlEventTouchUpInside];
        self.rejectBtn.layer.cornerRadius = 5;
        self.rejectBtn.layer.masksToBounds = YES;
        [CONTENT_VIEW addSubview:self.rejectBtn];
        [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(CONTENT_VIEW).offset(-8);
            make.centerY.equalTo(CONTENT_VIEW);
            make.size.mas_equalTo(CGSizeMake(60, 32));
        }];
        
        self.acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.acceptBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHex:0x1064FA] size:CGSizeMake(1, 1)]
                                  forState:UIControlStateNormal];
        [self.acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
        [self.acceptBtn addTarget:self
                           action:@selector(touchAccept)
                 forControlEvents:UIControlEventTouchUpInside];
        self.acceptBtn.layer.cornerRadius = 5;
        self.acceptBtn.layer.masksToBounds = YES;
        [CONTENT_VIEW addSubview:self.acceptBtn];
        [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.rejectBtn.mas_left).offset(-8);
            make.centerY.equalTo(CONTENT_VIEW);
            make.size.mas_equalTo(CGSizeMake(60, 32));
            make.left.equalTo(self.nameLabel.mas_right).offset(8);
        }];
    }

    return self;
}

- (void)touchAccept {
    [self.delegate processFriendRequestWithUserid:self.data.userid
                                           accept:YES
                                             cell:self];
}

- (void)touchReject {
    [self.delegate processFriendRequestWithUserid:self.data.userid
                                           accept:NO
                                             cell:self];
}

- (void)setData:(FriendRequsetData *)data {
    _data = data;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[data.portraitUri ossUrlStringRoundWithSize:LIST_ICON_SIZE]]
                     placeholderImage:nil
                            completed:nil];
    
    self.nameLabel.text = data.name;
    
    [self updateRequestStatus:data.status.integerValue];
}

- (void)updateRequestStatus:(FriendRequestStatus)requestStatus {
    switch (requestStatus) {
        case FriendRequestStatusSend: {
            self.acceptBtn.hidden = YES;
            self.rejectBtn.hidden = YES;
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"已发送";
        }
            break;
        case FriendRequestStatusAccept: {
            self.acceptBtn.hidden = YES;
            self.rejectBtn.hidden = YES;
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"已添加";
        }
            break;
        case FriendRequestStatusRequest: {
            self.acceptBtn.hidden = NO;
            self.rejectBtn.hidden = NO;
            self.statusLabel.hidden = YES;
        }
            break;
        case FriendRequestStatusReject: {
            self.acceptBtn.hidden = YES;
            self.rejectBtn.hidden = YES;
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"已拒绝";
        }
            break;
            
        default:
            break;
    }
}

@end
