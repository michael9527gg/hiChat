//
//  CheckinData.h
//  hiChat
//
//  Created by Polly polly on 19/06/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckinData : NSObject

@property (nonatomic, copy)     NSString    *uid;
@property (nonatomic, copy)     NSString    *title;
@property (nonatomic, copy)     NSString    *imageUrl;
@property (nonatomic, assign)   BOOL        checkinToday;
@property (nonatomic, copy)     NSString    *checkinDays;

+ (instancetype)checkinWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
