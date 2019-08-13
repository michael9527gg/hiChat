//
//  NotificationDetailViewController.m
//  hiChat
//
//  Created by Polly polly on 27/02/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "NotificationDetailViewController.h"
#import <SafariServices/SafariServices.h>

@interface NotificationDetailViewController () < UITextViewDelegate >

@end

@implementation NotificationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.data.title;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds
                                               textContainer:nil];
    textView.font = [UIFont systemFontOfSize:16];
    textView.editable = NO;
    textView.dataDetectorTypes = UIDataDetectorTypeAll;
    textView.textColor = [UIColor darkGrayColor];
    textView.text = self.data.content;
    textView.delegate = self;
    [self.view addSubview:textView];
    
    self.data.read = YES;
    [[NotificationDataSource sharedClient] addObject:self.data
                                          entityName:[NotificationEntity entityName]];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSRange range = [URL.scheme rangeOfString:@"http" options:NSCaseInsensitiveSearch];
    if (range.location == 0 && range.length > 0) {
        // 这是个网址
        if (@available(iOS 9.0, *)) {
            SFSafariViewController *web = [[SFSafariViewController alloc] initWithURL:URL];
            
            [[UniManager manager].topViewController presentViewController:web
                                                                 animated:YES
                                                               completion:nil];
            
            return NO;
        }
    }
    
    return YES;
}

@end
