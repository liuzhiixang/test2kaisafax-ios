//
//  KSLoanDetailEntity.h
//  kaisafax
//
//  Created by semny on 16/8/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSLoanItemEntity.h"

/**
 *  @author semny
 *
 *  标的详情数据(投资页面)
 */
@interface KSLoanDetailEntity : KSBaseEntity

@property (nonatomic, strong) KSLoanItemEntity *loan;
//是否可以投资
@property (nonatomic, assign) BOOL canInvest;

@property (nonatomic, assign) NSInteger serverTime;

@property (nonatomic, copy) NSString *status;
//合同号 | 查看投资协议需要传这个参数
@property (nonatomic, copy) NSString *contract;

@end

