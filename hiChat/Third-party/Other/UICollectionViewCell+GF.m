//
//  UICollectionViewCell+GF.m
//  GFCocoaTools
//
//  Created by zhangliyong on 2017/3/14.
//  Copyright © 2017年 zhangliyong@gmail.com. All rights reserved.
//

#import "UICollectionViewCell+GF.h"

@implementation UICollectionViewCell (GF)

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

@end
