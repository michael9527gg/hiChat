//
//  UserDataSource.h
//  hiChat
//
//  Created by Polly polly on 16/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "VICocoaTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserData : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *portrait;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *platformName;

@property (nonatomic, readonly) NSString *name;

+ (instancetype)userWithDic:(NSDictionary *)dic;

@end

@interface UserDataSource : VIDataSource

@end

NS_ASSUME_NONNULL_END
