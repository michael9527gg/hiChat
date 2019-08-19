//
//  ContactsDataSource.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "Model+CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FriendRequestStatusSend,
    FriendRequestStatusAccept,
    FriendRequestStatusRequest,
    FriendRequestStatusReject
} FriendRequestStatus;

@interface FriendBlackData : NSObject

@property (nullable, nonatomic, copy) NSString  *userid;
@property (nullable, nonatomic, copy) NSString  *nickname;
@property (nullable, nonatomic, copy) NSString  *portraitUri;
@property (nullable, nonatomic, copy) NSDate    *updatedAt;

+ (instancetype)friendBlackWithDic:(NSDictionary *)dic;

+ (FriendBlackData *)blackForEntity:(FriendBlackEntity *)entity;

@end

@interface FriendRequsetData : NSObject

@property (nullable, nonatomic, copy) NSString  *userid;
@property (nullable, nonatomic, copy) NSString  *displayName;
@property (nullable, nonatomic, copy) NSString  *message;
@property (nullable, nonatomic, copy) NSString  *nickname;
@property (nullable, nonatomic, copy) NSString  *portraitUri;
@property (nullable, nonatomic, copy) NSString  *status;
@property (nullable, nonatomic, copy) NSDate    *updatedAt;

@property (nonnull, readonly) NSString          *name;

+ (instancetype)friendRequsetWithDic:(NSDictionary *)dic;

+ (FriendRequsetData *)requestForEntity:(FriendRequestEntity *)entity;

@end

@interface ContactData : NSObject

@property (nullable, nonatomic, copy) NSString  *uid;
@property (nullable, nonatomic, copy) NSString  *account;
@property (nullable, nonatomic, copy) NSString  *displayName;
@property (nullable, nonatomic, copy) NSString  *loginid;
@property (nullable, nonatomic, copy) NSString  *message;
@property (nullable, nonatomic, copy) NSString  *nickname;
@property (nullable, nonatomic, copy) NSString  *phone;
@property (nullable, nonatomic, copy) NSString  *portraitUri;
@property (nonatomic, strong) NSNumber          *status;
@property (nullable, nonatomic, copy) NSString  *sectionKey;

@property (nonnull, readonly) NSString          *name;

- (nullable NSString *)cacheKey;

+ (instancetype)contactFromData:(NSDictionary *)data;

+ (instancetype)contactForEntity:(ContactEntity *)entity;

@end

@interface ContactsDataSource : LYDataSource

- (NSArray *)allContacts;

- (NSArray *)allContactsForController:(NSFetchedResultsController *)controller;

- (ContactData *)contactAtIndexPath:(NSIndexPath *)indexPath
                         controller:(NSFetchedResultsController *)controller;

- (ContactData *)contactWithUserid:(NSString *)userid;

- (FriendRequsetData *)requestWithUserid:(NSString *)userid;

- (FriendRequsetData *)requestAtIndexPath:(NSIndexPath *)indexPath
                               controller:(NSFetchedResultsController *)controller;

- (BOOL)isFriendForUserid:(NSString *)userid;

- (FriendBlackData *)blackAtIndexPath:(NSIndexPath *)indexPath
                           controller:(NSFetchedResultsController *)controller;

- (FriendBlackData *)blackWithUserid:(NSString *)userid;

@end

NS_ASSUME_NONNULL_END
