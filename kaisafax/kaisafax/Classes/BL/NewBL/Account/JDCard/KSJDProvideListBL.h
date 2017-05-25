//
//  KSJDProvideListBL.h
//  kaisafax
//
//  Created by Jjyo on 2017/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

//发放记录
@interface KSJDProvideListBL : KSRequestBL

/**
 *  加载最新的京东制卡纪录列表数据
 */
- (void)refreshJDProvideList;

/**
 *  加载更多京东制卡纪录列表数据
 */
- (void)requestNextPageJDProvideList;

@end
