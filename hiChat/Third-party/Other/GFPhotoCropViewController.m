//
//  GFPhotoCropViewController.m
//  GFPhotoBrowser
//
//

#import "GFPhotoCropViewController.h"
#import "NSBundle+GFPhotoBrowser.h"
#import <Masonry/Masonry.h>

@interface UIView (mask)

@end

@implementation UIView (mask)

- (instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color alpha:(CGFloat)alpha {
    if (self = [self initWithFrame:frame]) {
        self.backgroundColor = color;
        self.alpha = alpha;
    }
    
    return self;
}

@end
@interface CropContentView : UIView

@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, copy)   UIImage           *image;

@end

@implementation CropContentView

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self init]) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = image;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.
                                                          constant:.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.
                                                          constant:.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.
                                                          constant:.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.
                                                          constant:.0]];
    }
    
    return self;
}

@end

#pragma mark - CropGridView

@interface CropGridView : UIView

@end

@implementation CropGridView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    
    return self;
}

@end

#pragma mark - GFCropView

@interface GFCropView : UIView < UIScrollViewDelegate >

@property (nonatomic, copy)   UIImage               *image;
@property (nonatomic, assign) CGFloat               fixedRatio;

@property (nonatomic, strong) UIScrollView          *scrollView;
@property (nonatomic, strong) CropContentView       *contentView;
@property (nonatomic, strong) CropGridView          *gridView;

@property (nonatomic, assign) CGFloat               centerY;

@end

@implementation GFCropView

- (instancetype)initWithImage:(UIImage *)image fixedRatio:(CGFloat)ratio {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.image = image;
        self.fixedRatio = ratio;
        
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.bounces = YES;
        self.scrollView.layer.anchorPoint = CGPointMake(.5, .5);
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.alwaysBounceVertical = YES;
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 10;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.clipsToBounds = NO;
        [self addSubview:self.scrollView];
        
        self.contentView = [[CropContentView alloc] initWithImage:image];
        [self.scrollView addSubview:self.contentView];
        
        self.gridView = [[CropGridView alloc] init];
        [self addSubview:self.gridView];
        
        [self setupMasks];
    }
    
    return self;
}

- (void)setupMasks {
    UIView *leftMask = [[UIView alloc] initWithFrame:CGRectZero
                                     backgroundColor:[UIColor grayColor]
                                               alpha:.7];
    [self addSubview:leftMask];
    [leftMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.right.equalTo(self.gridView.mas_left);
        make.bottom.equalTo(self);
    }];
    
    UIView *topMask = [[UIView alloc] initWithFrame:CGRectZero
                                    backgroundColor:[UIColor grayColor]
                                              alpha:.7];
    [self addSubview:topMask];
    [topMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gridView);
        make.top.equalTo(self);
        make.right.equalTo(self.gridView);
        make.bottom.equalTo(self.gridView.mas_top);
    }];
    
    UIView *rightMask = [[UIView alloc] initWithFrame:CGRectZero
                                      backgroundColor:[UIColor grayColor]
                                                alpha:.7];
    [self addSubview:rightMask];
    [rightMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gridView.mas_right);
        make.top.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    UIView *bottomMask = [[UIView alloc] initWithFrame:CGRectZero
                                       backgroundColor:[UIColor grayColor]
                                                 alpha:.7];
    [self addSubview:bottomMask];
    [bottomMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gridView);
        make.right.equalTo(self.gridView);
        make.top.equalTo(self.gridView.mas_bottom);
        make.bottom.equalTo(self);
    }];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    CGFloat paddingx = 10;
    CGFloat paddingy = 10;
    
    self.centerY = (CGRectGetHeight(bounds) - 20) / 2;
    
    CGFloat scaleX = self.image.size.width / (CGRectGetWidth(bounds) - paddingx * 2);
    CGFloat scaleY = self.image.size.height / (CGRectGetHeight(bounds) - paddingy * 2);
    CGFloat scale = MAX(scaleX, scaleY);
    CGSize imageSize = CGSizeMake(self.image.size.width / scale, self.image.size.height / scale);
    CGFloat imageRatio = imageSize.width / imageSize.height;
    
    CGFloat screenRatio = (CGRectGetWidth(bounds) - paddingx * 2) / (CGRectGetHeight(bounds) - paddingy * 2);
    CGRect rectContent;
    if (imageRatio > screenRatio) {
        CGFloat y = (CGRectGetHeight(bounds) - imageSize.height) / 2;
        rectContent = CGRectMake(paddingx, y, imageSize.width, imageSize.height);
    }
    else {
        CGFloat x = (CGRectGetWidth(bounds) - imageSize.width) / 2;
        rectContent = CGRectMake(x, paddingy, imageSize.width, imageSize.height);
    }
    
    CGRect rectGrid = rectContent;
    if (self.fixedRatio) {
        if (imageRatio > self.fixedRatio) {
            CGFloat height = imageSize.height;
            CGFloat width = height * self.fixedRatio;
            rectGrid = CGRectMake((CGRectGetWidth(rectGrid) - width) / 2 + CGRectGetMinX(rectGrid), CGRectGetMinY(rectGrid), width, height);
        }
        else {
            CGFloat width = imageSize.width;
            CGFloat height = width / self.fixedRatio;
            rectGrid = CGRectMake(CGRectGetMinX(rectGrid), (CGRectGetHeight(rectGrid) - height) / 2 + CGRectGetMinY(rectGrid), width, height);
        }
    }
    
    self.gridView.frame = rectGrid;
    
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(rectContent), CGRectGetHeight(rectContent));
    
    self.scrollView.frame = rectGrid;
    self.scrollView.contentSize = rectContent.size;
    
    CGFloat x = (self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds)) / 2;
    CGFloat y = (self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds)) / 2;
    self.scrollView.contentOffset = CGPointMake(x, y);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rectOut, rectIn;
    rectOut = CGRectInset(self.gridView.frame, -4, -4);
    rectIn = CGRectInset(self.gridView.frame, 4, 4);
    if (CGRectContainsPoint(rectOut, point) && !CGRectContainsPoint(rectIn, point)) {
        return self.gridView;
    }
    
    return self.scrollView;
}

