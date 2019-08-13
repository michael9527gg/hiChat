//
//  WebViewController.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController () < WKNavigationDelegate, WKUIDelegate >

@property (nonatomic, copy)   NSURL         *url;
@property (nonatomic, strong) WKWebView     *webView;

@end

@implementation WebViewController

- (instancetype)initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        self.url = url;
    }

    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];

    WKWebView *webView = [WKWebView new];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.allowsBackForwardNavigationGestures = YES;
    [view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(view.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(view.mas_safeAreaLayoutGuideBottom);
        } else {
            // Fallback on earlier versions
            make.edges.equalTo(view);
        }
    }];

    self.webView = webView;

    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"%s start loading url: %@", __PRETTY_FUNCTION__, self.url);
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark - WKNavigationDelegate, WKUIDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.title = webView.title;
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end
