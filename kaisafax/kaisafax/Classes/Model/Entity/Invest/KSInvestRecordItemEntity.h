//
//  KSInvestRecordItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  标的投资记录单条信息(单条)
 */
@interface KSInvestRecordItemEntity : KSBaseEntity

//投资者
@property (nonatomic, copy) NSString *investor;
// 状态
@property (nonatomic, assign) NSInteger status;
//金额
@property (nonatomic, copy) NSString *amount;
//投资时间
@property (nonatomic, strong) NSDate *investTime;
//是否自动投资
@property (nonatomic, assign) BOOL isAutoInvest;

@end
