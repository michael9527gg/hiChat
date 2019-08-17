//
//  ConversationSettingDataSource.m
//  hiChat
//
//  Created by Polly polly on 27/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "ConversationSettingDataSource.h"

@implementation ConversationSettingData

+ (instancetype)conversationSettingWithType:(RCConversationType)conversationType
                                   targetId:(NSString *)targetId {
    ConversationSettingData *data = [[ConversationSettingDataSource sharedInstance] settingWithType:conversationType
                                                                                         targetId:targetId];
    
    return data?:[[self alloc] initWithType:conversationType
                                   targetId:targetId];
}

- (instancetype)initWithType:(RCConversationType)conversationType
                    targetId:(NSString *)targetId {
    if(self = [super init]) {
        self.conversationType = conversationType;
        self.targetId = targetId;
        self.isSilent = NO;
        self.isTop = NO;
        self.canMessage = YES;
    }
    
    return self;
}

@end

@implementation ConversationSettingDataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ConversationSettingDataSource *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ConversationSettingDataSource alloc] initWithPrivateContext:[[LYCoreDataManager manager] newPrivateContext]];
    });
    
    return instance;
}

- (void)initializeSettings {
    // 给所有会话都默认初始化一份配置
    NSArray *contacts = [[ContactsDataSource sharedInstance] allContacts];
    NSArray *groups = [[GroupDataSource sharedInstance] allGroups];
    
    NSMutableArray *mulArr = [NSMutableArray array];
    for(ContactData *contact in contacts) {
        ConversationSettingData *data = [[ConversationSettingDataSource sharedInstance] settingWithType:ConversationType_PRIVATE
                                                                                             targetId:contact.uid];
        if(!data) {
            data = [[ConversationSettingData alloc] initWithType:ConversationType_PRIVATE
                                                        targetId:contact.uid];
            [mulArr addObject:data];
        }
    }
    
    for(GroupData *group in groups) {
        ConversationSettingData *data = [[ConversationSettingDataSource sharedInstance] settingWithType:ConversationType_GROUP
                                                                                             targetId:group.uid];
        if(!data) {
            data = [[ConversationSettingData alloc] initWithType:ConversationType_GROUP
                                                        targetId:group.uid];
            [mulArr addObject:data];
        }
    }
    
    [[ConversationSettingDataSource sharedInstance] addObjects:mulArr];
}

- (NSString *)entityNameForObject:(id)object {
    if([object isKindOfClass:[ConversationSettingData class]]) {
        return [ConversationSettingEntity entityName];
    }
    
    return nil;
}

- (NSManagedObject *)onAddObject:(id)object {
    if([object isKindOfClass:[ConversationSettingData class]]) {
        ConversationSettingData *data = (ConversationSettingData *)object;
        NSFetchRequest *request = [ConversationSettingEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"loginid == %@ && type == %ld && targetid == %@", YUCLOUD_ACCOUNT_USERID, data.conversationType, data.targetId];
        
        ConversationSettingEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
        if (!item) {
            item = [NSEntityDescription insertNewObjectForEntityForName:[ConversationSettingEntity entityName]
                                                 inManagedObjectContext:self.privateContext];
            item.type = data.conversationType;
            item.targetid = data.targetId;
            item.loginid = YUCLOUD_ACCOUNT_USERID;
        }
        
        item.isTop = data.isTop;
        item.isSilent = data.isSilent;
        item.canMessage = data.canMessage;
        item.messageError = data.messageError;
        
        return item;
    }
    
    return nil;
}

- (ConversationSettingData *)settingForEntity:(ConversationSettingEntity *)entity {
    if(!entity) return nil;
    
    ConversationSettingData *data = [[ConversationSettingData alloc] init];
    
    data.conversationType = entity.type;
    data.targetId = entity.targetid;
    data.isTop = entity.isTop;
    data.isSilent = entity.isSilent;
    data.canMessage = entity.canMessage;
    data.messageError = entity.messageError;
    
    return data;
}

- (ConversationSettingData *)settingWithType:(RCConversationType)conversationType
                                    targetId:(NSString *)targetId {
    NSFetchRequest *request = [ConversationSettingEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"loginid == %@ && type == %ld && targetid == %@", YUCLOUD_ACCOUNT_USERID, conversationType, targetId];
    
    ConversationSettingEntity *item = [self.privateContext executeFetchRequest:request error:nil].firstObject;
    
    return [self settingForEntity:item];
}

- (NSArray *)allSettings {
    NSFetchRequest *request = [ConversationSettingEntity fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"loginid == %@", YUCLOUD_ACCOUNT_USERID];
    
    NSArray *items = [self.privateContext executeFetchRequest:request error:nil];
    NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:items.count];
    
    for(ConversationSettingEntity *item in items) {
        [mulArr addObject:[self settingForEntity:item]];
    }
    
    return mulArr;
}

@end
