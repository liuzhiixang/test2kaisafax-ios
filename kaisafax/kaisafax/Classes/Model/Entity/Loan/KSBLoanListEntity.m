//
//  KSBLoansEntity.m
//  kaisafax
//
//  Created by semny on 16/9/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBLoanListEntity.h"

@implementation KSBLoanListEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"dataList" : KSLoanItemEntity.class};
}
@end
