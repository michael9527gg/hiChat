//
//  UniManager.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "UniManager.h"
#import "AppDelegate.h"
#import "TextEditViewController.h"
#import "MainNavigationController.h"
#import "ContactsSelectViewController.h"
#import "MainTabBarController.h"

@interface UniManager () < GFPhotoBrowserNavigationDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ContactsSelectDelegate, TextEditDelegate >

@property (nonatomic, copy)   CommonBlock       selectImageCompletion;
@property (nonatomic, assign) BOOL              selectImageUpload;
@property (nonatomic, assign) BOOL              selectImageSquared;

@property (nonatomic, copy)   CommonBlock       selectContactsCompletion;
@property (nonatomic, copy)   CommonBlock       textEditCompletion;

@end

@implementation UniManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static UniManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [UniManager new];
    });
    
    return client;
}

- (void)selectImageWithLimit:(NSInteger)limit
                        type:(PHAssetMediaType)mediaType
              viewController:(UIViewController *)viewController
                     squared:(BOOL)squared
                      upload:(BOOL)upload
              withCompletion:(CommonBlock)completion {
    self.selectImageCompletion = completion;
    self.selectImageUpload = upload;
    self.selectImageSquared = squared;
    
    if (mediaType == PHAssetMediaTypeVideo) {
        //视频只能单选
        limit = 1;
    }
    
    UIAlertControllerStyle alertControllerStyle = UIAlertControllerStyleActionSheet;
    if([self currentDeviceType] == UIUserInterfaceIdiomPad) {
        alertControllerStyle = UIAlertControllerStyleAlert;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"请选择来源"
                                                            preferredStyle:alertControllerStyle];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相机"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                           UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                           picker.delegate = self;
                                                           picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                           [viewController presentViewController:picker animated:YES completion:nil];
                                                       }
                                                   }];
    
    void(^selectFromLibray)(PHAssetMediaType) = ^(PHAssetMediaType mediaType) {
        GFPhotoBrowserNavigationController *photo = [[GFPhotoBrowserNavigationController alloc] initWithType:PHAssetCollectionTypeSmartAlbum
                                                                                                     subType:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                                                   mediaType:mediaType
                                                                                     allowsMultipleSelection:limit > 1
                                                                                                  returnSize:CGSizeMake(1080, 1080)
                                                                                             imageCountLimit:limit
                                                                                             fileLengthLimit:1024 * 1024 * 10];
        photo.delegate = self;
        
        [viewController presentViewController:photo
                                     animated:YES
                                   completion:nil];
    };
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"相册"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        selectFromLibray(mediaType);
                                                    }];
    
    if (mediaType == PHAssetMediaTypeVideo) {
        selectFromLibray(mediaType);
    }
    else {
        [alert addAction:camera];
        [alert addAction:library];
        [alert addAction:[UIAlertAction actionWithTitle:YUCLOUD_STRING_CANCEL
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (self.selectImageCompletion) {
                                                        self.selectImageCompletion(NO, nil);
                                                    }
                                                }]];
        
        [viewController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)selectImageFinishedWithImage:(NSArray<UIImage *> *)images {
    NSMutableArray *arr = [NSMutableArray array];
    
    if (self.selectImageUpload) {
        MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                                 mode:MBProgressHUDModeIndeterminate
                                                image:nil
                                              message:@"上传中"
                                            delayHide:NO
                                           completion:nil];
        
        dispatch_group_t group = dispatch_group_create();
        for (UIImage *item in images) {
            UIImage *image = [item imageResized:768];
            
            if (self.selectImageSquared) {
                CGSize size = image.size;
                CGFloat cropSize = size.width > size.height?size.height:size.width;
                CGRect rect = CGRectMake((size.width - cropSize) / 2, (size.height - cropSize) / 2, cropSize, cropSize);
                image = [image croppedImage:rect];
            }
            
            dispatch_group_enter(group);
            [[UploadManager manager] uploadData:UIImageJPEGRepresentation(image, .75)
                                        fileExt:@"jpg"
                                       progress:^(NSUInteger completedBytes, NSUInteger totalBytes) {
                                           
                                       }
                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                         if (success) {
                                             NSString *url = info[@"url"];
                                             [arr addObject:url];
                                         }
                                         
                                         dispatch_group_leave(group);
                                     }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [MBProgressHUD finishHudWithResult:arr.count > 0
                                           hud:hud
                                     labelText:arr.count > 0?YUCLOUD_STRING_SUCCESS:YUCLOUD_STRING_FAILED
                                    completion:^{
                                        if (self.selectImageCompletion) {
                                            self.selectImageCompletion(arr.count > 0, @{@"images" : arr.copy});
                                        }
                                    }];
        });
    }
    else {
        if (self.selectImageCompletion) {
            self.selectImageCompletion(images > 0, @{@"images" : images?:@[]});
        }
    }
}

