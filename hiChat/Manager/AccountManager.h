//
//  AccountManager.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "BaseManager.h"
#import "CloudInterface.h"
#import <WechatOpenSDK/WXApi.h>

#define WECHAT_APP_ID           @"wx736fa016dd9e829e"

#define YUCLOUD_ACCOUNT_USERID              [AccountManager manager].loginid
#define YUCLOUD_ACCOUNT_TOKEN               [AccountManager manager].token
#define YUCLOUD_ACCOUNT_NAME                [AccountManager manager].accountInfo.nickname
#define YUCLOUD_ACCOUNT_PORTRAIT            [AccountManager manager].accountInfo.portraitUri

#define ACCOUNT_STATUS_KEYPATH              @"accountStatus"

typedef NS_ENUM(NSInteger, YuCloudDataActions) {
    YuCloudDataList,
    YuCloudDataAdd,
    YuCloudDataEdit,
    YuCloudDataDelete
};

typedef enum : NSUInteger {
    AccountToken,
    AccountPhone,
    AccountWechat
} LoginAccountType;

typedef enum : NSUInteger {
    InfoBindTypeSignUp = 1,
    InfoBindTypeLogined
} InfoBindType;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (User)

- (BOOL)isSpecialUser;

@end

@interface UIImage (avatar)

+ (NSString *)defaultAvatarUrl;

+ (UIImage *)defaultAvatar;

@end

@interface AccountInfo : NSObject

@property (nonatomic, copy)   NSString        *phone;
@property (nonatomic, copy)   NSString        *loginid;
@property (nonatomic, copy)   NSString        *appKey;
@property (nonatomic, copy)   NSString        *sign;
@property (nonatomic, copy)   NSString        *rcKey;
@property (nonatomic, copy)   NSString        *rcToken;
@property (nonatomic, copy)   NSString        *nickname;
@property (nonatomic, copy)   NSString        *portraitUri;
@property (nonatomic, copy)   NSString        *account;
@property (nonatomic, copy)   NSString        *role;
@property (nonatomic, copy)   NSString        *invitationCode;
@property (nonatomic, copy)   NSURL           *platformUrl;
@property (nonatomic, copy)   NSString        *platformName;
@property (nonatomic, assign) BOOL            isStaff;

+ (instancetype)infoFromData:(NSDictionary *)data;

@end

@interface AccountManager : BaseManager < WXApiDelegate >

@property (nonatomic, strong, readonly)   AccountInfo   *accountInfo;

@property (nonatomic, readonly, nullable) NSString      *loginid;
@property (nonatomic, readonly, nullable) NSString      *token;
@property (nonatomic, readonly, nullable) NSString      *rcKey;
@property (nonatomic, readonly, nullable) NSString      *rcToken;

- (BOOL)isSignin;
- (BOOL)isLocalSignin;
- (BOOL)isServerSignin;
- (BOOL)isStaff;
- (BOOL)isSpecialUser;
- (BOOL)isSpecialOrStaff;

- (void)startAutoLoginWithCompletion:(nullable CommonBlock)completion;

- (void)showWechatAuthWithCompletion:(CommonBlock)completion;

- (void)requestSmsWithPhone:(NSString *)phone
                     reason:(NSString *)reason
                 completion:(nullable CommonBlock)completion;

- (void)registerWithName:(NSString *)name
                   phone:(NSString *)phone
                    pass:(NSString *)pass
                 smsCode:(NSString *)smsCode
          invitationCode:(NSString *)invitationCode
              completion:(nullable CommonBlock)completion;

- (void)loginWithPhone:(nullable NSString *)phone
                  pass:(nullable NSString *)pass
                 token:(nullable NSString *)token
                  code:(nullable NSString *)code
            completion:(nullable CommonBlock)completion;

- (void)twoStepVerify:(NSString *)token
                 code:(NSString *)code
           completion:(nullable CommonBlock)completion;

- (void)logoutWithCompletion:(nullable CommonBlock)completion;

- (void)changePassword:(NSString *)newPass
               oldPass:(NSString *)oldPass
            completion:(nullable CommonBlock)completion;

- (void)requestMeInfoWithAction:(YuCloudDataActions)action
                           user:(NSString *)userid
                           info:(nullable AccountInfo *)info
                     completion:(nullable CommonBlock)completion;

- (void)requestVersionWithCompletion:(nullable CommonBlock)completion;

- (void)fillInfoWithAccessToken:(NSString *)token
                          phone:(NSString *)phone
                           code:(NSString *)code
                     inviteCode:(NSString *)inviteCode
                     completion:(nullable CommonBlock)completion;

- (void)resetPassword:(NSString *)phone
                 pass:(NSString *)pass
                 code:(NSString *)code
           completion:(CommonBlock)completion;

- (void)requestPlatformInfoWithCompletion:(nullable CommonBlock)completion;

- (void)processInvalidToken;

- (void)requestCheckinWithAction:(YuCloudDataActions)action
                          taskId:(nullable NSString *)taskId
                      completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
