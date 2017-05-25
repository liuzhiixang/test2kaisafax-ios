//
//  KSInvestRecordEntity.m
//  kaisafax
//
//  Created by semny on 16/8/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestRecordEntity.h"

@implementation KSInvestRecordEntity
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"investData" : KSInvestRecordItemEntity.class};
}

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{@"recordList" : @"result"};
//}

@end
