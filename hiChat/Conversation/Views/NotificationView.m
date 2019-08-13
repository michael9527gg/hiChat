//
//  NotificationView.m
//  hiChat
//
//  Created by Polly polly on 17/03/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "NotificationView.h"
#import "AppDelegate.h"
#import "NotificationDetailViewController.h"

static NSMutableArray *notificationViews;

@interface NotificationView()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation NotificationView

+ (instancetype)show:(NotificationData *)notification {
    NotificationView *notificationView = [[NotificationView alloc] init];
    notificationView.notification = notification;
    [APP_DELEGATE_WINDOW addSubview:notificationView];
    [notificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APP_DELEGATE_WINDOW);
    }];
    
    if(!notificationViews) {
        notificationViews = [NSMutableArray array];
    }
    
    [notificationViews addObject:notificationView];
    
    return notificationView;
}

+ (void)removeAllNotificationViews {
    for(NotificationView *view in notificationViews) {
        [view removeFromSuperview];
    }
    
    [notificationViews removeAllObjects];
    notificationViews = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorFromHex:0xF5F5F5]
                                                                                       size:CGSizeMake(1, 1)]];
        imageView.userInteractionEnabled = YES;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.borderWidth = .5;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self).multipliedBy(.7);
            make.height.equalTo(@160);
        }];
        imageView.transform = CGAffineTransformMakeScale(.1, .1);
        
        UIColor *lineColor = [UIColor lightGrayColor];
        
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_me_about"]];
        [imageView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView).offset(24);
            make.top.equalTo(imageView).offset(12);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        UILabel *sysLabel = [[UILabel alloc] init];
        sysLabel.text = @"系统通知";
        sysLabel.textColor = [UIColor colorFromHex:0x00BFFF];
        sysLabel.font = [UIFont boldSystemFontOfSize:20];
        [imageView addSubview:sysLabel];
        [sysLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(iconView);
            make.left.equalTo(iconView.mas_right).offset(12);
        }];
        
        UIView *topLineView = [[UIView alloc] init];
        topLineView.backgroundColor = [UIColor colorFromHex:0x00BFFF];
        [imageView addSubview:topLineView];
        [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(imageView);
            make.top.equalTo(iconView.mas_bottom).offset(12);
            make.height.equalTo(@2);
        }];
        
        UIView *lineView1 = [[UIView alloc] init];
        lineView1.backgroundColor = lineColor;
        [imageView addSubview:lineView1];
        [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(imageView);
            make.width.equalTo(@.5);
            make.centerX.equalTo(imageView);
            make.height.equalTo(@44);
        }];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [cancelBtn addTarget:self
                      action:@selector(touchCancel)
            forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitleColor:[UIColor darkGrayColor]
                        forState:UIControlStateNormal];
        [imageView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView);
            make.bottom.equalTo(imageView);
            make.right.equalTo(lineView1.mas_left);
            make.height.equalTo(@44);
        }];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sureBtn setTitle:@"查看" forState:UIControlStateNormal];
        [sureBtn addTarget:self
                      action:@selector(touchSure)
            forControlEvents:UIControlEventTouchUpInside];
        [sureBtn setTitleColor:[UIColor darkGrayColor]
                      forState:UIControlStateNormal];
        [imageView addSubview:sureBtn];
        [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(imageView);
            make.bottom.equalTo(imageView);
            make.left.equalTo(lineView1.mas_right);
            make.height.equalTo(@44);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = lineColor;
        [imageView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(imageView);
            make.bottom.equalTo(sureBtn.mas_top);
            make.height.equalTo(@.5);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.numberOfLines = 2;
        [titleLabel sizeToFit];
        [imageView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView).offset(8);
            make.right.equalTo(imageView).offset(-8);
            make.top.equalTo(topLineView.mas_bottom).offset(8);
            make.bottom.equalTo(lineView.mas_top).offset(-8);
        }];
        
        self.titleLabel = titleLabel;
        
        [UIView animateWithDuration:.3 animations:^{
            CGAffineTransform transform1 = CGAffineTransformMakeRotation(M_PI*2.0);
            CGAffineTransform transform2 = CGAffineTransformScale(transform1, 1.2, 1.2);
            imageView.transform = CGAffineTransformTranslate(transform2, 0, 0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            }];
        }];
    }
    
    return self;
}

- (void)setNotification:(NotificationData *)notification {
    _notification = notification;
    
    self.titleLabel.text = notification.title;
}

- (void)touchCancel {
    [UIView animateWithDuration:.3 animations:^{
        CGAffineTransform transform1 = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform transform2 = CGAffineTransformScale(transform1, 0.01, 0.01);
        self.transform = CGAffineTransformTranslate(transform2, 0, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchSure {
    [NotificationView removeAllNotificationViews];
    
    NotificationDetailViewController *detailVC = [[NotificationDetailViewController alloc] init];
    detailVC.data = self.notification;
    [[UniManager manager].topNavigationController pushViewController:detailVC
                                                            animated:YES];
}

@end
