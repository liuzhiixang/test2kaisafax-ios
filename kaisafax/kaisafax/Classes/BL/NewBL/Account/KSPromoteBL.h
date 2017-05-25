//
//  KSPromoteBL.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

/**
 *  @author semny
 *
 *  推广
 */
@interface KSPromoteBL : KSRequestBL

/**
 *  @author semny
 *
 *  获取我的推广信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetPromoteInfo;

/**
 *  @author semny
 *
 *  获取我的推广收益信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetPromoteIncomeInfo;

@end
