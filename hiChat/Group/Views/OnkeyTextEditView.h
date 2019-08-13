//
//  OnkeyTextEditView.h
//  hiChat
//
//  Created by Polly polly on 31/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnkeyTextEditView : UITextView

@property (nonatomic, copy)     NSString                    *placeHolder;
@property (nonatomic, assign)   NSInteger                   maxLength;
@property (nonatomic, assign)   BOOL                        hasBorder;

@end
