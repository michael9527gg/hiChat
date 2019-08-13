//
//  YuAlertViewController.h
//  hiChat
//
//

#import <UIKit/UIKit.h>

#define hiChat_NAME_MAX_LENGTH     20

@interface YuAlertViewController : UIAlertController

+ (void)showAlertWithTitle:(nullable NSString *)title
                   message:(nullable NSString *)message
            viewController:(nullable UIViewController *)viewController
                   okTitle:(nullable NSString *)okTitle
                  okAction:(nullable void (^)(UIAlertAction * _Nonnull action))okAction
               cancelTitle:(nullable NSString *)cancelTitle
              cancelAction:(nullable void (^)(UIAlertAction * _Nonnull action))cancelAction
                completion:(nullable void (^)(void))completion;

+ (void)showAlertWithTitle:(nullable NSString *)title
                   message:(nullable NSString *)message
            viewController:(nullable UIViewController *)viewController
                   okTitle:(nullable NSString *)okTitle
                  okAction:(nullable void (^)(UIAlertAction * _Nonnull action))okAction
               cancelTitle:(nullable NSString *)cancelTitle
              cancelAction:(nullable void (^)(UIAlertAction * _Nonnull action))cancelAction
            preferredStyle:(UIAlertControllerStyle)preferredStyle
                completion:(nullable void (^)(void))completion;

+ (nullable YuAlertViewController *)alertWithTitle:(nullable NSString *)title
                                           message:(nullable NSString *)message
                                   textPlaceHolder:(nullable NSString *)placeHolder
                                              text:(nullable NSString *)text
                                     textMaxLength:(NSInteger)maxInputLength
                                     textMinLength:(NSInteger)minInputLength
                                      keyboardType:(UIKeyboardType)keyboardType
                                           okTitle:(nullable NSString *)okTitle
                                          okAction:(nullable void (^)(UIAlertAction * _Nonnull action, NSString * _Nonnull text))okAction
                                       cancelTitle:(nullable NSString *)cancelTitle
                                      cancelAction:(nullable void (^)(UIAlertAction * _Nonnull))cancelAction
                                        completion:(nullable void (^)(void))completion;

@end
