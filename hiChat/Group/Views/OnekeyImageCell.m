//
//  OnekeyImageCell.m
//  hiChat
//
//  Created by Polly polly on 31/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "OnekeyImageCell.h"

@interface OnekeyImageCell()

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation OnekeyImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        CONTENT_VIEW.backgroundColor = [UIColor clearColor];
        
        self.iconView = [[UIImageView alloc] init];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(CONTENT_VIEW);
            make.top.equalTo(CONTENT_VIEW).offset(12);
        }];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.hidden = YES;
        [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"ic_onekey_delete"]
                                  forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self
                           action:@selector(touchDelete)
                 forControlEvents:UIControlEventTouchUpInside];
        [CONTENT_VIEW addSubview:self.deleteBtn];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.iconView.mas_right);
            make.centerY.equalTo(self.iconView.mas_top);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    
    return self;
}

-(void)startShakeAnimation:(UIView *)shakeView {
    CAKeyframeAnimation *tranAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"] ;
    NSNumber *leftN = @(M_PI_2/90*3) ;
    NSNumber *rightN = @(M_PI_2/90*(-3)) ;
    
    tranAnim.values = @[ leftN , rightN , leftN] ;
    
    tranAnim.duration = .2;
    
    tranAnim.removedOnCompletion = NO;
    
    tranAnim.repeatCount = MAXFLOAT;
    
    tranAnim.autoreverses = YES;
    
    tranAnim.fillMode = kCAFillModeForwards;
    
    [shakeView.layer addAnimation:tranAnim
                           forKey:@"shakeAnimation"];
}

- (void)endShakeAnimation:(UIView *)shakeView {
    [shakeView.layer removeAnimationForKey:@"shakeAnimation"];
}

- (void)touchDelete {
    if(self.delegate) {
        [self.delegate userChooseDelete:self];
    }
}

- (void)setShowDelete:(BOOL)showDelete {
    self.deleteBtn.hidden = !showDelete;
    
    if(showDelete) {
        [self startShakeAnimation:self];
    } else {
        [self endShakeAnimation:self];
    }
}

@end
