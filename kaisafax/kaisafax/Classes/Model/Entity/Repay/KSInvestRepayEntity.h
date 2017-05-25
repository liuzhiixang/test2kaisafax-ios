//
//  KSInvestRepayEntity.h
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSIRItemEntity.h"

/**
 *  @author semny
 *
 *  投资回款计划
 */
@interface KSInvestRepayEntity : KSBaseEntity

//回款计划数据 KSIRItemEntity
@property (nonatomic, strong) NSArray<KSIRItemEntity*> *repayList;
@property (nonatomic, copy) NSString *loanProduct;
//标的标题
@property (nonatomic, copy) NSString *loanTitle;

@end
