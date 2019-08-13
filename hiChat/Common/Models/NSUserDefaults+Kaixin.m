//
//  NSUserDefaults+Kaixin.m
//  Kaixin
//
//

#import "NSUserDefaults+Kaixin.h"
#import "AccountManager.h"

extern NSString *defaultStartupKey;

@implementation NSUserDefaults (Kaixin)

+ (instancetype)defaults {
    static dispatch_once_t onceToken;
    static NSUserDefaults *defaults = nil;
    dispatch_once(&onceToken, ^{
#if ENV_DEV
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"defaults_dev"];
#else
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"defaults"];
#endif
    });
    
    return defaults;
}

#define DEFAULT_STARTUP_KEY   @"default.startup.key"
+ (BOOL)firstTimeStartup {
    NSString *string = [[self defaults] objectForKey:DEFAULT_STARTUP_KEY];
    return ![string isEqualToString:defaultStartupKey];
}

+ (void)saveFirstTimeStartup:(BOOL)first {
    [[self defaults] setObject:defaultStartupKey forKey:DEFAULT_STARTUP_KEY];
}

#define DEFAULT_PHONE_KEY   @"default.phone.key"

+ (NSString *)phone {
    return [[self defaults] objectForKey:DEFAULT_PHONE_KEY];
}

+ (void)savePhone:(NSString *)phone {
    [[self defaults] setObject:phone?:@"" forKey:DEFAULT_PHONE_KEY];
}

#define DEFAULT_TOKEN_KEY   @"default.token.key"
#define TOKEN_DATE_KEY      @"default.token.date.key"

+ (NSString *)token {
    return [[self defaults] objectForKey:DEFAULT_TOKEN_KEY];
}

+ (void)saveToken:(NSString *)token {
    [[self defaults] setObject:token?:@"" forKey:DEFAULT_TOKEN_KEY];
    [[self defaults] setObject:[NSDate date] forKey:TOKEN_DATE_KEY];
}

+ (NSDate *)tokenDate {
    return [[self defaults] objectForKey:TOKEN_DATE_KEY];
}

#define DATABASE_HASH_KEY   @"database.hash.key"

+ (NSUInteger)databaseHash {
    NSNumber *number = [[self defaults] objectForKey:DATABASE_HASH_KEY];
    return [number unsignedIntegerValue];
}

+ (void)saveDatabaseHash:(NSUInteger)hash {
    [[self defaults] setObject:@(hash) forKey:DATABASE_HASH_KEY];
}

#define UNREAD_FRIEND_MESSAGE_COUNT   @"unread.friend.message.count"

+ (NSUInteger)unreadFriendRequstMessageCount {
    NSNumber *number = [[self defaults] objectForKey:UNREAD_FRIEND_MESSAGE_COUNT];
    return [number unsignedIntegerValue];
}

+ (void)saveUnreadFriendRequstMessageCount:(NSUInteger)count {
    [[self defaults] setObject:@(count) forKey:UNREAD_FRIEND_MESSAGE_COUNT];
}

#define INVITATION_CODE_KEY     @"invitation.code.key"

+ (NSString *)invitationCode {
#if ENV_DEV
    return @"852dfs";
#endif //ENV_DEV
    
    return [[self defaults] objectForKey:INVITATION_CODE_KEY];
}

+ (void)saveInvitationCode:(NSString *)code {
    [[self defaults] setObject:code?:@"" forKey:INVITATION_CODE_KEY];
}

#define VERSION_SKIP_KEY    @"version.skip.key"

+ (BOOL)versionShouldSkip:(NSString *)version {
    NSString *string = [[self defaults] objectForKey:[NSString stringWithFormat:@"%@-%ld", VERSION_SKIP_KEY, (long)[NSDate date].day]];
    return version && [version isEqualToString:string];
}

+ (void)skipVersion:(NSString *)version {
    [[self defaults] setObject:version?:@"" forKey:[NSString stringWithFormat:@"%@-%ld", VERSION_SKIP_KEY, (long)[NSDate date].day]];
}

#define USER_INFO_KEY       @"user.info.key"

+ (NSString *)nameOfUser:(NSString *)user {
    NSString *key = [NSString stringWithFormat:@"%@-name-%@", USER_INFO_KEY, user];
    return [[self defaults] objectForKey:key];
}

+ (NSString *)portraitUriOfUser:(NSString *)user {
    NSString *key = [NSString stringWithFormat:@"%@-portrait-%@", USER_INFO_KEY, user];
    return [[self defaults] objectForKey:key];
}

+ (void)saveName:(NSString *)name forUser:(NSString *)user {
    NSString *key = [NSString stringWithFormat:@"%@-name-%@", USER_INFO_KEY, user];
    [[self defaults] setObject:name forKey:key];
}

+ (void)savePortraitUri:(NSString *)portraitUri forUser:(NSString *)user {
    NSString *key = [NSString stringWithFormat:@"%@-portrait-%@", USER_INFO_KEY, user];
    [[self defaults] setObject:portraitUri forKey:key];
}

#define CHECK_VERSION_DATE_KEY  @"check.version.date.key"

+ (NSDate *)checkVersionDate {
    return [[self defaults] objectForKey:CHECK_VERSION_DATE_KEY];
}

+ (void)saveCheckVersionDate:(NSDate *)date {
    [[self defaults] setObject:date forKey:CHECK_VERSION_DATE_KEY];
}

#define LAST_PASSWORD_LOGIN_DATE    @"last.password.login.date.key"

+ (NSDate *)lastPassLoginDate {
    return [[self defaults] objectForKey:LAST_PASSWORD_LOGIN_DATE];
}

+ (void)saveLastPassLoginDate:(NSDate *)date {
    [[self defaults] setObject:date?:[NSDate date] forKey:LAST_PASSWORD_LOGIN_DATE];
}

#define LAST_CHECKIN_DATE    @"last.checkin.date.key"

+ (NSDate *)lastCheckinDateForUser:(NSString *)userid {
    NSString *key = [NSString stringWithFormat:@"%@-%@", LAST_CHECKIN_DATE, userid];
    return [[self defaults] objectForKey:key];
}

+ (void)saveLastCheckinDate:(NSDate *)date forUser:(NSString *)userid {
    NSString *key = [NSString stringWithFormat:@"%@-%@", LAST_CHECKIN_DATE, userid];
    [[self defaults] setObject:date?:[NSDate date] forKey:key];
}

@end
