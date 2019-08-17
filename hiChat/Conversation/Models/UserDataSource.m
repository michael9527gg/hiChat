//
//  UserDataSource.m
//  hiChat
//
//  Created by Polly polly on 16/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "UserDataSource.h"

@implementation UserData

+ (instancetype)userWithDic:(NSDictionary *)dic {
    return [[self alloc] initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if(self = [super init]) {
        self.uid = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"id"]);
        self.portrait = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"portraitUri"]);
        self.nickname = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"nickname"]);
        self.displayName = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"displayName"]);
        self.phone = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"phone"]);
        self.platformName = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"platform_name"]);
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

@end

@implementation UserDataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static UserDataSource *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[UserDataSource alloc] initWithPrivateContext:[[LYCoreDataManager manager] newPrivateContext]];
    });
    
    return instance;
}

- (NSString *)entityNameForObject:(id)object {
    if([object isKindOfClass:[UserData class]]) {
        return [UserEntity entityName];
    }
    
    return nil;
}

- (NSManagedObject *)onAddObject:(id)object {
    if ([object isKindOfClass:[UserData class]]) {
        UserData *data = (UserData *)object;
        NSFetchRequest *request = [UserEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@", data.uid];
        
        UserEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[UserEntity entityName]
                                                 inManagedObjectContext:self.privateContext];
            item.uid = data.uid;
        }
        
        item.nickname = data.nickname;
        item.portrait = data.portrait;
        item.displayName = data.displayName;
        item.phone = data.phone;
        
        return item;
    }
    
    return nil;
}

@end
