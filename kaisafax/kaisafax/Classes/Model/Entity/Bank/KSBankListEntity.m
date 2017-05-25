//
//  KSBankListEntity.m
//  kaisafax
//
//  Created by semny on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBankListEntity.h"

@implementation KSBankListEntity

//+ (NSDictionary *)modelCustomPropertyMapper
//{
//    return @{@"bankList" : @[@"B2CBankList", @"QPBankList"]};
//}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"bankList" : KSBankEntity.class};
}
@end
