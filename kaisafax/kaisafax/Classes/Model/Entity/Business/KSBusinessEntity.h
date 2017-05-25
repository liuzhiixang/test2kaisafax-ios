//
//  KSBusinessEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSBussinessItemEntity.h"

/**
 *  @author semny
 *
 *  首页运营图数据
 */
@interface KSBusinessEntity : KSBaseEntity

//array KSBussinessItemEntity
@property (nonatomic, strong) NSArray<KSBussinessItemEntity*> *businessList;

@end
