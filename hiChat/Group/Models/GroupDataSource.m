//
//  GroupDataSource.m
//  hiChat
//
//  Created by Polly polly on 16/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "GroupDataSource.h"

@implementation GroupData

+ (instancetype)groupWithDic:(NSDictionary *)dic {
    return [[self alloc] initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if(self = [super init]) {
//        0:管理员 1:群员
        self.groupRole = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"role"]);
        if(dic[@"group"]) {
            dic = dic[@"group"];
        }
        
        self.uid = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"id"]);
        self.name = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"name"]);
        self.portrait = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"portraitUri"]);
        self.creatorid = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"creatorId"]);
        self.introduce = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"bulletin"]);
        self.memberCount = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"memberCount"]);
        self.maxMemberCount = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"maxMemberCount"]);
        self.banState = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"stat"]);
    }
    
    return self;
}

@end

@implementation GroupMemberData

+ (instancetype)groupMemberWithGroupid:(NSString *)groupid
                                   dic:(NSDictionary *)dic {
    return [[self alloc] initWithGroupid:groupid
                                     dic:dic];
}

- (instancetype)initWithGroupid:(NSString *)groupid
                            dic:(NSDictionary *)dic {
    if(self = [super init]) {
        self.groupid = groupid;
        
        self.displayName = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"displayName"]);
        NSNumber *number = YUCLOUD_VALIDATE_NUMBER([dic valueForKey:@"isgag"]);
        self.isgag = number.boolValue;
        NSString *groupRole = YUCLOUD_VALIDATE_STRING_WITH_DEFAULT(dic[@"role"], @"1");
        // 这里我们自己修改下，后面列表好排序 （2：群主，1：管理员，0：成员）
        if([groupRole isEqualToString:@"0"]) {
            groupRole = @"1";
        } else if([groupRole isEqualToString:@"1"]) {
            groupRole = @"0";
        }
        self.groupRole = groupRole;
        
        NSDictionary *user = [dic valueForKey:@"user"];
        self.userid = YUCLOUD_VALIDATE_STRING([user valueForKey:@"id"]);
        self.nickname = YUCLOUD_VALIDATE_STRING([user valueForKey:@"nickname"]);
        self.portraitUri = YUCLOUD_VALIDATE_STRING_WITH_DEFAULT([user valueForKey:@"portraitUri"], [UIImage defaultAvatarUrl]);
        self.role = YUCLOUD_VALIDATE_STRING_WITH_DEFAULT(user[@"role"], @"1");
        self.phone = YUCLOUD_VALIDATE_STRING([user valueForKey:@"phone"]);
        NSString *lastLoginAt = YUCLOUD_VALIDATE_STRING([user valueForKey:@"lastLoginAt"]);
        self.lastLoginAt = [NSDate dateWithTimeIntervalSince1970:lastLoginAt.doubleValue];
    }
    
    return self;
}

- (BOOL)isLord {
    return [self.groupRole isEqualToString:@"2"];
}

- (BOOL)isAdmin {
    return [self.groupRole isEqualToString:@"1"];
}

@end

@implementation GroupDataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GroupDataSource *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[GroupDataSource alloc] initWithPrivateContext:[[LYCoreDataManager manager] newPrivateContext]];
    });
    
    return instance;
}

- (NSString *)entityNameForObject:(id)object {
    if([object isKindOfClass:[GroupData class]]) {
        return [GroupEntity entityName];
    } else if([object isKindOfClass:[GroupMemberData class]]) {
        return [GroupMemberEntity entityName];
    }
    
    return nil;
}

