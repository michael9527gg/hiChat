//
//  PhotoViewer.m
//  Unilife
//
//  Created by zhangliyong on 2017/7/31.
//  Copyright © 2017年 南京远御网络科技有限公司. All rights reserved.
//

#import "PhotoViewer.h"
#import <UIImage+GIF.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIImage+MultiFormat.h>

@interface PhotoViewer() < UIScrollViewDelegate >

@property (nonatomic, strong)   UIImageView     *imageView;
@property (nonatomic, strong)   UIScrollView    *scrollView;
@property (nonatomic, strong)   UIPageControl   *pageControl;
@property (nonatomic, strong)   UIButton        *saveBtn;

@property (nonatomic, copy)     NSString        *imageUrl;
@property (nonatomic, strong)   NSData          *data;

@end

@implementation PhotoViewer

+ (void)showImage:(NSString *)imageUrl {
    PhotoViewer *viewer = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    viewer.imageUrl = imageUrl;
    [APP_DELEGATE_WINDOW addSubview:viewer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0;
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = 1;
        }];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.delegate = self;
        self.scrollView.maximumZoomScale = 5;
        self.scrollView.zoomScale = 1;
        self.scrollView.bounces = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touchDismiss)];
        [self.scrollView addGestureRecognizer:tap];
        [self addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:self.imageView];
        
        self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.saveBtn.frame = CGRectMake(self.bounds.size.width-100,
                                        self.bounds.size.height-60,
                                        80,
                                        40);
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        self.saveBtn.hidden = YES;
        self.saveBtn.layer.cornerRadius = 5;
        self.saveBtn.layer.masksToBounds = YES;
        [self.saveBtn setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
        [self.saveBtn setBackgroundColor:[UIColor colorFromHex:0x0099ff]];
        self.saveBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [self.saveBtn addTarget:self
                         action:@selector(savePhoto)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.saveBtn];
    }
    
    return self;
}

- (void)touchDismiss {
    if(self.scrollView.zoomScale == 1.0) {
        [UIView animateWithDuration:.3
                         animations:^{
                             self.alpha = .1;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

- (void)dealloc {
    
}

- (void)setData:(NSData *)data {
    _data = data;
    if(data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.saveBtn.hidden = NO;
        });
    }
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    
//    if([imageUrl hasSuffix:@".gif"]) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
//        [self bringSubviewToFront:hud];
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            self.data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [hud hideAnimated:YES];
//                self.imageView.image = [UIImage sd_imageWithGIFData:self.data];
//            });
//        });
//    }
//    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self
                                                  animated:YES];
        [self bringSubviewToFront:hud];
        hud.mode = MBProgressHUDModeDeterminate;
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                          placeholderImage:nil
                                   options:SDWebImageRetryFailed
                                  progress:^(NSInteger receivedSize,
                                             NSInteger expectedSize,
                                             NSURL * _Nullable targetURL) {
                                      CGFloat progress = receivedSize/(CGFloat)expectedSize;
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          hud.progress = progress;
                                      });
                                  }
                                 completed:^(UIImage * _Nullable image,
                                             NSError * _Nullable error,
                                             SDImageCacheType cacheType,
                                             NSURL * _Nullable imageURL) {
                                     self.data = [image sd_imageData];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [hud hideAnimated:YES];
                                     });
                                 }];
//    }
}

- (void)savePhoto {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if(status == PHAuthorizationStatusAuthorized) {
        [self saveToLocal];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized) {
                [self saveToLocal];
            }
        }];
    }
}

- (void)saveToLocal {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if(self.data) {
        [library writeImageDataToSavedPhotosAlbum:self.data
                                         metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                                                              withResult:!error
                                                               labelText:error?@"保存失败":@"已保存到系统相册"
                                                               delayHide:YES
                                                              completion:nil];
                                      });
                                  }];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                        scrollView.contentSize.height * 0.5 + offsetY);
}

@end
