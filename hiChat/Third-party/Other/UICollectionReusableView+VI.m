//
//  UICollectionReusableView+VI.m
//  AFNetworking
//
//  Created by zhangliyong on 2018/8/3.
//

#import "UICollectionReusableView+VI.h"

@implementation UICollectionReusableView (VI)

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

@end
