//
//  GFAlbumCell.h
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/3.
//
//

#import <UIKit/UIKit.h>
#import "GFPhotosDataSource.h"

@interface GFAlbumCell : UITableViewCell

@property (nonatomic, copy) PhotoSectionInfo        *sectionInfo;

+ (NSString *)cellIdentifier;

@end
