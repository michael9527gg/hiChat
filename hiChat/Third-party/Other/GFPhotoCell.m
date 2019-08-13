//
//  GFPhotoCell.m
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/3.
//
//

#import "GFPhotoCell.h"
#import "NSBundle+GFPhotoBrowser.h"

@interface GFPhotoCell ()

@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, strong) UIImageView       *selectView;

@end

@implementation GFPhotoCell

+ (NSString *)cellIdentifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:1]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:1]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:-1]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:-1]];
        
        self.selectView = [[UIImageView alloc] initWithImage:[UIImage photoBrowserImageNamed:@"photo_unselected"]];
        self.selectView.hidden = YES;
        [self.contentView addSubview:self.selectView];
        
        self.selectView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectView
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.imageView
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.
                                                                      constant:.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.imageView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.
                                                                      constant:.0]];
    }
    
    return self;
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    __weak typeof(self) wself = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.synchronous = NO;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(128, 128)
                                              contentMode:PHImageContentModeDefault
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                if (result) {
                                                    wself.imageView.image = result;
                                                }
                                            }];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    self.selectView.hidden = !allowsMultipleSelection;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self.selectView setImage:[UIImage photoBrowserImageNamed:selected?@"photo_selected":@"photo_unselected"]];
}

@end
