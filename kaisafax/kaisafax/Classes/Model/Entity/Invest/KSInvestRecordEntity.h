//
//  KSInvestRecordEntity.h
//  kaisafax
//
//  Created by semny on 16/8/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSInvestRecordItemEntity.h"

/**
 *  @author semny
 *
 *  标的投资记录列表
 */
@interface KSInvestRecordEntity : KSBaseEntity

//投资记录表 KSInvestRecordItemEntity
@property (nonatomic, strong) NSMutableArray<KSInvestRecordItemEntity*> *investData;
//数量
@property (nonatomic, assign) NSInteger totalSize;

@end
