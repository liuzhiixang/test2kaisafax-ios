//
//  KSNewBeeBL.h
//  kaisafax
//
//  Created by semny on 16/9/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSNewBeeBL : KSRequestBL

/**
 *  @author semny
 *
 *  获取新手标相惜数据
 *
 *  @return 请求序列号
 */
- (NSInteger)doGetNewBeeDetail;

@end
