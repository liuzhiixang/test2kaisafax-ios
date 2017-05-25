//
//  KSJDCardExtractBL.h
//  kaisafax
//
//  Created by Jjyo on 2017/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSJDCardExtractBL : KSRequestBL



- (NSInteger)doGetCardWithAmount:(NSInteger)amount;

@end
