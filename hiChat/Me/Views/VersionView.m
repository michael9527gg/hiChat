//
//  VersionView.m
//  hiChat
//
//  Created by zhangliyong on 26/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "VersionView.h"

@protocol VersionContentViewDelegate < NSObject >

- (void)skip;

@end

@interface VersionContentView : UIView

@property (nonatomic, weak) id<VersionContentViewDelegate>  delegate;

@property (nonatomic, copy) NSDictionary    *data;
@property (nonatomic, strong) UILabel       *labelDesc;
@property (nonatomic, strong) UIButton      *btnSkip;

@end

@implementation VersionContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CALayer *layer = self.layer;
        layer.cornerRadius = 6;
        layer.masksToBounds = YES;
        
        UIImageView *backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_version_background"]];
        backView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_version_check"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView).offset(16);
            make.top.equalTo(backView).offset(16);
            make.width.equalTo(@26);
            make.height.equalTo(@26);
        }];
        
        UILabel *label = [UILabel new];
        label.text = @"版本更新";
        label.font = [UIFont boldSystemFontOfSize:17];
        label.textColor = [UIColor orangeColor];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).offset(8);
            make.centerY.equalTo(imageView);
        }];
        
        UILabel *labelDesc = [UILabel new];
        labelDesc.textColor = [UIColor whiteColor];
        labelDesc.numberOfLines = 10;
        labelDesc.adjustsFontSizeToFitWidth = YES;
        [self addSubview:labelDesc];
        [labelDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self).multipliedBy(.7);
            make.centerX.equalTo(self);
            make.top.equalTo(imageView.mas_bottom).offset(8);
            make.height.equalTo(@138);
        }];
        self.labelDesc = labelDesc;
        
        UIButton *btnUpdate = [UIButton buttonWithTitleColor:[UIColor whiteColor]
                                             backgroundColor:[UIColor colorFromHex:0x0099ff]
                                                 cornerRadii:CGSizeMake(6, 6)];
        [btnUpdate setTitle:@"开始更新" forState:UIControlStateNormal];
        [btnUpdate addTarget:self
                      action:@selector(touchUpdate)
            forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btnUpdate];
        [btnUpdate mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(labelDesc.mas_bottom).offset(8);
            make.bottom.equalTo(self).offset(-16);
            make.height.equalTo(@32);
            make.width.equalTo(@100);
            make.centerX.equalTo(self);
        }];
        
        UIButton *btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSkip setTitle:@"忽略" forState:UIControlStateNormal];
        btnSkip.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnSkip addTarget:self
                    action:@selector(touchSkip)
          forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btnSkip];
        [btnSkip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(btnUpdate.mas_right).offset(8);
            make.bottom.equalTo(btnUpdate);
        }];
        
        self.btnSkip = btnSkip;
    }
    
    return self;
}

- (void)setData:(NSDictionary *)data {
    _data = data.copy;
    
    NSString *force = YUCLOUD_VALIDATE_STRING(data[@"is_force"]);
    self.btnSkip.hidden = [force isEqualToString:@"2"];
    self.labelDesc.text = data[@"versionDescribe"];
    [self.labelDesc sizeToFit];
}

- (void)touchUpdate {
    NSString *downloadUrl = self.data[@"downloadUrl"];
    if (downloadUrl) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", downloadUrl]]];
    }
}

- (void)touchSkip {
    [NSUserDefaults skipVersion:self.data[@"versionNum"]];
    [self.delegate skip];
}

@end

@interface VersionView () < VersionContentViewDelegate >

@property (nonatomic, strong) UIView                *backgroundView;
@property (nonatomic, strong) VersionContentView    *contentView;

@end

static BOOL versionUpdating = NO;

@implementation VersionView

+ (void)showVersionViewWithData:(NSDictionary *)data {
    if (!versionUpdating) {
        VersionView *view = [[VersionView alloc] initWithFrame:APP_DELEGATE_WINDOW.bounds data:data];
        [APP_DELEGATE_WINDOW addSubview:view];
    }
}

- (instancetype)initWithFrame:(CGRect)frame data:(NSDictionary *)data {
    if (self = [super initWithFrame:frame]) {
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = .0;
        [self addSubview:backgroundView];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.backgroundView = backgroundView;
        
        VersionContentView *contentView = [VersionContentView new];
        contentView.data = data;
        contentView.alpha = .0;
        contentView.delegate = self;
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self).multipliedBy(.8);
            make.height.equalTo(contentView.mas_width).multipliedBy(.7);
            make.center.equalTo(self);
        }];
        
        self.contentView = contentView;
        
        [self showView];
    }
    
    return self;
}

- (void)showView {
    [UIView animateWithDuration:.3
                     animations:^{
                         self.backgroundView.alpha = .5;
                         self.contentView.alpha = 1.;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)dismissView {
    [UIView animateWithDuration:.3
                     animations:^{
                         self.backgroundView.alpha = .0;
                         self.contentView.alpha = .0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - VersionContentViewDelegate

- (void)skip {
    [self dismissView];
}

@end
