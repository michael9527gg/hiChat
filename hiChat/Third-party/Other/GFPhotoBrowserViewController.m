//
//  GFPhotoBrowserViewController.m
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/4.
//
//

#import "GFPhotoBrowserViewController.h"
#import "GFPhotoCell.h"
#import "GFPhotosDataSource.h"
#import "NSBundle+GFPhotoBrowser.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface GFPhotoBrowserViewController () < GFPhotosDataDelegate >

@property (nonatomic, assign) PHAssetCollectionType         type;
@property (nonatomic, assign) PHAssetCollectionSubtype      subType;
@property (nonatomic, assign) PHAssetMediaType              mediaType;

@property (nonatomic, strong) GFPhotosDataSource            *dataSource;

@property (nonatomic, strong) UIBarButtonItem               *cancelItem;
@property (nonatomic, strong) UIBarButtonItem               *doneItem;

@property (nonatomic, strong) NSMutableArray                *selectedAssets;

@end

@implementation GFPhotoBrowserViewController

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType
                   mediaType:(PHAssetMediaType)mediaType
     allowsMultipleSelection:(BOOL)allowsMultipleSelection {
    return [self initWithType:type
                      subType:subType
                    mediaType:mediaType
      allowsMultipleSelection:allowsMultipleSelection
                   returnSize:PHImageManagerMaximumSize];
}

- (instancetype)initWithType:(PHAssetCollectionType)type subType:(PHAssetCollectionSubtype)subType mediaType:(PHAssetMediaType)mediaType allowsMultipleSelection:(BOOL)allowsMultipleSelection returnSize:(CGSize)returnSize {
    return [self initWithType:type
                      subType:subType
                    mediaType:mediaType
      allowsMultipleSelection:allowsMultipleSelection
                   returnSize:returnSize
              imageCountLimit:0
              fileLengthLimit:0];
}

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType
                   mediaType:(PHAssetMediaType)mediaType
     allowsMultipleSelection:(BOOL)allowsMultipleSelection
                  returnSize:(CGSize)returnSize
             imageCountLimit:(NSInteger)imageCountLimit
             fileLengthLimit:(NSUInteger)fileLengthLimit {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    if (self = [super initWithCollectionViewLayout:layout]) {
        self.type = type;
        self.subType = subType;
        self.mediaType = mediaType;
        self.returnSize = returnSize;
        self.imageCountLimit = imageCountLimit;
        self.fileLengthLimit = fileLengthLimit;
        
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.allowsMultipleSelection = allowsMultipleSelection;
        
        [self.collectionView registerClass:[GFPhotoCell class]
                forCellWithReuseIdentifier:[GFPhotoCell cellIdentifier]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.dataSource = [[GFPhotosDataSource alloc] initWithType:self.type
                                                       subType:self.subType
                                                     mediaType:self.mediaType];
    
    self.dataSource.delegate = self;
    
    self.cancelItem = [[UIBarButtonItem alloc] initWithTitle:GFLocalizedString(@"Cancel", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(selectCancel)];
    
    self.doneItem = [[UIBarButtonItem alloc] initWithTitle:GFLocalizedString(@"Done", nil)
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(selectDone)];
    
    self.navigationItem.rightBarButtonItem = self.cancelItem;
    self.selectedAssets = [NSMutableArray new];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect rect = CGRectMake(0, self.collectionView.contentSize.height - 1, 1, 1);
        [self.collectionView scrollRectToVisible:rect animated:NO];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)selectCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectDone {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"导出中";
    
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableDictionary *videoThumbnail = [NSMutableDictionary dictionary];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        for (PHAsset *item in self.selectedAssets) {
            if (item.mediaType == PHAssetMediaTypeVideo) {
                PHVideoRequestOptions *videoOptions = [[PHVideoRequestOptions alloc] init];
                videoOptions.networkAccessAllowed = YES;
                
                NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
                url = [url URLByAppendingPathComponent:@"video.mp4"];
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                
                dispatch_group_enter(group);
                [[PHImageManager defaultManager] requestExportSessionForVideo:item
                                                                      options:videoOptions
                                                                 exportPreset:AVAssetExportPreset640x480
                                                                resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                                                                    exportSession.outputURL = url;
                                                                    exportSession.outputFileType = AVFileTypeMPEG4;
                                                                    exportSession.fileLengthLimit = self.fileLengthLimit;
                                                                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                                                                        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                                                                            [arr addObject:url];
                                                                            dispatch_group_leave(group);
                                                                        }
                                                                        else {
                                                                            dispatch_group_leave(group);
                                                                        }
                                                                    }];
                                                                }];
                
                PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
                imageOptions.networkAccessAllowed = YES;
                imageOptions.synchronous = NO;
                imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                
                dispatch_group_enter(group);
                [[PHImageManager defaultManager] requestImageForAsset:item
                                                           targetSize:CGSizeMake(516, 516)
                                                          contentMode:PHImageContentModeAspectFit
                                                              options:imageOptions
                                                        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                            if (result) {
                                                                [videoThumbnail setObject:result forKey:url];
                                                                [videoThumbnail setObject:@(result.size.height) forKey:@"height"];
                                                                [videoThumbnail setObject:@(result.size.width) forKey:@"width"];
                                                            }
                                                            dispatch_group_leave(group);
                                                        }];
            }
            else if (item.mediaType == PHAssetMediaTypeImage) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.networkAccessAllowed = YES;
                options.synchronous = NO;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                
                dispatch_group_enter(group);
                [[PHImageManager defaultManager] requestImageForAsset:item
                                                           targetSize:self.returnSize
                                                          contentMode:PHImageContentModeDefault
                                                              options:options
                                                        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                            if (result) {
                                                                [arr addObject:result];
                                                            }
                                                            
                                                            dispatch_group_leave(group);
                                                        }];
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            hud.completionBlock = ^() {
                if (arr.count == 0) {
                    [self.selectedAssets removeAllObjects];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:@"选择失败，请检查网络"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *done = [UIAlertAction actionWithTitle:@"知道了"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
                    [alert addAction:done];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else if (self.mediaType == PHAssetMediaTypeImage) {
                    if ([self.delegate respondsToSelector:@selector(browser:selectImages:)]) {
                        [self.delegate browser:self selectImages:arr.copy];
                    }
                }
                else if (self.mediaType == PHAssetMediaTypeVideo) {
                    if ([self.delegate respondsToSelector:@selector(browser:selectVideos:)]) {
                        NSMutableArray *result = [NSMutableArray array];
                        for (NSURL *item in arr) {
                            UIImage *thumbnail = videoThumbnail[item];
                            NSMutableDictionary *data = [NSMutableDictionary dictionary];
                            [data setObject:item forKey:@"fileUrl"];
                            if (thumbnail) {
                                [data setObject:thumbnail forKeyedSubscript:@"thumbnail"];
                                NSNumber *height = videoThumbnail[@"height"];
                                [data setObject:height forKey:@"height"];
                                NSNumber *width = videoThumbnail[@"width"];
                                [data setObject:width forKey:@"width"];
                            }
                            
                            [result addObject:data];
                        }
                        [self.delegate browser:self selectVideos:result.copy];
                    }
                }
            };
        });
    });
}

