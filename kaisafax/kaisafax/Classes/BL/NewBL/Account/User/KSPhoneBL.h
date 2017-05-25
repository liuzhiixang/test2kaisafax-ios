//
//  KSPhoneBL.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/28.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSPhoneBL : KSRequestBL
- (NSInteger)doSetPhoneWithStr:(NSString*)phone mobileCap:(NSString*)cha;

@end
