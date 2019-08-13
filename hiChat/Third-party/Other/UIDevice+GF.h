//
//  UIDevice.h
//  AFNetworking
//
//  Created by zhangliyong on 2017/11/9.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface UIDevice (GF)

+ (NSString *)osPlatform;

+ (NSString *)osModel;

+ (NSString *)osVersion;

+ (NSString *)WiFiSSID;

+ (NSString *)WiFiBSSID;

+ (NSString *)appVersion;

+ (NSString *)appBuildVersion;

+ (NSString *)deviceID;

@end
