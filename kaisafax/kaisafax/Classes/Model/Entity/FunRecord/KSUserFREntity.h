//
//  KSUserFREntity.h
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSUserFRItemEntity.h"

/**
 *  @author semny
 *
 *  用户资金交易记录
 */
@interface KSUserFREntity : KSBaseEntity

//@property (nonatomic, assign) NSInteger recordsFiltered;
////总共记录数
//@property (nonatomic, assign) NSInteger recordsTotal;
//记录列表数据 KSUserFRItemEntity
@property (nonatomic, strong) NSArray<KSUserFRItemEntity*> *fundList;

@end
