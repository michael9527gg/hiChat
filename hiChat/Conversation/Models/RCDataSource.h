//
//  RCDataSource.h
//  hiChat
//
//  Created by Polly polly on 13/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

#define RCCDataSource [RCDataSource shareInstance]

NS_ASSUME_NONNULL_BEGIN

@interface RCDataSource : NSObject < RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupMemberDataSource >

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
