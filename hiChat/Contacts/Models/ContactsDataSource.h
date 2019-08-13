//
//  ContactsDataSource.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/13.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "VICocoaTools.h"
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

+ (instancetype)contactFromEntity:(ContactEntity *)item;

@end

@interface ContactsDataSource : VIDataSource

- (NSArray *)allContacts;

- (NSArray *)allContactsForKey:(NSString *)key;

- (ContactData *)contactAtIndexPath:(NSIndexPath *)indexPath
                             forKey:(NSString *)key;

- (ContactData *)contactWithUserid:(NSString *)userid;

- (FriendRequsetData *)requestWithUserid:(NSString *)userid;

- (FriendRequsetData *)requestAtIndexPath:(NSIndexPath *)indexPath
                                   forKey:(NSString *)key;

- (BOOL)isFriendForUserid:(NSString *)userid;

- (FriendBlackData *)blackAtIndexPath:(NSIndexPath *)indexPath
                               forKey:(NSString *)key;

- (FriendBlackData *)blackWithUserid:(NSString *)userid;

@end

NS_ASSUME_NONNULL_END
