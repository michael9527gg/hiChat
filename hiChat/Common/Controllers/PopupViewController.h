//
//  PopupViewController.h
//  XNN
//
//  Created by zhangliyong on 16/8/15.
//  Copyright © 2016年 VIROYAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPopup.h"
#import "STPopupController.h"

#define YUCLOUD_CAR_POPUP_CORNER_RADIUS     8

NS_ASSUME_NONNULL_BEGIN

@interface PopupViewController : UIViewController

- (void)popupOnViewController:(UIViewController *)viewController
                 cornerRadius:(CGFloat)cornerRadius
              transitionStyle:(STPopupTransitionStyle)transitionStyle
                        style:(STPopupStyle)style
                   completion:(nullable void (^)(void))completion;

- (void)hidePopup:(BOOL)animated
       completion:(nullable void (^)(void))completion;

- (void)hidePopup:(BOOL)animated
       afterDelay:(NSTimeInterval)delay
       completion:(nullable void (^)(void))completion;


@end

NS_ASSUME_NONNULL_END