- (NSManagedObject *)onAddObject:(id)object {
    if([object isKindOfClass:[GroupData class]]) {
        GroupData *data = (GroupData *)object;
        NSFetchRequest *request = [GroupEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, YUCLOUD_ACCOUNT_USERID];
        
        GroupEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[GroupEntity entityName]
                                                 inManagedObjectContext:self.privateContext];
            item.uid = data.uid;
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
        
        item.name = data.name;
        item.portrait = data.portrait;
        item.creatorId = data.creatorid;
        item.introduce = data.introduce;
        item.memberCount = data.memberCount;
        item.maxMemberCount = data.maxMemberCount;
        item.groupRole = data.groupRole;
        item.banState = data.banState;
        item.sortIndex = data.sortIndex;
        
        if([data.creatorid isEqualToString:YUCLOUD_ACCOUNT_USERID]) {
            item.mine = @"我创建的群组";
            item.mineKey = @"A";
        } else {
            item.mine = @"我加入的群组";
            item.mineKey = @"B";
        }
        
        return item;
    }
    else if([object isKindOfClass:[GroupMemberData class]]) {
        GroupMemberData *data = (GroupMemberData *)object;
        NSFetchRequest *request = [GroupMemberEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"groupid == %@ && userid == %@ && loginid == %@", data.groupid, data.userid, YUCLOUD_ACCOUNT_USERID];
        
        GroupMemberEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[GroupMemberEntity entityName]
                                                 inManagedObjectContext:self.privateContext];
            item.groupid = data.groupid;
            item.userid = data.userid;
            item.loginid = YUCLOUD_ACCOUNT_USERID;
        }
    
        NSString *name = data.nickname;
        NSFetchRequest *contactRequest = [ContactEntity fetchRequest];
        contactRequest.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.userid, YUCLOUD_ACCOUNT_USERID];
        ContactEntity *contact = [self.privateContext executeFetchRequest:contactRequest error:nil].firstObject;
        // 群组成员不一定是好友，name要先初始化为昵称
        if(contact && contact.displayName.length) {
            name = contact.displayName;
        }
        
        if (![item.name isEqualToString:name]) {
            if(![self hasChinesePrefix:name] &&
               ![self hasEnglishPrefix:name]) {
                item.shengmu = item.sectionKey = @"~";
            }
            else {
                NSString *pinyin = [name pinyin];
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
        
        item.role = data.role;
        item.groupRole = data.groupRole;
        item.isgag = data.isgag;
        item.name = name;
        item.displayName = data.displayName;
        item.nickname = data.nickname;
        item.portraitUri = data.portraitUri;
        item.phone = data.phone;
        item.lastLoginAt = data.lastLoginAt;
        
        return item;
    }
    
    return nil;
}

- (void)onDeleteObject:(id)object {
    if ([object isKindOfClass:[GroupData class]]) {
        GroupData *data = (GroupData *)object;
        
        NSFetchRequest *request = [GroupEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, YUCLOUD_ACCOUNT_USERID];
        
        GroupEntity *item = [[self.privateContext executeFetchRequest:request error:nil] firstObject];
        if (item && !item.isDeleted) {
            [self.privateContext deleteObject:item];
        }
    }
}

- (GroupData *)groupForEntity:(GroupEntity *)entity {
    if(!entity) return nil;
    
    GroupData *data = [[GroupData alloc] init];
    
    data.uid = entity.uid;
    data.name = entity.name;
    data.portrait = entity.portrait;
    data.creatorid = entity.creatorId;
    data.introduce = entity.introduce;
    data.memberCount = entity.memberCount;
    data.maxMemberCount = entity.maxMemberCount;
    data.sectionKey = entity.sectionKey;
    data.banState = entity.banState;
    data.sortIndex = entity.sortIndex;
    data.sectionKey = entity.sectionKey;
    
    return data;
}

