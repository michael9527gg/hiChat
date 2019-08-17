//
//  ContactsDataSource.m
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "ContactsDataSource.h"
#import "AppDelegate.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import "ContactsManager.h"

@implementation FriendBlackData

+ (instancetype)friendBlackWithDic:(NSDictionary *)dic {
    return [[self alloc] initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if(self = [super init]) {
        self.userid = dic[@"id"];
        self.nickname = dic[@"nickname"];
        self.portraitUri = dic[@"portraitUri"];
        NSString *updateStr = YUCLOUD_VALIDATE_STRING(dic[@"updatedAt"]);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        self.updatedAt = [formatter dateFromString:updateStr];
    }
    
    return self;
}

+ (FriendBlackData *)blackForEntity:(FriendBlackEntity *)entity {
    if(!entity) return nil;
    
    FriendBlackData *black = [[FriendBlackData alloc] init];
    black.userid = entity.userid;
    black.nickname = entity.nickname;
    black.portraitUri = entity.portraitUri;
    black.updatedAt = entity.updatedAt;
    
    return black;
}

@end

@implementation FriendRequsetData

+ (instancetype)friendRequsetWithDic:(NSDictionary *)dic {
    return [[self alloc] initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if(self = [super init]) {
        self.displayName = dic[@"displayName"];
        self.message = dic[@"message"];
        self.status = YUCLOUD_VALIDATE_STRING(dic[@"status"]);
        NSString *updateStr = YUCLOUD_VALIDATE_STRING(dic[@"updatedAt"]);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        self.updatedAt = [formatter dateFromString:updateStr];
        
        NSDictionary *user = dic[@"user"];
        
        self.userid = YUCLOUD_VALIDATE_STRING(user[@"id"]);
        if (self.userid == nil) {
            return nil;
        }
        
        self.nickname = user[@"nickname"];
        self.portraitUri = user[@"portraitUri"];
    }
    
    return self;
}

+ (FriendRequsetData *)requestForEntity:(FriendRequestEntity *)entity {
    if(!entity) return nil;
    
    FriendRequsetData *data = [[FriendRequsetData alloc] init];
    
    data.userid = entity.userid;
    data.nickname = entity.nickname;
    data.displayName = entity.displayName;
    data.portraitUri = entity.portraitUri;
    data.updatedAt = entity.updateAt;
    data.message = entity.message;
    data.status = entity.status;
    
    return data;
}

- (NSString *)name {
    if (self.displayName && self.displayName.length) {
        return self.displayName;
    }
    else if (self.nickname && self.nickname.length) {
        return self.nickname;
    }
    else {
        return @"未命名";
    }
}

@end

@implementation ContactData

+ (instancetype)contactFromData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

+ (instancetype)contactForEntity:(ContactEntity *)item {
    return [[self alloc] initWithEntity:item];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.displayName = YUCLOUD_VALIDATE_STRING(data[@"displayName"]);
        self.message = YUCLOUD_VALIDATE_STRING(data[@"message"]);
        self.status = YUCLOUD_VALIDATE_NUMBER(data[@"status"]);
        
        NSDictionary *user = data[@"user"];
        
        self.uid = YUCLOUD_VALIDATE_STRING(user[@"id"]);
        self.account = YUCLOUD_VALIDATE_STRING(user[@"account"]);
        self.nickname = YUCLOUD_VALIDATE_STRING(user[@"nickname"]);
        self.phone = YUCLOUD_VALIDATE_STRING(user[@"phone"]);
        self.portraitUri = YUCLOUD_VALIDATE_STRING_WITH_DEFAULT(user[@"portraitUri"], [UIImage defaultAvatarUrl]);
    }
    
    return self;
}

- (instancetype)initWithEntity:(ContactEntity *)entity {
    if (self = [super init]) {
        self.uid = entity.uid;
        self.account = entity.account;
        self.displayName = entity.displayName;
        self.nickname = entity.nickname;
        self.message = entity.message;
        self.phone = entity.phone;
        self.portraitUri = entity.portraitUri;
        self.sectionKey = entity.sectionKey;
    }
    
    return self;
}

- (NSString *)name {
    if (self.displayName && self.displayName.length) {
        return self.displayName;
    }
    else if (self.nickname && self.nickname.length) {
        return self.nickname;
    }
    else {
        return @"未命名";
    }
}

- (NSString *)cacheKey {
    if (self.portraitUri.length) {
        return [NSString stringWithFormat:@"%@-cached", self.portraitUri];
    }
    
    return nil;
}

@end


@implementation ContactsDataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ContactsDataSource *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ContactsDataSource alloc] initWithPrivateContext:[[LYCoreDataManager manager] newPrivateContext]];
    });
    
    return instance;
}

