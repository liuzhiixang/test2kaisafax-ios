//
//  KSBRequest.m
//  kaisafax
//
//  Created by semny on 16/7/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBRequest.h"
#import "SQNetworkPrivate.h"
#import "KSRequestService.h"

//业务请求超时设置
#define KSBRequestTimeoutInterval  10

@implementation KSBRequest

/**
 *  根据请求序列号初始化请求对象
 *
 *  @param seqNo 请求序列号
 *  @param tradeId 接口编号，表示请求的业务类型
 *
 *  @return 请求对象
 */
- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId
{
    return [self initWithSequenceID:seqNo tradeId:tradeId updateSession:NO];
}

- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId updateSession:(BOOL)updateSession
{
    self = [super init];
    if (self)
    {
        //请求序列号
        _sequenceID = seqNo;
        _tradeId = tradeId;
        //是否需要session
        _updateSession = updateSession;
        //超时
        self.requestTimeoutInterval = KSBRequestTimeoutInterval;
    }
    return self;
}

- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId header:(NSDictionary*)header body:(NSDictionary*)body
{
    return [self initWithSequenceID:seqNo tradeId:tradeId header:header body:body updateSession:NO];
}

- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId header:(NSDictionary*)header body:(NSDictionary*)body updateSession:(BOOL)updateSession
{
    self = [super init];
    if (self)
    {
        //请求序列号
        _sequenceID = seqNo;
        _tradeId = tradeId;
        
        //是否需要session
        _updateSession = updateSession;
        
        //请求数据(header和body组合request数据)
        _header = header;
        _body = body;
        
        //超时
        self.requestTimeoutInterval = KSBRequestTimeoutInterval;
    }
    return self;
}

- (NSUInteger)hash
{
    if (_tradeId && _tradeId.length > 0)
    {
        NSString *hashStr = [NSString stringWithFormat:@"%@%lld", _tradeId, (long long)_sequenceID];
        return hashStr.hash;
    }
    return [super hash];
}

#pragma mark - super method
- (void)start
{
    [self toggleAccessoriesWillStartCallBack];
    [[KSRequestService sharedInstance] addRequest:self];
}
@end
