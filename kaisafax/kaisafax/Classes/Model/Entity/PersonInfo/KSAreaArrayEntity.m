//
//  KSAreaArrayEntity.m
//  kaisafax
//
//  Created by yubei on 2017/5/3.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSAreaArrayEntity.h"
#import "KSAreaEntity.h"

@implementation KSAreaArrayEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"result" : KSAreaEntity.class};
}
@end
