//
//  UITextField.h
//  hiChat
//
//

#import <UIKit/UIKit.h>

@class YuTextField;

@protocol YuTextFieldDelegate <UITextFieldDelegate>

@optional

- (void)didTouchRightView:(YuTextField *)yuTextField;

@end

@interface YuTextFieldCommonTarget : NSObject

@end

@interface YuTextField : UITextField

@property (atomic, assign) NSInteger    maxInputLength;
@property (atomic, assign) BOOL         upperCase;
@property (atomic, assign) BOOL         lowerCase;
@property (atomic, assign) BOOL         filterEmoji;
@property (nonatomic, weak) id <YuTextFieldDelegate> yuTextFieldDelegate;

+ (id <YuTextFieldDelegate>)commonYuTextTarget;

- (void)setLeftPadding:(NSInteger)padding mode:(UITextFieldViewMode)mode;
- (void)setRightPadding:(NSInteger)padding mode:(UITextFieldViewMode)mode;
- (void)setLeftImage:(UIImage *)image padding:(NSInteger)padding mode:(UITextFieldViewMode)mode;
- (void)setRightImage:(UIImage *)image padding:(NSInteger)padding mode:(UITextFieldViewMode)mode;

- (void)setMaxInputLength:(NSInteger)maxInputLength delegate:(id < YuTextFieldDelegate >)delegate;
- (void)setFilterEmoji:(BOOL)filterEmoji delegate:(id < YuTextFieldDelegate >)delegate;


@end
