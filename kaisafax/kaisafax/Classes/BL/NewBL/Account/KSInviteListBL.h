//
//  KSInviteListBL.h
//  kaisafax
//
//  Created by semny on 16/8/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

/**
 *  @author semny
 *
 *  推荐人列表
 */
@interface KSInviteListBL : KSRequestBL

/**
 *  加载最新的推荐人列表数据
 */
- (void)refreshInviteList;

/**
 *  加载更多推荐人列表数据
 */
- (void)requestNextPageInviteList;

@end
