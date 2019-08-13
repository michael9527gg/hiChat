//
//  RCProfileMessage.h
//  kaixinliao
//
//  Created by zhangliyong on 15/12/2018.
//  Copyright © 2018 kaixinliao. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCustomMessage : RCMessageContent < NSCoding >

@property (nonatomic, copy) NSString        *operation;

@property (nonatomic, copy) NSDictionary    *data;

@property (nonatomic, copy) NSString        *extra;

@end

NS_ASSUME_NONNULL_END
