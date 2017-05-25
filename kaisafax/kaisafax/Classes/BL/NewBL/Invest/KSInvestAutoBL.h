//
//  KSInvestAutoBL.h
//  kaisafax
//
//  Created by semny on 16/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSInvestAutoBL : KSRequestBL

//获取自动投标的配置信息
- (NSInteger)doGetAutoInvestInfo;

//保存自动投标的配置信息
- (NSInteger)doSaveAutoInvestInfoWithMinRate:(NSInteger)minRate maxRate:(NSInteger)maxRate minAmount:(NSInteger)minAmount maxAmount:(NSInteger)maxAmount reservedAmount:(NSString *)reservedAmount repayMethodIndex:(NSInteger)repayMethodIndex minDays:(NSInteger)minDays maxDays:(NSInteger)maxDays durType:(NSInteger)durType;
//开启自动投标
//- (NSInteger)doOpenAutoInvestWithMinRate:(NSInteger)minRate maxRate:(NSInteger)maxRate minAmount:(NSInteger)minAmount maxAmount:(NSInteger)maxAmount reservedAmount:(NSInteger)reservedAmount repayMethodIndex:(NSString*)repayMethodIndex minDays:(NSInteger)minDays maxDays:(NSInteger)maxDays durType:(NSInteger)durType;

//关闭自动投标
//- (NSInteger)doCloseAutoInvest;

@end
