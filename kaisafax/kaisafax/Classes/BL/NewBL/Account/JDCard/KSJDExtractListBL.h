//
//  KSJDExtractListBL.h
//  kaisafax
//
//  Created by semny on 17/3/23.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

//京东卡余额及领取列表
@interface KSJDExtractListBL : KSRequestBL

/**
 *  加载最新的京东制卡纪录列表数据
 */
- (void)refreshJDExtractList;

/**
 *  加载更多京东制卡纪录列表数据
 */
- (void)requestNextPageJDExtractList;

@end
