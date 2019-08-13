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

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    static NotificationDataSource *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[NotificationDataSource alloc] initWithManagedObjectContext:[AppDelegate appDelegate].managedObjectContext
                                                                  coordinator:[AppDelegate appDelegate].persistentStoreCoordinator];
    });
    
    return client;
}

- (NSManagedObject *)onAddObject:(id)object managedObjectContext:(NSManagedObjectContext *)managedObjectContex {
    if([object isKindOfClass:[NotificationData class]]) {
        NotificationData *data = (NotificationData *)object;
        NSFetchRequest *request = [NotificationEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, YUCLOUD_ACCOUNT_USERID];
        
        NotificationEntity *item = [managedObjectContex executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[NotificationEntity entityName]
                                                 inManagedObjectContext:managedObjectContex];
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

- (void)onDeleteObject:(id)object managedObjectContext:(NSManagedObjectContext *)managedObjectContex {
    if ([object isKindOfClass:[NotificationData class]]) {
        NotificationData *data = (NotificationData *)object;
        
        NSFetchRequest *request = [NotificationEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, YUCLOUD_ACCOUNT_USERID];
        
        NotificationEntity *item = [[managedObjectContex executeFetchRequest:request error:nil] firstObject];
        if (item && !item.isDeleted) {
            [managedObjectContex deleteObject:item];
        }
    }
}

- (NotificationData *)notificationAtIndexPath:(NSIndexPath *)indexPath forKey:(NSString *)key {
    NotificationEntity *item = [self objectAtIndexPath:indexPath forKey:key];
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
    NSFetchRequest *request = [NotificationEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", uid, YUCLOUD_ACCOUNT_USERID];
    NotificationEntity *item = [self.managedObjectContext executeFetchRequest:request error:nil].firstObject;
    
    return [self notificationForEntity:item];
}

- (NSInteger)unReadNotificationsCount {
    NSFetchRequest *request = [NotificationEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"read == NO && loginid == %@", YUCLOUD_ACCOUNT_USERID];
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return array.count;
}

- (void)clearAllNotifications {
    NSFetchRequest *request = [NotificationEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID];
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    for(NotificationEntity *entity in array) {
        [self deleteObject:[self notificationForEntity:entity]];
    }
}


@end
