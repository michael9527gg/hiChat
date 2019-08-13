//
//  GFPhotoBrowserViewController.h
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/4.
//
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class GFPhotoBrowserViewController;

@protocol PhotoBrowserDelegate <NSObject>

@optional

- (void)browser:(GFPhotoBrowserViewController *)browser selectImages:(NSArray <UIImage *> *)images;
- (void)browser:(GFPhotoBrowserViewController *)browser selectVideos:(NSArray <NSDictionary *> *)videos;

@end

@interface GFPhotoBrowserViewController : UICollectionViewController

@property (nonatomic, weak) id <PhotoBrowserDelegate>   delegate;
@property (nonatomic, assign) CGSize                    returnSize;
@property (nonatomic, assign) NSInteger                 imageCountLimit;
@property (nonatomic, assign) NSUInteger                fileLengthLimit;

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType
                   mediaType:(PHAssetMediaType)mediaType
     allowsMultipleSelection:(BOOL)allowsMultipleSelection;

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType
                   mediaType:(PHAssetMediaType)mediaType
     allowsMultipleSelection:(BOOL)allowsMultipleSelection
                  returnSize:(CGSize)returnSize;

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType
                   mediaType:(PHAssetMediaType)mediaType
     allowsMultipleSelection:(BOOL)allowsMultipleSelection
                  returnSize:(CGSize)returnSize
             imageCountLimit:(NSInteger)imageCountLimit
             fileLengthLimit:(NSUInteger)fileLengthLimit;

@end
