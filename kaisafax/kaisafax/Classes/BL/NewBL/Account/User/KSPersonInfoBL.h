//
//  KSPersonInfoBL.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSPersonInfoBL : KSRequestBL
/**
 *  @author Yubei
 *
 *  获取个人信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetPersonalInfo;

@end