- (UINavigationController *)topNavigationController {
    UIViewController *viewController = [AppDelegate appDelegate].window.rootViewController;
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)viewController;
        UINavigationController *nav = tab.selectedViewController;
        return nav;
    }
    else if ([viewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)viewController;
    }
    
    return nil;
}

- (UIViewController *)topViewController {
    UINavigationController *nav = [self topNavigationController];
    if (nav.presentedViewController) {
        return nav.presentedViewController;
    }
    else {
        return nav.topViewController;
    }
}

- (void)startTextEdit:(NSString *)text completion:(CommonBlock)completion {
    [self startTextEdit:text
            placeholder:nil
              maxLength:1000
             completion:completion];
}

- (void)startTextEdit:(NSString *)text placeholder:(NSString *)placeholder maxLength:(NSInteger)maxLength completion:(CommonBlock)completion {
    TextEditViewController *edit = [TextEditViewController new];
    edit.delegate = self;
    edit.text = text;
    edit.placeholder = placeholder;
    edit.maxLength = maxLength;
    
    self.textEditCompletion = completion;
    [[self topViewController] presentViewController:[[MainNavigationController alloc] initWithRootViewController:edit]
                                           animated:YES
                                         completion:nil];
}

- (void)selectContactsWithCompletion:(CommonBlock)completion {
    self.selectContactsCompletion = completion;
    ContactsSelectViewController *select = [ContactsSelectViewController new];
    select.delegate = self;
    [[self topViewController] presentViewController:[[MainNavigationController alloc] initWithRootViewController:select]
                                           animated:YES
                                         completion:nil];
}

- (UIUserInterfaceIdiom)currentDeviceType {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIUserInterfaceIdiomPad;
    } else {
        return UIUserInterfaceIdiomPhone;
    }
}

#pragma mark - GFPhotoBrowserNavigationDelegate

- (void)browserNavi:(GFPhotoBrowserNavigationController *)nav selectImages:(NSArray<UIImage *> *)images {
    if (images.count) {
        [self selectImageFinishedWithImage:images];
    }
    else {
        if (self.selectImageCompletion) {
            self.selectImageCompletion(NO, nil);
        }
    }
}

- (void)browserNavi:(GFPhotoBrowserNavigationController *)nav
       selectVideos:(NSArray<NSDictionary *> *)videos {
    if (videos.count) {
        
    }
    else {
        if (self.selectImageCompletion) {
            self.selectImageCompletion(NO, nil);
        }
    }
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   UIImage *image = info[UIImagePickerControllerOriginalImage];
                                   if (image) {
                                       [self selectImageFinishedWithImage:@[image]];
                                   }
                               }];
}

#pragma mark - ContactsSelectDelegate

- (void)didSelectedCancel:(ContactsSelectViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES
                                       completion:nil];
}

#pragma mark - TextEditDelegate

- (void)textEditDidCancel:(TextEditViewController *)editor {
    [editor dismissViewControllerAnimated:YES completion:^{
        if (self.textEditCompletion) {
            self.textEditCompletion(NO, nil);
        }
    }];
}

- (void)textEditDidSave:(TextEditViewController *)editor {
    [editor dismissViewControllerAnimated:YES completion:^{
        if (self.textEditCompletion) {
            self.textEditCompletion(YES, @{@"text": editor.text});
        }
    }];
}

#pragma mark - ContactsSelectDelegate

- (void)selectWithContacts:(NSArray *)contacts
                   purpose:(ContactSelectPurpose)purpose
                 mulSelect:(BOOL)mulSelect {

}

@end