- (UIImage *)croppedImageWithWidth:(CGFloat)width {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // translate
    CGPoint translation = [self photoTranslation];
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    
    // rotate
    transform = CGAffineTransformRotate(transform, 0);
    
    // scale
    CGAffineTransform t = self.contentView.transform;
    CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    transform = CGAffineTransformScale(transform, xScale, yScale);
    
    if (width == 0) {
        width = self.gridView.frame.size.width * [UIScreen mainScreen].scale;
    }
    
    CGImageRef imageRef = [self newTransformedImage:transform
                                        sourceImage:self.image.CGImage
                                         sourceSize:self.image.size
                                  sourceOrientation:self.image.imageOrientation
                                        outputWidth:width
                                           cropSize:self.gridView.frame.size
                                      imageViewSize:self.contentView.bounds.size];
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

- (CGPoint)photoTranslation {
    CGRect rect = [self.contentView convertRect:self.contentView.bounds toView:self];
    CGPoint point = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    
    CGPoint zeroPoint = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY + 10);
    
    return CGPointMake(point.x - zeroPoint.x, point.y - zeroPoint.y);
}

- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality {
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch (orientation) {
            case UIImageOrientationUp: {
                rotation = 0;
            }
            break;
            
            case UIImageOrientationDown: {
                rotation = M_PI;
            }
            break;
            
            case UIImageOrientationLeft:{
                rotation = M_PI_2;
                srcSize = CGSizeMake(size.height, size.width);
            }
            break;
            
            case UIImageOrientationRight: {
                rotation = -M_PI_2;
                srcSize = CGSizeMake(size.height, size.width);
            }
            break;
            
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,  //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                                 );
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize {
    CGImageRef source = [self newScaledImage:sourceImage
                             withOrientation:sourceOrientation
                                      toSize:sourceSize
                                 withQuality:kCGInterpolationNone];
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                            outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       , source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return resultRef;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

@end

#pragma mark - GFPhotoCropViewController

@interface GFPhotoCropViewController ()

@property (nonatomic, strong) UIImage           *image;
@property (nonatomic, assign) CGFloat           fixedRatio;

@property (nonatomic, strong) GFCropView        *cropView;

@end

@implementation GFPhotoCropViewController

- (instancetype)initWithImage:(UIImage *)image fixedRatio:(CGFloat)ratio {
    if (self = [super init]) {
        self.image = image;
        self.fixedRatio = ratio;
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = YES;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.cropView = [[GFCropView alloc] initWithImage:self.image fixedRatio:self.fixedRatio];
    [self.view addSubview:self.cropView];
    
    self.cropView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.
                                                           constant:.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.
                                                           constant:.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.
                                                           constant:.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.
                                                           constant:.0]];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:GFLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [btnCancel addTarget:self
                  action:@selector(touchCancel)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
    
    btnCancel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btnCancel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeftMargin
                                                         multiplier:1.
                                                           constant:.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btnCancel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottomMargin
                                                         multiplier:1.
                                                           constant:.0]];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setTitle:GFLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [btnDone addTarget:self
                action:@selector(touchDone)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDone];
    
    btnDone.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btnDone
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRightMargin
                                                         multiplier:1.
                                                           constant:.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btnDone
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottomMargin
                                                         multiplier:1.
                                                           constant:.0]];
    
    self.view.layer.masksToBounds = YES;
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)touchCancel {
    [self.delegate photoCropViewControllerDidCancel:self];
}

- (void)touchDone {
    [self.delegate photoCropViewController:self
                    didFinishCroppingImage:[self.cropView croppedImageWithWidth:self.outputWidth]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
