//
//  KSAssetsBL.h
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

//资产明细
@interface KSAssetsBL : KSRequestBL

/**
 *  @author semny
 *
 *  获取当前用户的个人账户财富信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserNewAssets;

/**
 *  @author semny
 *
 *  获取当前用户的个人账户财富信息
 *
 *  @param delegate 网络请求delegate
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserNewAssetsByDelegate:(id<SQRequestDelegate>)delegate;

/**
 *  @author semny
 *
 *  获取当前用户的累积收益
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserAccumulatedIncome;

@end
