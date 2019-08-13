//
//  NSUserDefaults+Kaixin.h
//  Kaixin
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (Kaixin)

+ (BOOL)firstTimeStartup;
+ (void)saveFirstTimeStartup:(BOOL)first;

+ (NSString *)phone;
+ (void)savePhone:(NSString *)phone;

+ (NSString *)token;
+ (void)saveToken:(nullable NSString *)token;

+ (NSDate *)tokenDate;

+ (NSUInteger)databaseHash;
+ (void)saveDatabaseHash:(NSUInteger)hash;

+ (NSUInteger)unreadFriendRequstMessageCount;
+ (void)saveUnreadFriendRequstMessageCount:(NSUInteger)count;

+ (NSString *)invitationCode;
+ (void)saveInvitationCode:(NSString *)code;

+ (BOOL)versionShouldSkip:(NSString *)version;
+ (void)skipVersion:(NSString *)version;

+ (NSString *)nameOfUser:(NSString *)user;
+ (NSString *)portraitUriOfUser:(NSString *)user;
+ (void)saveName:(NSString *)name forUser:(NSString *)user;
+ (void)savePortraitUri:(NSString *)portraitUri forUser:(NSString *)user;

+ (NSDate *)checkVersionDate;
+ (void)saveCheckVersionDate:(NSDate *)date;

+ (NSDate *)lastPassLoginDate;
+ (void)saveLastPassLoginDate:(NSDate *)date;

+ (NSDate *)lastCheckinDateForUser:(NSString *)userid;
+ (void)saveLastCheckinDate:(NSDate *)date
                    forUser:(NSString *)userid;

@end

NS_ASSUME_NONNULL_END
