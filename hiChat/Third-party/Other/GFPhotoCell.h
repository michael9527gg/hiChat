//
//  GFPhotoCell.h
//  GFPhotoBrowser
//
//  Created by zhangliyong on 2016/11/3.
//
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface GFPhotoCell : UICollectionViewCell

@property (nonatomic, strong)   PHAsset         *asset;
@property (nonatomic)           BOOL            allowsMultipleSelection;

+ (NSString *)cellIdentifier;

@end
