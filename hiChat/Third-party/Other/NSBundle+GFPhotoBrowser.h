//
//  NSBundle+GFPhotoBrowser.h
//  GFPhotoBrowser
//
//

#import <UIKit/UIKit.h>

@interface UIImage (GFPhotoBrowser)

+ (UIImage *)photoBrowserImageNamed:(NSString *)name;

@end

@interface NSBundle (GFPhotoBrowser)

+ (instancetype)photoBrowserBundle;

- (NSString *)photoBrowserStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;

@end

#define GFLocalizedString(key, comment) \
    [[NSBundle photoBrowserBundle] photoBrowserStringForKey:(key) value:(key) table:@"Localizable"]
