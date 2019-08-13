//
//  CommonDefs.h
//
//

#ifndef CommonDefs_h
#define CommonDefs_h

#define CONTENT_VIEW                                self.contentView

#define YUCLOUD_VALIDATE_STRING(string)             (string     && [string isKindOfClass:[NSString class]])?string:nil
#define YUCLOUD_VALIDATE_NUMBER(number)             (number     && [number isKindOfClass:[NSNumber class]])?number:nil
#define YUCLOUD_VALIDATE_DICTIONARY(dictionary)     (dictionary && [dictionary isKindOfClass:[NSDictionary class]])?dictionary:nil
#define YUCLOUD_VALIDATE_ARRAY(array)               (array      && [array isKindOfClass:[NSArray class]])?array:nil

#define YUCLOUD_VALIDATE_STRING_WITH_DEFAULT(string, default) (string && [string isKindOfClass:[NSString class]])?string:default
#define YUCLOUD_VALIDATE_NUMBER_WITH_DEFAULT(number, default) (number && [number isKindOfClass:[NSNumber class]])?number:default

#define YUCLOUD_STRING_PLEASE_WAIT                      NSLocalizedString(@"Please wait", nil)
#define YUCLOUD_STRING_SUCCESS                          NSLocalizedString(@"Success", nil)
#define YUCLOUD_STRING_FAILED                           NSLocalizedString(@"Failed", nil)
#define YUCLOUD_STRING_CANCEL                           NSLocalizedString(@"Cancel", nil)
#define YUCLOUD_STRING_CONTINUE                         NSLocalizedString(@"Continue", nil)
#define YUCLOUD_STRING_DONE                             NSLocalizedString(@"Done", nil)
#define YUCLOUD_STRING_SAVE                             NSLocalizedString(@"Save", nil)
#define YUCLOUD_STRING_OK                               NSLocalizedString(@"OK", nil)
#define YUCLOUD_STRING_CLOSE                            NSLocalizedString(@"Close", nil)
#define YUCLOUD_STRING_EDIT                             NSLocalizedString(@"Edit", nil)
#define YUCLOUD_STRING_DELETE                           NSLocalizedString(@"Delete", nil)
#define YUCLOUD_STRING_ADD                              NSLocalizedString(@"Add", nil)

#define YUCLOUD_IMAGE_SUCCESS                           [UIImage imageNamed:@"icon_common_finished"]
#define YUCLOUD_IMAGE_FAILED                            [UIImage imageNamed:@"icon_common_failed"]

#define WEAK(var, name)             __weak __typeof(var) name = var
#define STRONG(var, name)           __strong __typeof(var) name = var
#define LATER_DATE(a, b)            a = a?[a laterDate:b]:b

typedef void (^CommonBlock)(BOOL success, NSDictionary * _Nullable info);

#define LIST_ICON_SIZE  CGSizeMake(256, 256)
#define LARGE_ICON_SIZE CGSizeMake(768, 768)

#endif /* CommonDefs_h */
