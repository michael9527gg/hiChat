//
//  WebViewController.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKWebViewJavascriptBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebViewController : UIViewController

@property (nonatomic, readonly) WKWebView   *webView;

- (instancetype)initWithUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
