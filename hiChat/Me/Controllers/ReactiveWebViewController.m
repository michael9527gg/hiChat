//
//  ReactiveViewController.m
//  hiChat
//
//  Created by zhangliyong on 23/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "ReactiveWebViewController.h"
#import "VersionView.h"

@interface ReactiveWebViewController ()

@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@end

@implementation ReactiveWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [WKWebViewJavascriptBridge enableLogging];
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setupInstance:self.webView];
    [self.bridge setWebViewDelegate:self];
    [self registerWebHandlers];
}

- (void)registerWebHandlers {
    [self.bridge registerHandler:@"getVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[AccountManager manager] requestVersionWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                responseCallback(@{@"string": [NSString stringWithFormat:@"%@(build %@)", [[NSBundle mainBundle] bundleShortVersion], [[NSBundle mainBundle] bundleVersion]],
                                   @"has_new": @(YES)});
            }
            else {
                responseCallback(@{@"string": [NSString stringWithFormat:@"%@(build %@)", [[NSBundle mainBundle] bundleShortVersion], [[NSBundle mainBundle] bundleVersion]],
                                   @"has_new": @(NO)});
            }
        }];
    }];
    
    [self.bridge registerHandler:@"updateVersion"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             [[AccountManager manager] requestVersionWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                 if (success) {
                                     [VersionView showVersionViewWithData:info];
                                 }
                                 
                                 responseCallback(@"OK");
                                 
                             }];
                         }];
    
    [self.bridge registerHandler:@"getAppName"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             NSDictionary *info = [NSBundle mainBundle].infoDictionary;
                             responseCallback(@{@"name": info[@"CFBundleDisplayName"]});
                         }];
}

@end
