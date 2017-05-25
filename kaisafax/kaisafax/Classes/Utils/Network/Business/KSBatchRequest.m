//
//  KSBatchRequest.m
//  kaisafax
//
//  Created by semny on 16/7/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBatchRequest.h"

@implementation KSBatchRequest
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
- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId requestArray:(NSArray *)requestArray
{
    self = [super initWithRequestArray:requestArray];
    if (self)
    {
        //请求序列号
        _sequenceID = seqNo;
        _tradeId = tradeId;
    }
    return self;
}

@end
