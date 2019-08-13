//
//  GFPhotoBrowserNavigationController.m
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/4.
//
//

#import "GFPhotoBrowserNavigationController.h"
#import "GFAlbumViewController.h"
#import "GFPhotoBrowserViewController.h"

@interface GFPhotoBrowserNavigationController () < AlbumViewDelegate, PhotoBrowserDelegate >

@property (nonatomic, strong) GFPhotoBrowserViewController        *browserView;

@end

@implementation GFPhotoBrowserNavigationController

@dynamic delegate;

- (instancetype)init {
    NSAssert(NO, @"Please use the method -initWithType:subType:allowsMultipleSelection: instead");
    return nil;
}

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

- (instancetype)initWithType:(PHAssetCollectionType)type
                     subType:(PHAssetCollectionSubtype)subType
                   mediaType:(PHAssetMediaType)mediaType
     allowsMultipleSelection:(BOOL)allowsMultipleSelection
                  returnSize:(CGSize)returnSize {
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
    
    GFAlbumViewController *album = [[GFAlbumViewController alloc] init];
    if (self = [super initWithRootViewController:album]) {
        self.mediaType = mediaType;
        self.allowsMultipleSelection = allowsMultipleSelection;
        self.returnSize = returnSize;
        self.imageCountLimit = imageCountLimit;
        self.fileLengthLimit = fileLengthLimit;
        
        self.browserView = [[GFPhotoBrowserViewController alloc] initWithType:type
                                                                      subType:subType
                                                                    mediaType:mediaType
                                                      allowsMultipleSelection:self.allowsMultipleSelection
                                                                   returnSize:returnSize
                                                              imageCountLimit:imageCountLimit
                                                              fileLengthLimit:fileLengthLimit];
        
        album.delegate = self;
        self.browserView.delegate = self;
        [self pushViewController:self.browserView animated:NO];
    }
    
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - AlbumViewDelegate

- (void)album:(GFAlbumViewController *)album selectSection:(PhotoSectionInfo *)sectionInfo {
    self.browserView = [[GFPhotoBrowserViewController alloc] initWithType:sectionInfo.type
                                                                  subType:sectionInfo.subType
                                                                mediaType:self.mediaType
                                                  allowsMultipleSelection:self.allowsMultipleSelection
                                                               returnSize:self.returnSize];
    self.browserView.delegate = self;
    [self pushViewController:self.browserView animated:YES];
}

#pragma mark - PhotoBrowserDelegate

- (void)browser:(GFPhotoBrowserViewController *)browser selectImages:(NSArray<UIImage *> *)images {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(browserNavi:selectImages:)]) {
            [self.delegate browserNavi:self selectImages:images];
        }
    }];
}

- (void)browser:(GFPhotoBrowserViewController *)browser selectVideos:(NSArray<NSDictionary *> *)videos {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(browserNavi:selectVideos:)]) {
            [self.delegate browserNavi:self selectVideos:videos];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
