//
//  KSWithdrawBL.h
//  kaisafax
//
//  Created by semny on 16/8/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

/**
 *  @author semny
 *
 *  体现信息相关BL
 */
@interface KSWithdrawBL : KSRequestBL

/**
 *  @author semny
 *
 *  获取提现信息(默认提现卡，银行，其他信息)
 *
 *  @return 序列号
 */
- (NSInteger)doGetWithdrawInfo;

@end
