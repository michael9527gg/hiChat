//
//  GFPhotosDataSource.h
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/3.
//
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoSectionInfo : NSObject

@property (nonatomic, readonly) NSString    *key;
@property (nonatomic, readonly) NSString    *title;

@property (nonatomic, assign)   PHAssetCollectionType       type;
@property (nonatomic, assign)   PHAssetCollectionSubtype    subType;

@property (nonatomic, readonly) NSInteger   numberOfObjects;
@property (nonatomic, strong)   NSArray     *objects;

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title;

@end

@protocol GFPhotosDataDelegate <NSObject>

@optional
- (void)dataInitWillBegin;
- (void)dataInitDidFinish:(NSArray <PhotoSectionInfo *> *)sections;

@end

@interface GFPhotosDataSource : NSObject

@property (nonatomic, weak) id <GFPhotosDataDelegate>   delegate;

- (instancetype)initWithType:(PHAssetCollectionType)type;

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType;

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType
                   mediaType:(PHAssetMediaType)mediaType;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (PHAsset *)objectAtIndexPath:(NSIndexPath *)indexPath;
- (PhotoSectionInfo *)sectionInfoForSection:(NSInteger)section;

- (NSArray <PHAsset *> *)fetchedObjects;
- (PHAsset *)nextObjectWithOptions:(NSEnumerationOptions)opt forObj:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
