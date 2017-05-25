//
//  KSBatchRequest.h
//  kaisafax
//
//  Created by semny on 16/7/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SQBatchRequest.h"

@interface KSBatchRequest : SQBatchRequest

//接口名称
@property (nonatomic, copy, readonly) NSString *tradeId;
//SID
@property (nonatomic, assign, readonly) long long sequenceID;

/**
 *  @author semny
 *
 *  根据请求序列号,接口编号，batch请求的各个子请求对象数组 初始化请求对象
 *
 *  @param seqNo        请求序列号
 *  @param tradeId      接口编号
 *  @param requestArray batch请求的各个子请求对象数组
 *
 *  @return 请求对象
 */
- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId requestArray:(NSArray *)requestArray;

@end
