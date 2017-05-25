//
//  KSORLoanEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSRecomLoanEntity.h"
#import "KSOwnerLoanItemEntity.h"
#import "KSRecommendDataEntity.h"

/**
 *  @author semny
 *
 *  推荐，物业宝 标的信息
 */
@interface KSORLoanEntity : KSBaseEntity

//推荐数据
//@property (nonatomic, strong) NSArray<KSRecomLoanEntity*> *recommendData;
@property (nonatomic, strong) KSRecommendDataEntity *recommendData;

//物业宝数据 KSOwnerLoanItemEntity
@property (nonatomic, strong) NSArray<KSOwnerLoanItemEntity*> *ownerLoansData;

@end
