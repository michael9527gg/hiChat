//
//  GuideViewController.h
//  Kaixin
//
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, GuideViewMask) {
    GuideOpening        = 1 << 0,
    GuideLogin          = 1 << 2,
    GuideAll            = GuideOpening | GuideLogin,
    GuideStartup        = GuideAll | (1 << 3)
};

@class GuideViewController;

@protocol GuideViewDelegate < NSObject >

- (void)guideViewDidFinished:(GuideViewController *)viewController;

@optional

- (void)loginWithResult:(BOOL)success;

@end

@interface GuideViewController : UIViewController

@property (nonatomic, weak)     id<GuideViewDelegate>   delegate;

- (instancetype)initWithMask:(NSUInteger)guideMask;

- (void)hideAnimated:(BOOL)animated;

@end
