//
//  GuidePageViewController.m
//  Kaixin
//
//

#import "GuidePageViewController.h"
#import "UniManager.h"

@interface GuidePageViewController ()

@end

@implementation GuidePageViewController

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(touchBackground)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)noti {
    UIView *aa = [self.view firstResponder];
    
    NSDictionary *dict      = noti.userInfo;
    CGRect keyboardFrame    = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat maxY            = CGRectGetMaxY(aa.frame) + 16;
    
    if (keyboardFrame.origin.y < maxY) {
        [UIView animateWithDuration:duration animations:^{
            self.view.transform     = CGAffineTransformMakeTranslation(0, -(maxY-keyboardFrame.origin.y));
        }];
    }
    else if (CGRectGetMinY(aa.frame) < 16) {
        [UIView animateWithDuration:duration animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    NSDictionary *dict      = noti.userInfo;
    NSTimeInterval duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchBackground {
    [self.view endEditing:YES];
}

- (void)touchContinue {
    [self.delegate continueWithCurrent:self];
}

@end