#pragma mark - GFPhotosDataDelegate

- (void)dataInitWillBegin {
    
}

- (void)dataInitDidFinish:(NSArray<PhotoSectionInfo *> *)sections {
    self.title = [[sections firstObject] title];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataSource numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GFPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GFPhotoCell cellIdentifier]
                                                                  forIndexPath:indexPath];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(GFPhotoCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.asset = [self.dataSource objectAtIndexPath:indexPath];
    cell.allowsMultipleSelection = self.collectionView.allowsMultipleSelection;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = MIN(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds));
    return CGSizeMake(width / 4, width / 4);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.imageCountLimit > 0 && [self.selectedAssets count] >= self.imageCountLimit) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        NSString *msg = GFLocalizedString(@"select picture up limit message", nil);
        hud.label.text = [NSString stringWithFormat:msg, (long)self.imageCountLimit];
        [hud hideAnimated:YES afterDelay:2];
        hud.completionBlock = ^{
            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        };
        
        return;
    }
    
    PHAsset *asset = [self.dataSource objectAtIndexPath:indexPath];
    [self.selectedAssets addObject:asset];
    
    if (collectionView.allowsMultipleSelection) {
        [self selectionChanged];
    }
    else {
        [self selectDone];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self.dataSource objectAtIndexPath:indexPath];
    [self.selectedAssets removeObject:asset];
    
    [self selectionChanged];
}

- (void)selectionChanged {
    NSArray *selected = [self.collectionView indexPathsForSelectedItems];
    if ([selected count]) {
        self.navigationItem.rightBarButtonItem = self.doneItem;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.cancelItem;
    }
}

@end
