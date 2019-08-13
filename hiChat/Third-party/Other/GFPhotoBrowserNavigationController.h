//
//  GFPhotoBrowserNavigationController.h
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/4.
//
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "GFPhotoBrowserViewController.h"

@class GFPhotoBrowserNavigationController;

@protocol GFPhotoBrowserNavigationDelegate <UINavigationControllerDelegate>

@optional

- (void)browserNavi:(GFPhotoBrowserNavigationController *)nav selectImages:(NSArray<UIImage *> *)images;
- (void)browserNavi:(GFPhotoBrowserNavigationController *)nav selectVideos:(NSArray<NSDictionary *> *)videos;

@end

@interface GFPhotoBrowserNavigationController : UINavigationController

@property (nonatomic, weak) id <GFPhotoBrowserNavigationDelegate> delegate;

@property (nonatomic) PHAssetMediaType      mediaType;
@property (nonatomic) BOOL                  allowsMultipleSelection;
@property (nonatomic) CGSize                returnSize;
@property (nonatomic) NSInteger             imageCountLimit;
@property (atomic)    NSUInteger            fileLengthLimit;

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
