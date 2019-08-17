//
//  GroupDataSource.h
//  hiChat
//
//  Created by Polly polly on 16/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "VICocoaTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupData : NSObject

@property (nonatomic, copy)   NSString  *groupRole;
@property (nonatomic, copy)   NSString  *uid;
@property (nonatomic, copy)   NSString  *name;
@property (nonatomic, copy)   NSString  *portrait;
@property (nonatomic, copy)   NSString  *creatorid;
@property (nonatomic, copy)   NSString  *introduce;
@property (nonatomic, copy)   NSString  *memberCount;
@property (nonatomic, copy)   NSString  *maxMemberCount;
@property (nonatomic, copy)   NSString  *sectionKey;
@property (nonatomic, copy)   NSString  *banState;
@property (nonatomic, assign) NSInteger sortIndex;

+ (instancetype)groupWithDic:(NSDictionary *)dic;

@end

@interface GroupMemberData : NSObject

@property (nonatomic, copy)     NSString    *groupid;
@property (nonatomic, copy)     NSString    *userid;
@property (nonatomic, copy)     NSString    *role;
@property (nonatomic, copy)     NSString    *nickname;
@property (nonatomic, copy)     NSString    *portraitUri;
@property (nonatomic, copy)     NSString    *phone;
@property (nonatomic, copy)     NSString    *displayName;
@property (nonatomic, assign)   BOOL        isgag;
@property (nonatomic, copy)     NSString    *groupRole;
@property (nonatomic, copy)     NSString    *sectionKey;
@property (nonatomic, copy)     NSDate      *lastLoginAt;
@property (nonatomic, copy)     NSString    *name;

@property (nonatomic, readonly) BOOL        isLord; // 群主 (2)
@property (nonatomic, readonly) BOOL        isAdmin; // 管理员 (1)

+ (instancetype)groupMemberWithGroupid:(NSString *)groupid
                                   dic:(NSDictionary *)dic;


@end

@interface GroupDataSource : LYDataSource

- (GroupData *)groupWithGroupid:(NSString *)groupid;

- (GroupData *)groupAtIndexPath:(NSIndexPath *)indexPath
                     controller:(NSFetchedResultsController *)controller;

- (NSArray *)allGroups:(NSFetchedResultsController *)controller;

- (NSArray *)allGroups;

- (GroupMemberData *)groupMemberWithUserd:(NSString *)memberid
                                  groupid:(NSString *)groupid;;

- (GroupMemberData *)groupMemberAtIndexPath:(NSIndexPath *)indexPath
                                 controller:(NSFetchedResultsController *)controller;

- (NSArray *)allGroupMembersForGroupid:(NSString *)groupid;

- (NSArray *)allGroupMembers:(NSFetchedResultsController *)controller;

- (GroupMemberData *)groupLordForGroupid:(NSString *)groupid;;

- (NSArray *)groupAdminsForGroupid:(NSString *)groupid;;

@end

NS_ASSUME_NONNULL_END
