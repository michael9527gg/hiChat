//
//  UITextField.m
//  hiChat
//
//

#import "YuTextField.h"
#import "UIView+Shake.h"

YuTextFieldCommonTarget *textCommonDelegateTarget = nil;


@interface YuTextFieldCommonTarget () < YuTextFieldDelegate >

@end

@implementation YuTextFieldCommonTarget

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *lang = [[textField textInputMode] primaryLanguage];

    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *marked = [textField markedTextRange];
        if (marked) {
            //正在拼音输入中，
            return YES;
        }
    }

#if YUCLOUD_WEILIAO
    //过滤 emoji
    NSInteger len = [string length];
    BOOL emojiFound = NO;

    size_t size = (len + 1) * sizeof(unichar);
    unichar *buffer = malloc(size);
    memset(buffer, 0, size);
    [string getCharacters:buffer];

    for (int i = 0; i < len; i++) {
        if (
            (buffer[i] >= 0x2600 && buffer[i] <= 0x26ff) ||
            (buffer[i] >= 0x2700 && buffer[i] <= 0x27ff) ||
            (buffer[i] >= 0xf100 && buffer[i] <= 0xf9ff) ||
            (buffer[i] >= 0xd100 && buffer[i] <= 0xd9ff)
            ) {
            emojiFound = YES;
            break;
        }
    }

    free(buffer);
    if (emojiFound) {
        return NO;
    }
#endif //YUCLOUD_WEILIAO

    if ([textField isKindOfClass:[YuTextField class]]) {
        YuTextField *field = (YuTextField *)textField;

        if (field.maxInputLength && field.maxInputLength < [field.text length] + [string length] - range.length) {
            [field shakeView];
            return NO;
        }
    }

    return YES;
}


@end



@interface YuTextField ()

@property (nonatomic, copy)     NSString        *preContent;

@end

@implementation YuTextField

+ (id <YuTextFieldDelegate>)commonYuTextTarget {
    if (textCommonDelegateTarget == nil) {
        textCommonDelegateTarget = [[YuTextFieldCommonTarget alloc] init];
    }

    return textCommonDelegateTarget;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidBeginEditingNotification:) name:UITextFieldTextDidBeginEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidEndEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self];
    }

    return self;
}

- (void)setLeftPadding:(NSInteger)padding mode:(UITextFieldViewMode)mode
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, padding, padding)];
    self.leftView = paddingView;
    self.leftViewMode = mode;
}

- (void)setRightPadding:(NSInteger)padding mode:(UITextFieldViewMode)mode
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, padding, padding)];
    self.rightView = paddingView;
    self.rightViewMode = mode;
}

- (void)setLeftImage:(UIImage *)image padding:(NSInteger)padding mode:(UITextFieldViewMode)mode
{
    UIView *view = [[UIView alloc] init];
    self.leftView = view;
    self.leftViewMode = mode;
    [self addSubview:view];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [view addSubview:imageView];

    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(@49);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
    }];
}

- (void)setRightImage:(UIImage *)image padding:(NSInteger)padding mode:(UITextFieldViewMode)mode
{
    UIView *view = [[UIView alloc] init];
    self.rightView = view;
    self.rightViewMode = mode;
    [self addSubview:view];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(touchDelete)];
    [imageView addGestureRecognizer:tap];
    [view addSubview:imageView];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(@49);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
    }];
}

- (void)touchDelete {
    if(self.yuTextFieldDelegate && [self.yuTextFieldDelegate respondsToSelector:@selector(didTouchRightView:)]) {
        [self.yuTextFieldDelegate didTouchRightView:self];
    }
}

- (void)setMaxInputLength:(NSInteger)maxInputLength delegate:(id<YuTextFieldDelegate>)delegate
{
    self.maxInputLength = maxInputLength;
    self.delegate = delegate;
}

- (void)setFilterEmoji:(BOOL)filterEmoji delegate:(id<YuTextFieldDelegate>)delegate {
    _filterEmoji = filterEmoji;
    self.delegate = delegate;
}

- (void)textFieldTextDidBeginEditingNotification:(NSNotification *)notification
{
    YuTextField *textField = notification.object;

    self.preContent = textField.text;
}

- (void)textFieldTextDidEndEditingNotification:(NSNotification *)notification
{

}

- (void)textFieldTextDidChangeNotification:(NSNotification *)notification
{
    YuTextField *textField = notification.object;

    NSString *lang = [[textField textInputMode] primaryLanguage];

    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *marked = [textField markedTextRange];
        if (marked) {
            //正在拼音输入中，
            return;
        }
    }

    if (_maxInputLength > 0 && [textField.text length] > _maxInputLength) {
        textField.text = self.preContent;

        [textField shakeView];
        return;
    }

    NSString *content = textField.text;
    if (_upperCase) {
        content = [content uppercaseString];
    }
    else if (_lowerCase) {
        content = [content lowercaseString];
    }

    textField.text = content;
    self.preContent = content;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
