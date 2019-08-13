//
//  GFPhotoCropViewController.h
//  GFPhotoBrowser
//
//

#import <UIKit/UIKit.h>

@class GFPhotoCropViewController;

@protocol GFPhotoCropViewControllerDelegate <NSObject>

- (void)photoCropViewControllerDidCancel:(GFPhotoCropViewController *)cropViewController;
- (void)photoCropViewController:(GFPhotoCropViewController *)cropViewController
         didFinishCroppingImage:(UIImage *)image;

@end

@interface GFPhotoCropViewController : UIViewController

@property (nonatomic, weak) id<GFPhotoCropViewControllerDelegate>       delegate;
@property (assign)          CGFloat                                     outputWidth;

- (instancetype)initWithImage:(UIImage *)image fixedRatio:(CGFloat)ratio;

@end
