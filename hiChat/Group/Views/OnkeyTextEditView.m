//
//  OnkeyTextEditView.m
//  hiChat
//
//  Created by Polly polly on 31/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "OnkeyTextEditView.h"

@interface OnkeyTextEditView()< UITextViewDelegate >

@property (nonatomic, copy)     NSString    *input;

@end

@implementation OnkeyTextEditView

- (instancetype)init {
    if(self = [super init]) {
        self.maxLength = 120;
        self.placeHolder = @"说点儿什么吧！";
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.layer.borderWidth = .5;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.font = [UIFont systemFontOfSize:16];
    }
    return self;
}

- (void)setHasBorder:(BOOL)hasBorder {
    self.layer.borderWidth = hasBorder?2.0:0;
}

#pragma mark - drawrect

- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSString * placeholder = self.input.length>0 ?  @"" : self.placeHolder;
    NSDictionary *dic = @{
                          NSForegroundColorAttributeName : [UIColor lightGrayColor],
                          NSFontAttributeName : [UIFont systemFontOfSize:16]
                          } ;
    
    [placeholder drawAtPoint:CGPointMake(7, 7) withAttributes:dic];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChangeSelection:(UITextView *)textView {
    self.input = textView.text;
    [self setNeedsDisplay] ;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([textView.text length]+text.length >self.maxLength ||
        [textView.text length] > self.maxLength) {
        return  NO;
    }
    
    return YES;
}

@end
