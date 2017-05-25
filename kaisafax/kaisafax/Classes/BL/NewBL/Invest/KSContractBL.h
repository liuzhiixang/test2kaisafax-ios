//
//  KSContractBL.h
//  kaisafax
//
//  Created by semny on 16/11/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSContractBL : KSRequestBL

//根据投资id获取合同信息
- (NSInteger)doGetContractWithInvestId:(NSString*)investId;

@end
