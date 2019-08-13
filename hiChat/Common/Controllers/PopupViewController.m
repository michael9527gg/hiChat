//
//  PopupViewController.m
//  XNN
//
//  Created by zhangliyong on 16/8/15.
//  Copyright © 2016年 VIROYAL. All rights reserved.
//

#import "PopupViewController.h"

@interface PopupViewController ()

@end

@implementation PopupViewController

- (instancetype)init {
    if (self = [super init]) {
        CGRect rect = [UIScreen mainScreen].bounds;
        self.contentSizeInPopup = CGSizeMake(CGRectGetWidth(rect) - 40, CGRectGetHeight(rect) - 140);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popupOnViewController:(UIViewController *)viewController
                 cornerRadius:(CGFloat)cornerRadius
              transitionStyle:(STPopupTransitionStyle)transitionStyle
                        style:(STPopupStyle)style
                   completion:(void (^)(void))completion {
    STPopupController *popup = [[STPopupController alloc] initWithRootViewController:self];
    
    popup.containerView.layer.cornerRadius = cornerRadius;
    popup.transitionStyle = transitionStyle;
    popup.style = style;
    popup.navigationBarHidden = YES;
    [popup presentInViewController:viewController completion:completion];
}

- (void)hidePopup:(BOOL)animated
       completion:(void (^)(void))completion {
    [self hidePopup:animated afterDelay:0 completion:completion];
}

- (void)hidePopup:(BOOL)animated
       afterDelay:(NSTimeInterval)delay
       completion:(void (^)(void))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:animated completion:completion];
    });
}

@end

