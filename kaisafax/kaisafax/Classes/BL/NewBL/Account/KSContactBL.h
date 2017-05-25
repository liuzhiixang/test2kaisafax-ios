//
//  KSContactBL.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/24.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSContactBL : KSRequestBL
- (NSInteger)doSetContactWithName:(NSString*)name mobile:(NSString*)mobile relation:(NSInteger)relation;
@end
