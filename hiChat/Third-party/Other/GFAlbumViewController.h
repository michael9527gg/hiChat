//
//  GFAlbumViewController.h
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/4.
//
//

#import <UIKit/UIKit.h>
#import "GFPhotosDataSource.h"

@class GFAlbumViewController;

@protocol AlbumViewDelegate <NSObject>

- (void)album:(GFAlbumViewController *)album selectSection:(PhotoSectionInfo *)sectionInfo;

@end

@interface GFAlbumViewController : UITableViewController

@property (nonatomic, weak) id<AlbumViewDelegate>   delegate;

@end
