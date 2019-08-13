//
//  CheckinData.m
//  hiChat
//
//  Created by Polly polly on 19/06/2019.
//  Copyright © 2019 HiChat Org. All rights reserved.
//

#import "CheckinData.h"

@implementation CheckinData

+ (instancetype)checkinWithDic:(NSDictionary *)dic {
    return [[self alloc] initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if(self = [super init]) {
        self.uid = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"id"]);
        self.title = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"title"]);
        self.imageUrl = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"imageurl"]);
        NSNumber *number = YUCLOUD_VALIDATE_NUMBER([dic valueForKey:@"checkin_today"]);
        self.checkinToday = number.boolValue;
        self.checkinDays = YUCLOUD_VALIDATE_STRING([dic valueForKey:@"checkin_days"]);
    }
    
    return self;
}

@end
