//
//  KSUIItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSLoanItemEntity.h"
#import "KSInvestItemEntity.h"

/**
 *  @author semny
 *
 *  用户投资记录下的单条数据
 */
@interface KSUIItemEntity : KSBaseEntity

//标的信息
@property (nonatomic, strong) KSLoanItemEntity *loan;
//已收本息
@property (nonatomic, copy) NSString *repayedAmount;
//总收益
@property (nonatomic, copy) NSString *totalProfit;
//内部投资信息
@property (nonatomic, strong) KSInvestItemEntity *invest;
//待收本息
@property (nonatomic, copy) NSString *undueAmount;

@end
