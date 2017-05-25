//
//  KSFilterUtils.h
//  kaisafax
//
//  Created by philipyu on 16/9/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSFilterUtils : NSObject
+ (instancetype)sharedInstance;

//过滤跟版本号，渠道号，平台号都匹配的benner／notice数组
-(id)pickupValidBanner:(id)item Platform:(NSArray*)platformTypes Versions:(NSArray*)appVersions Channels:(NSArray*)appChannels Status:(NSString*)status;
@end
