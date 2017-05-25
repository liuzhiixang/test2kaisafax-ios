//
//  KSValidRewardEntity.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  红包奖励(老接口，我的红包列表使用)
 */
@interface KSValidRedRewardEntity : KSBaseEntity

//可提取奖励金额
@property (nonatomic, assign) CGFloat qualified;

//审核中的金额
@property (nonatomic, assign) CGFloat invoked;

@end
