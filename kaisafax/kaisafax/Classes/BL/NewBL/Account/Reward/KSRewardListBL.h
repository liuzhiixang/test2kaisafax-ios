//
//  KSRewardListBL.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

/**
 *  @author semny
 *
 *  奖励列表信息
 */
@interface KSRewardListBL : KSRequestBL

//奖励的状态(加载列表的参数)
@property (nonatomic, copy) NSString *status;

/**
 *  加载最新的奖励列表数据
 */
- (void)refreshRewardList;

/**
 *  加载更多奖励列表数据
 */
- (void)requestNextPageRewardList;
@end
