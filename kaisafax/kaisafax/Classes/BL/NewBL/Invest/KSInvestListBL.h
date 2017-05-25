//
//  KSInvestListBL.h
//  kaisafax
//
//  Created by semny on 16/6/30.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"
#import "KSUserInvestsEntity.h"

/**
 *  @author semny
 *
 *  用户投资列表接口
 */
@interface KSInvestListBL : KSRequestBL

//投资记录的状态
@property (nonatomic, assign) NSInteger status;

/**
 *  加载最新的投资列表数据
 */
- (void)refreshUserInvestList;

/**
 *  加载更多投资列表数据
 */
- (void)requestNextPageUserInvestList;

@end
