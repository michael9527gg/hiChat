//
//  AFDataResponseSerializer.m
//
//

#import "AFDataResponseSerializer.h"

@implementation AFDataResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing  _Nullable *)error {
    return [NSData dataWithData:data];
}

@end
