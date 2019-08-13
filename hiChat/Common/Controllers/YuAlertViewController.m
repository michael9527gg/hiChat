//
//  YuAlertViewController.m
//  hiChat
//
//

#import "YuAlertViewController.h"
#import "YuTextField.h"
#import "UIView+Shake.h"

@interface YuAlertViewController ()

@property (atomic, assign)   NSInteger              maxInputLength;
@property (atomic, assign)   NSInteger              minInputLength;

@property (nonatomic, copy)  NSString               *preContent;

@property (nonatomic, strong) UIAlertAction         *okAction;

@end

@implementation YuAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
            viewController:(UINavigationController *)navController
                   okTitle:(NSString *)okTitle
                  okAction:(void (^)(UIAlertAction *))okAction
               cancelTitle:(NSString *)cancelTitle
              cancelAction:(void (^)(UIAlertAction *))cancelAction
                completion:(void (^)(void))completion {
    [self showAlertWithTitle:title
                     message:message
              viewController:navController
                     okTitle:okTitle
                    okAction:okAction
                 cancelTitle:cancelTitle
                cancelAction:cancelAction
              preferredStyle:UIAlertControllerStyleAlert
                  completion:completion];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
            viewController:(UIViewController *)viewController
                   okTitle:(NSString *)okTitle
                  okAction:(void (^)(UIAlertAction *))okAction
               cancelTitle:(NSString *)cancelTitle
              cancelAction:(void (^)(UIAlertAction *))cancelAction
            preferredStyle:(UIAlertControllerStyle)preferredStyle
                completion:(void (^)(void))completion {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:preferredStyle];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:okAction];
    [alert addAction:ok];
    
    if ([cancelTitle length]) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelAction];
        [alert addAction:cancel];
    }
    
    [viewController presentViewController:alert animated:YES completion:completion];
}

+ (YuAlertViewController *)alertWithTitle:(NSString *)title
                                  message:(NSString *)message
                          textPlaceHolder:(NSString *)placeHolder
                                     text:(NSString *)text
                            textMaxLength:(NSInteger)maxInputLength
                            textMinLength:(NSInteger)minInputLength
                             keyboardType:(UIKeyboardType)keyboardType
                                  okTitle:(NSString *)okTitle
                                 okAction:(void (^)(UIAlertAction * _Nonnull, NSString * _Nonnull))okAction
                              cancelTitle:(NSString *)cancelTitle
                             cancelAction:(void (^)(UIAlertAction * _Nonnull))cancelAction
                               completion:(void (^)(void))completion
{
    YuAlertViewController *alert = [YuAlertViewController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    alert.maxInputLength = maxInputLength;
    alert.minInputLength = minInputLength;
    
    WEAK(alert, walert);
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeHolder;
        textField.text = text;
        textField.font = [UIFont systemFontOfSize:18.0];
        textField.keyboardType = keyboardType;
        textField.delegate = [YuTextField commonYuTextTarget];
        
        if (walert.maxInputLength > 0) {
            walert.preContent = text;
            [[NSNotificationCenter defaultCenter] addObserver:walert
                                                     selector:@selector(textFieldTextDidChangeNotification:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:textField];
            [[NSNotificationCenter defaultCenter] addObserver:walert
                                                     selector:@selector(UITextFieldTextDidBeginEditingNotification:)
                                                         name:UITextFieldTextDidBeginEditingNotification
                                                       object:textField];
            
        }
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okTitle
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   UITextField *textField = [alert.textFields firstObject];
                                                   
                                                   okAction(action, textField.text);
                                               }];
    [alert addAction:ok];
    
    alert.okAction = ok;
    if ([cancelTitle length]) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        [alert addAction:cancel];
    }
    
    return alert;
}

- (void)UITextFieldTextDidBeginEditingNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    if (self.minInputLength) {
        self.okAction.enabled = [textField.text length] >= self.minInputLength;
    }
}

- (void)textFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    NSString *lang = [[textField textInputMode] primaryLanguage];
    
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *marked = [textField markedTextRange];
        if (marked) {
            //正在拼音输入中，
            return;
        }
    }
    
    if (self.maxInputLength > 0 && [textField.text length] > self.maxInputLength) {
        textField.text = self.preContent;
        
        [textField shakeView];
        return;
    }
    
    self.preContent = textField.text;
    
    if (self.minInputLength) {
        self.okAction.enabled = [textField.text length] >= self.minInputLength;
    }
}


@end
