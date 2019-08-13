//
//  NSManagedObject+VICoreDataSource.m
//  Pods
//
//  Created by zhangliyong on 2017/6/28.
//
//

#import "NSManagedObject+VICoreDataSource.h"

@implementation NSManagedObject (VICoreDataSource)

+ (NSString *)entityName {
    return NSStringFromClass([self class]);
}

@end
