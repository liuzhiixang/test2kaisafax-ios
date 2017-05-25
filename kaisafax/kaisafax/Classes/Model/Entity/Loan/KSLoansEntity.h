//
//  KSLoanListEntity.h
//  kaisafax
//
//  Created by semny on 16/8/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSLoanItemEntity.h"

/**
 *  @author semny
 *
 *  普通投资列表数据
 */
@interface KSLoansEntity : KSBaseEntity

@property (nonatomic, assign) NSInteger recordsFiltered;
//标的数据列表 KSLoanItemEntity
@property (nonatomic, strong) NSArray<KSLoanItemEntity*> *loanList;
@property (nonatomic, assign) long long serverTime;
@property (nonatomic, assign) NSInteger total;



@end
