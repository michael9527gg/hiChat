//
//  CloudInterface.h
//  hiChat
//
//  Created by zhangliyong on 2018/12/12.
//  Copyright © 2018年 HiChat Org. All rights reserved.
//

#import "VICocoaTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (response)

- (NSInteger)code;

- (BOOL)success;

- (NSString *)msg;

@end

@interface CloudInterface : CommonInterface

@end

NS_ASSUME_NONNULL_END
