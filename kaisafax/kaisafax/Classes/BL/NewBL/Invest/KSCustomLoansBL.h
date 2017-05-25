//
//  KSCustomLoansBL.h
//  kaisafax
//
//  Created by semny on 16/12/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"
#import "KSLoansEntity.h"
@interface KSCustomLoansBL : KSRequestBL

// 定制标列表
- (NSInteger)doGetCustomLoans;

@end
