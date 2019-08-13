//
//  RCProfileMessage.m
//  kaixinliao
//
//  Created by zhangliyong on 15/12/2018.
//  Copyright © 2018 kaixinliao. All rights reserved.
//

#import "RCCustomMessage.h"

@implementation RCCustomMessage

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.operation = [aDecoder decodeObjectForKey:@"operation"];
        self.data = [aDecoder decodeObjectForKey:@"data"];
        self.extra = [aDecoder decodeObjectForKey:@"extra"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.operation forKey:@"operation"];
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
}

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.operation forKey:@"operation"];
    [dataDict setObject:self.data forKey:@"data"];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;

        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (dictionary) {
            NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            NSString *prettyPrintedJson = [[[NSString alloc] initWithData:prettyJsonData encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" : " withString:@": "];
            NSLog(@"RCCustomMessage received:\n%@", prettyPrintedJson);
        }

        if (dictionary) {
            NSDictionary *extra = YUCLOUD_VALIDATE_DICTIONARY([dictionary valueForKey:@"extra"]);
            if(extra) {
                self.operation = YUCLOUD_VALIDATE_STRING(extra[@"operation"]);
                self.data = YUCLOUD_VALIDATE_DICTIONARY(extra[@"data"]);
            }
            else {
                self.operation = YUCLOUD_VALIDATE_STRING(dictionary[@"operation"]);
                self.data = YUCLOUD_VALIDATE_DICTIONARY(dictionary[@"data"]);
                self.extra = YUCLOUD_VALIDATE_DICTIONARY(dictionary[@"extra"]);
            }
        }
    }
}

+ (NSString *)getObjectName {
    return @"KX:CustomNtf";
}

- (NSString *)conversationDigest {
    return [self.data valueForKey:@"title"];
}

@end
