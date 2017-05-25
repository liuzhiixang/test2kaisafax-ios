//
//  KSInvestAutoInfoEntity.h
//  kaisafax
//
//  Created by semny on 16/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSInvestAutoConfigEntity.h"
//#import "KSRepayMethodEntity.h"

@interface KSInvestAutoInfoEntity : KSBaseEntity

//自动投标配置信息
@property (nonatomic, strong) KSInvestAutoConfigEntity *autoInvest;
//自动投标的还款方式选择
//@property (nonatomic, strong) KSRepayMethodEntity *repayMethod;

@end
