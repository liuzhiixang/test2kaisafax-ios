//
//  KSRegRedPackEntity.h
//  kaisafax
//
//  Created by semny on 16/8/8.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSRewardItemEntity.h"

/**
 *  @author semny
 *
 *  注册后获取红包的数据实体
 */
@interface KSRegRedPackEntity : KSBaseEntity

//红包列表(注册, KSRewardItemEntity)
@property (nonatomic, strong) NSArray<KSRewardItemEntity *> *result;
@property (nonatomic, assign) NSInteger totalSize;


@end
