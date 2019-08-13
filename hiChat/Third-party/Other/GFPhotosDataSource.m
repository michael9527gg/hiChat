//
//  GFPhotosDataSource.m
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/3.
//
//

#import "GFPhotosDataSource.h"

@implementation PhotoSectionInfo

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title {
    if (self = [super init]) {
        _key = [key copy];
        _title = [title copy];
    }
    
    return self;
}

- (NSInteger)numberOfObjects {
    return [self.objects count];
}

@end

#pragma mark - GFPhotosDataSource

@interface GFPhotosDataSource ()

@property (nonatomic, strong)   PHPhotoLibrary                      *photoLibrary;

@property (nonatomic, strong)   NSMutableArray<PhotoSectionInfo *>  *sections;

@end

@implementation GFPhotosDataSource

- (instancetype)init {
    if (self = [super init]) {
        self.photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dataInitWillBegin];
                
                [self fetchDataType:PHAssetCollectionTypeSmartAlbum subType:PHAssetCollectionSubtypeAny mediaType:PHAssetMediaTypeUnknown];
                [self fetchDataType:PHAssetCollectionTypeAlbum subType:PHAssetCollectionSubtypeAny mediaType:PHAssetMediaTypeUnknown];
                
                [self dataInitDidFinish];
            });
        }];
    }
    
    return self;
}

- (instancetype)initWithType:(PHAssetCollectionType)type {
    return [self initWithType:type
                      subType:PHAssetCollectionSubtypeAny];
}

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType {
    return [self initWithType:type
                      subType:subType
                    mediaType:PHAssetMediaTypeUnknown];
}

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType
                   mediaType:(PHAssetMediaType)mediaType {
    if (self = [super init]) {
        self.photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dataInitWillBegin];
                [self fetchDataType:type subType:subType mediaType:mediaType];
                [self dataInitDidFinish];
            });
        }];
    }
    
    return self;
}

- (void)dataInitWillBegin {
    self.sections = [NSMutableArray new];
    
    if ([self.delegate respondsToSelector:@selector(dataInitWillBegin)]) {
        [self.delegate dataInitWillBegin];
    }
}

- (void)dataInitDidFinish {
    if ([self.delegate respondsToSelector:@selector(dataInitDidFinish:)]) {
        [self.delegate dataInitDidFinish:self.sections];
    }
}

- (void)fetchDataType:(PHAssetCollectionType)type
              subType:(PHAssetCollectionSubtype)subType
            mediaType:(PHAssetMediaType)mediaType{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.includeHiddenAssets = NO;
    
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:type
                                                                     subtype:subType
                                                                     options:options];
    for (PHAssetCollection *item in result) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        if (mediaType != PHAssetMediaTypeUnknown) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %i", mediaType];
        }
        
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:item options:options];
        NSMutableArray *arr = [NSMutableArray new];
        for (PHAsset *ass in assets) {
            [arr addObject:ass];
        }
        
        if ([arr count] == 0) {
            continue;
        }
        
        NSString *key = item.localIdentifier;
        NSString *title = item.localizedTitle;
        
        PhotoSectionInfo *info = [[PhotoSectionInfo alloc] initWithKey:key title:title];
        info.type = item.assetCollectionType;
        info.subType = item.assetCollectionSubtype;
        
        info.objects = [NSArray arrayWithArray:arr];
        [self.sections addObject:info];
    }
}

- (NSInteger)numberOfSections {
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        return 0;
    }
    
    return [self.sections count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        return 0;
    }
    
    return [self.sections[section] numberOfObjects];
}

- (PHAsset *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section].objects[indexPath.row];
}

- (PhotoSectionInfo *)sectionInfoForSection:(NSInteger)section {
    return self.sections[section];
}

- (NSArray<PHAsset *> *)fetchedObjects {
    NSMutableArray *arr = [NSMutableArray new];
    for (PhotoSectionInfo *item in self.sections) {
        [arr addObjectsFromArray:item.objects];
    }
    
    return [NSArray arrayWithArray:arr];
}

- (PHAsset *)nextObjectWithOptions:(NSEnumerationOptions)opt forObj:(PHAsset *)asset {
    NSArray *arr = [self fetchedObjects];
    NSInteger index = [arr indexOfObject:asset];
    if (index == NSNotFound) {
        return nil;
    }
    
    if (opt == NSEnumerationReverse) {
        index--;
    }
    else {
        index++;
    }
    
    if (index >= 0 && index <= [arr count]) {
        return arr[index];
    }
    
    return nil;
}

@end
