//
//  KSHomeBL.h
//  kaisafax
//
//  Created by semny on 16/7/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBRequestBL.h"

@interface KSHomeBL : KSBRequestBL
#pragma mark - 业务请求
/**
 *  加载主页信息
 */
- (void)doGetHomeInfo;

@end
