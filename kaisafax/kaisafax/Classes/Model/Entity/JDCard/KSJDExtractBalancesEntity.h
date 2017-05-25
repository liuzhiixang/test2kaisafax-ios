//
//  KSJDExtractBalancesEntity.h
//  kaisafax
//
//  Created by Jjyo on 2017/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

//制卡后剩下的余额
@interface KSJDExtractBalancesEntity : KSBaseEntity

//余额
@property (nonatomic, copy) NSString *jdAmount;


@end
