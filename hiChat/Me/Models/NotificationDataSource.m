//
//  NotificationDataSource.m
//  hiChat
//
//  Created by Polly polly on 27/02/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "NotificationDataSource.h"

@implementation NotificationData

+ (instancetype)notificationWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.uid = YUCLOUD_VALIDATE_STRING([data valueForKey:@"id"]);
        NSString *origin = YUCLOUD_VALIDATE_STRING([data valueForKey:@"title"]);
        if(origin.length) {
            origin = [origin stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            NSString *decode = [origin stringByRemovingPercentEncoding];
            self.title = origin;
            if(decode) {
                self.title = decode;
            }
        }
        origin = YUCLOUD_VALIDATE_STRING([data valueForKey:@"content"]);
        if(origin.length) {
            origin = [origin stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            NSString *decode = [origin stringByRemovingPercentEncoding];
            self.content = origin;
            if(decode) {
                self.content = decode;
            }
        }
        
        NSNumber *number = YUCLOUD_VALIDATE_NUMBER([data valueForKey:@"timestamp"]);
        self.time = [NSDate dateWithTimeIntervalSince1970:number.doubleValue];
        number = YUCLOUD_VALIDATE_NUMBER([data valueForKey:@"top_alert"]);
        self.alert = number.boolValue;
    }
    
    return self;
}

@end

@implementation NotificationDataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NotificationDataSource *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NotificationDataSource alloc] initWithPrivateContext:[[LYCoreDataManager manager] newPrivateContext]];
    });
    
    return instance;
}

- (NSString *)entityNameForObject:(id)object {
    if([object isKindOfClass:[NotificationData class]]) {
        return [NotificationEntity entityName];
    }
    
    return nil;
}

- (NSManagedObject *)onAddObject:(id)object {
    if([object isKindOfClass:[NotificationData class]]) {
        NotificationData *data = (NotificationData *)object;
        NSFetchRequest *request = [NotificationEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, YUCLOUD_ACCOUNT_USERID];
        
        NotificationEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[NotificationEntity entityName]
                                                 inManagedObjectContext:self.privateContext];
            item.loginid = YUCLOUD_ACCOUNT_USERID;
            item.uid = data.uid;
        }
        
        item.title = data.title;
        item.content = data.content;
        item.read = data.read;
        item.alert = data.alert;
        item.time = data.time;
        
        return item;
    }
    
    return nil;
}

- (void)onDeleteObject:(id)object {
    if ([object isKindOfClass:[NotificationData class]]) {
        NotificationData *data = (NotificationData *)object;
        
        NSFetchRequest *request = [NotificationEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, YUCLOUD_ACCOUNT_USERID];
        
        NotificationEntity *item = [[self.privateContext executeFetchRequest:request error:nil] firstObject];
        if (item && !item.isDeleted) {
            [self.privateContext deleteObject:item];
        }
    }
}

- (NotificationData *)notificationAtIndexPath:(NSIndexPath *)indexPath
                                   controller:(nonnull NSFetchedResultsController *)controller {
    NotificationEntity *item = [self objectAtIndexPath:indexPath controller:controller];
    
    return [self notificationForEntity:item];
}

- (NotificationData *)notificationForEntity:(NotificationEntity *)entity {
    if(!entity) return nil;
    
    NotificationData *contact = [[NotificationData alloc] init];
    contact.uid = entity.uid;
    contact.title = entity.title;
    contact.content = entity.content;
    contact.time = entity.time;
    contact.read = entity.read;
    contact.alert = entity.alert;
    
    return contact;
}

- (NotificationData *)notificationWithUid:(NSString *)uid {
    NotificationEntity *item = [self executeFetchOnEntity:[NotificationEntity class]
                                                predicate:[NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", uid, YUCLOUD_ACCOUNT_USERID]].firstObject;
    
    return [self notificationForEntity:item];
}

- (NSInteger)unReadNotificationsCount {
    NSArray *array = [self executeFetchOnEntity:[NotificationEntity class]
                                      predicate:[NSPredicate predicateWithFormat:@"read == NO && loginid == %@", YUCLOUD_ACCOUNT_USERID]];
    
    return array.count;
}

- (void)clearAllNotifications {
    NSArray *array = [self executeFetchOnEntity:[NotificationEntity class]
                                      predicate:[NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID]];
    
    for(NotificationEntity *entity in array) {
        [self deleteObject:[self notificationForEntity:entity]];
    }
}

@end