- (NSString *)entityNameForObject:(id)object {
    if([object isKindOfClass:[ContactData class]]) {
        return [ContactEntity entityName];
    } else if([object isKindOfClass:[FriendRequsetData class]]) {
        return [FriendRequestEntity entityName];
    } else if([object isKindOfClass:[FriendBlackData class]]) {
        return [FriendBlackEntity entityName];
    }
    
    return nil;
}

- (NSManagedObject *)onAddObject:(id)object {
    if ([object isKindOfClass:[ContactData class]]) {
        ContactData *data = (ContactData *)object;
        NSFetchRequest *request = [ContactEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, YUCLOUD_ACCOUNT_USERID];
        
        ContactEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[ContactEntity entityName]
                                                 inManagedObjectContext:self.privateContext];
            item.loginid = YUCLOUD_ACCOUNT_USERID;
        }
        
        if (![item.name isEqualToString:data.name]) {
            if(![self hasChinesePrefix:data.name] &&
               ![self hasEnglishPrefix:data.name]) {
                item.shengmu = item.sectionKey = @"~";
            }
            else {
                NSString *pinyin = [data.name pinyin];
                pinyin = [pinyin uppercaseString];
                
                NSMutableString *shengmu = [NSMutableString new];
                NSArray *arr = [pinyin componentsSeparatedByString:@" "];
                for (NSString *item in arr) {
                    if (item.length) {
                        [shengmu appendString:[item substringToIndex:1]];
                    }
                }
                
                item.shengmu = shengmu.copy;
                item.sectionKey = [pinyin substringToIndex:1];
            }
        }
        
        item.uid = data.uid;
        item.displayName = data.displayName;
        item.nickname = data.nickname;
        item.name = data.name;
        item.account = data.account;
        item.message = data.message;
        item.phone = data.phone;
        item.portraitUri = data.portraitUri;
        
        return item;
    } else if([object isKindOfClass:[FriendRequsetData class]]) {
        FriendRequsetData *data = (FriendRequsetData *)object;
        NSFetchRequest *request = [FriendRequestEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"userid == %@ && loginid == %@", data.userid, YUCLOUD_ACCOUNT_USERID];
        
        FriendRequestEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[FriendRequestEntity entityName]
                                                 inManagedObjectContext:self.privateContext];
            item.loginid = YUCLOUD_ACCOUNT_USERID;
            item.userid = data.userid;
        }
        
        item.nickname = data.nickname;
        item.displayName = data.displayName;
        item.portraitUri = data.portraitUri;
        item.updateAt = data.updatedAt;
        item.status = data.status;
        
        return item;
    } else if([object isKindOfClass:[FriendBlackData class]]) {
        
        FriendBlackData *data = (FriendBlackData *)object;
        NSFetchRequest *request = [FriendBlackEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"userid == %@ && loginid == %@", data.userid, YUCLOUD_ACCOUNT_USERID];
        
        FriendBlackEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[FriendBlackEntity entityName]
                                                 inManagedObjectContext:self.privateContext];
            item.loginid = YUCLOUD_ACCOUNT_USERID;
            item.userid = data.userid;
        }
        
        item.nickname = data.nickname;
        item.portraitUri = data.portraitUri;
        item.updatedAt = data.updatedAt;
        
        return item;
    }
    else {
        return nil;
    }
}