- (GroupData *)groupWithGroupid:(NSString *)groupid {
    NSFetchRequest *request = [GroupEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", groupid, YUCLOUD_ACCOUNT_USERID];
    
    GroupEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
    
    return [self groupForEntity:item];
}

- (GroupData *)groupAtIndexPath:(NSIndexPath *)indexPath controller:(nonnull NSFetchedResultsController *)controller {
    GroupEntity *entity = [self objectAtIndexPath:indexPath controller:controller];
    
    return [self groupForEntity:entity];
}

- (NSArray *)allGroups:(NSFetchedResultsController *)controller {
    NSArray *array = [self allObjects:controller];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
    for(GroupEntity *entity in array) {
        [mulArr addObject:[self groupForEntity:entity]];
    }
    
    return mulArr;
}

- (NSArray *)allGroups {
    NSFetchRequest *request = [GroupEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID];
    NSArray *array = [self.privateContext executeFetchRequest:request error:nil];
    
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
    for(GroupEntity *item in array) {
        [mulArr addObject:[self groupForEntity:item]];
    }
    
    return mulArr;
}

- (GroupMemberData *)groupMemberForEntity:(GroupMemberEntity *)entity {
    if(!entity) return nil;
    
    GroupMemberData *data = [[GroupMemberData alloc] init];
    
    data.groupid = entity.groupid;
    data.userid = entity.userid;
    data.role = entity.role;
    data.nickname = entity.nickname;
    data.portraitUri = entity.portraitUri;
    data.name = entity.name;
    data.displayName = entity.displayName;
    data.isgag = entity.isgag;
    data.groupRole = entity.groupRole;
    data.sectionKey = entity.sectionKey;
    data.phone = entity.phone;
    data.lastLoginAt = entity.lastLoginAt;
    
    return data;
}

- (GroupMemberData *)groupMemberWithUserd:(NSString *)memberid
                                  groupid:(NSString *)groupid {
    NSFetchRequest *request = [GroupMemberEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"groupid == %@ && userid == %@ && loginid == %@", groupid, memberid, YUCLOUD_ACCOUNT_USERID];
    
    GroupMemberEntity *entity = [self.privateContext executeFetchRequest:request error:nil].firstObject;
    
    return [self groupMemberForEntity:entity];
}

- (GroupMemberData *)groupMemberAtIndexPath:(NSIndexPath *)indexPath
                                 controller:(nonnull NSFetchedResultsController *)controller {
    GroupMemberEntity *entity = [self objectAtIndexPath:indexPath controller:controller];
    return [self groupMemberForEntity:entity];
}

- (NSArray *)allGroupMembersForGroupid:(NSString *)groupid {
    NSFetchRequest *request = [GroupMemberEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"groupid == %@ && loginid == %@", groupid, YUCLOUD_ACCOUNT_USERID];
    
    NSArray *array = [self.privateContext executeFetchRequest:request error:nil];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
    
    for(GroupMemberEntity *entity in array) {
        [mulArr addObject:[self groupMemberForEntity:entity]];
    }
    
    return mulArr;
}

- (NSArray *)allGroupMembers:(NSFetchedResultsController *)controller {
    NSArray *array = [self allObjects:controller];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
    for(GroupMemberEntity *entity in array) {
        [mulArr addObject:[self groupMemberForEntity:entity]];
    }
    
    return mulArr;
}

- (GroupMemberData *)groupLordForGroupid:(NSString *)groupid {
    NSFetchRequest *request = [GroupMemberEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"groupid == %@ && groupRole == %@ && loginid == %@", groupid, @"2", YUCLOUD_ACCOUNT_USERID];
    
    GroupMemberEntity *entity = [self.privateContext executeFetchRequest:request error:nil].firstObject;
    
    return [self groupMemberForEntity:entity];
}

- (NSArray *)groupAdminsForGroupid:(NSString *)groupid {
    NSFetchRequest *request = [GroupMemberEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"groupid == %@ && groupRole == %@ && loginid == %@", groupid, @"1", YUCLOUD_ACCOUNT_USERID];
    
    NSArray *array = [self.privateContext executeFetchRequest:request error:nil];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:array.count];
    
    for(GroupMemberEntity *entity in array) {
        [mulArr addObject:[self groupMemberForEntity:entity]];
    }
    
    return mulArr;
}

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
