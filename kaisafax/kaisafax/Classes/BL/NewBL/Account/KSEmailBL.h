//
//  KSEmailBL.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSEmailBL : KSRequestBL
- (NSInteger)doSetEmailWithStr:(NSString*)mailStr;

@end