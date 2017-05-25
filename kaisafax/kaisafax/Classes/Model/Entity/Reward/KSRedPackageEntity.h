//
//  KSRedPackageEntity.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSRealmEntity.h"

/**
 *  @author semny
 *
 *  红包信息
 */
@interface KSRedPackageEntity : KSBaseEntity

//生效时间
@property (nonatomic, strong) NSDate *availableTime;
//枚举 类型 1: REDBAG-红包，2:CASH-现金券
@property (nonatomic, assign) NSInteger type;
//奖券包规则ID
@property (nonatomic, copy) NSString *rpId;
//最小投资金额
@property (nonatomic, assign) NSInteger minAmount;
//奖券包名称
@property (nonatomic, copy) NSString *name;
/*
@property (nonatomic, copy) NSString *eventType;

@property (nonatomic, strong) KSRealmEntity *creator;

@property (nonatomic, assign) NSInteger bonus;
@property (nonatomic, assign) NSInteger ratio;

@property (nonatomic, assign) NSInteger maxAmount;
@property (nonatomic, assign) NSInteger splitAmount;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, strong) NSDate *recordTime;

@property (nonatomic, strong) NSDate *expiredTime;
@property (nonatomic, assign) NSInteger expiredDays;
@property (nonatomic, assign) NSInteger minInvestAmount;
@property (nonatomic, copy) NSString *remark;
*/
@end
