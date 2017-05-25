//
//  KSRequestUtils.h
//  kaisafax
//
//  Created by semny on 17/5/9.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSRequestUtils : NSObject

//创建请求参数(包括header)
+ (NSDictionary *)createArgumentWithTradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error;

@end
