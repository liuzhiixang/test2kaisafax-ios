//
//  KSUserInvestsEntity.h
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSUIItemEntity.h"

/**
 *  @author semny
 *
 *  用户投资记录列表
 */
@interface KSUserInvestsEntity : KSBaseEntity

@property (nonatomic, assign) NSInteger recordsFiltered;
//标的数据列表 KSUIItemEntity
@property (nonatomic, strong) NSArray<KSUIItemEntity*> *investList;
@property (nonatomic, assign) NSInteger recordsTotal;

@end
