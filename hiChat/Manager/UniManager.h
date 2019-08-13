//
//  UniManager.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "BaseManager.h"
#import "AccountManager.h"
#import "ContactsManager.h"
#import "UploadManager.h"
#import "GFPhotoBrowser.h"

NS_ASSUME_NONNULL_BEGIN

#define HICHAT_MAIN_BGCOLOR [UIColor colorFromString:@"0xf0f0f6"]

@interface UniManager : BaseManager

- (UINavigationController *)topNavigationController;
- (UIViewController *)topViewController;

- (void)selectImageWithLimit:(NSInteger)limit
                        type:(PHAssetMediaType)mediaType
              viewController:(UIViewController *)viewController
                     squared:(BOOL)squared
                      upload:(BOOL)upload
              withCompletion:(CommonBlock)completion;

- (void)startTextEdit:(nullable NSString *)text
           completion:(nullable CommonBlock)completion;

- (void)startTextEdit:(nullable NSString *)text
          placeholder:(nullable NSString *)placeholder
            maxLength:(NSInteger)maxLength
           completion:(nullable CommonBlock)completion;

- (void)selectContactsWithCompletion:(nullable CommonBlock)completion;

- (UIUserInterfaceIdiom)currentDeviceType;

@end

NS_ASSUME_NONNULL_END