- (void)onDeleteObject:(id)object {
    if ([object isKindOfClass:[ContactData class]]) {
        ContactData *contact = (ContactData *)object;
        
        NSFetchRequest *request = [ContactEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", contact.uid, YUCLOUD_ACCOUNT_USERID];
        
        ContactEntity *item = [[self.privateContext executeFetchRequest:request error:nil] firstObject];
        if (item && !item.isDeleted) {
            [self.privateContext deleteObject:item];
        }
    } else if([object isKindOfClass:[FriendBlackData class]]) {
        FriendBlackData *data = (FriendBlackData *)object;
        
        NSFetchRequest *request = [FriendBlackEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"userid == %@ && loginid == %@", data.userid, YUCLOUD_ACCOUNT_USERID];
        
        FriendBlackEntity *item = [[self.privateContext executeFetchRequest:request error:nil] firstObject];
        if (item && !item.isDeleted) {
            [self.privateContext deleteObject:item];
        }
    }
}

#pragma mark - ContactData methods

- (ContactData *)contactAtIndexPath:(NSIndexPath *)indexPath
                         controller:(NSFetchedResultsController *)controller {
    ContactEntity *item = [self objectAtIndexPath:indexPath
                                       controller:controller];
    
    return [ContactData contactForEntity:item];
}

- (ContactData *)contactWithUserid:(NSString *)userid {
    NSArray *contacts = [self executeFetchRequest:[ContactEntity fetchRequest]
                                            predicate:[NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", userid, YUCLOUD_ACCOUNT_USERID]];
    
    return [ContactData contactForEntity:contacts.firstObject];
}

- (NSArray *)allContacts {
    NSFetchRequest *request = [ContactEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID];
    NSArray *array = [self.privateContext executeFetchRequest:request error:nil];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
    
    for(ContactEntity *entity in array) {
        [mulArr addObject:[ContactData contactForEntity:entity]];
    }
    
    return mulArr;
}

- (NSArray *)allContactsForController:(NSFetchedResultsController *)controller {
    NSArray *array = [self allObjects:controller];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
    
    for(ContactEntity *entity in array) {
        [mulArr addObject:[ContactData contactForEntity:entity]];
    }
    
    return mulArr;
}

#pragma mark - FriendRequsetData methods

- (BOOL)isFriendForUserid:(NSString *)userid {
    NSFetchRequest *request = [ContactEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", userid, YUCLOUD_ACCOUNT_USERID];
    NSArray *contacts = [self.privateContext executeFetchRequest:request error:nil];
    
    return contacts.count;
}

- (FriendRequsetData *)requestAtIndexPath:(NSIndexPath *)indexPath
                               controller:(nonnull NSFetchedResultsController *)controller {
    FriendRequestEntity *item = [self objectAtIndexPath:indexPath controller:controller];
    
    return [FriendRequsetData requestForEntity:item];
}

- (FriendRequsetData *)requestWithUserid:(NSString *)userid {
    FriendRequestEntity *item = [self executeFetchRequest:[FriendRequestEntity fetchRequest]
                                                predicate:[NSPredicate predicateWithFormat:@"userid == %@ && loginid == %@", userid, YUCLOUD_ACCOUNT_USERID]];
    
    return [FriendRequsetData requestForEntity:item];
}

#pragma mark - FriendBlackData methods

- (FriendBlackData *)blackAtIndexPath:(NSIndexPath *)indexPath
                           controller:(nonnull NSFetchedResultsController *)controller {
    FriendBlackEntity *item = [self objectAtIndexPath:indexPath controller:controller];
    
    return [FriendBlackData blackForEntity:item];
}

- (FriendBlackData *)blackWithUserid:(NSString *)userid {
    FriendBlackEntity *item = [self executeFetchRequest:[FriendBlackEntity fetchRequest]
                                              predicate:[NSPredicate predicateWithFormat:@"userid == %@ && loginid == %@", userid, YUCLOUD_ACCOUNT_USERID]];
    
    return [FriendBlackData blackForEntity:item];
}

#pragma mark - private methods

- (BOOL)hasChinesePrefix:(NSString *)str {
    int utfCode = 0;
    void *buffer = &utfCode;
    NSRange range = NSMakeRange(0, 1);
    BOOL b = [str getBytes:buffer
                 maxLength:2
                usedLength:NULL
                  encoding:NSUTF16LittleEndianStringEncoding
                   options:NSStringEncodingConversionExternalRepresentation
                     range:range
            remainingRange:NULL];
    if (b && (utfCode >= 0x4e00 && utfCode <= 0x9fa5)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)hasEnglishPrefix:(NSString *)str {
    NSString *regular = @"^[A-Za-z].+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    
    if ([predicate evaluateWithObject:str]) {
        return YES;
    }
    
    return NO;
}

@end
