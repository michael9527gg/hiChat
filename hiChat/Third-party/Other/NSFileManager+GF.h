//
//  NSFileManager+GF.h
//  AFNetworking
//
//  Created by zhangliyong on 2018/4/23.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (GF)

- (unsigned long long)sizeOfFolder:(NSString *)folderPath;

- (NSString *)stringSizeOfFolder:(NSString *)folderPath;

@end
