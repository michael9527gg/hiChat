//
//  UIImageView+GF.m
//  GFCocoaTools
//
//  Created by zhangliyong on 2017/3/14.
//  Copyright © 2017年 zhangliyong@gmail.com. All rights reserved.
//

#import "UIImageView+GF.h"

@implementation UIImageView (GF)

- (void)setImage:(UIImage *)image fade:(BOOL)fade {
    if (self.image != image) {
        [UIView transitionWithView:self
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.image = image;
                        }
                        completion:nil];
    }
    else {
        self.image = image;
    }
}

@end
