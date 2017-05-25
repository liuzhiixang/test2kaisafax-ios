//
//  KSAccountBL.m
//  kaisafax
//
//  Created by semny on 17/4/11.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSAccountBL.h"
#import "KSBatchRequest.h"


@interface KSAccountBL()<SQBatchRequestDelegate>

//多个组合请求
@property (strong, nonatomic) KSBatchRequest *batchRequest;

@end


@implementation KSAccountBL

#pragma mark - batch组合接口

- (void)refreshAccountPage
{
    //账户信息
    KSBRequest *request1 = [self createUserNewAssetsRequest];
    //奖励
    KSBRequest *request2 = [self createRewardsRequest];
    //定指标
    KSBRequest *request3 = [self createCustomLoansRequest];
    //累计收益
    KSBRequest *request4 = [self createAcculateAssetsRequest];
    //组合请求
    NSInteger homeSeqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSArray *requestArray = @[request1, request2, request3, request4];
    NSString *tradeId = KAccountBatchRequestTradeId;
    _batchRequest = [[KSBatchRequest alloc] initWithSequenceID:homeSeqNo tradeId:tradeId requestArray:requestArray];
    _batchRequest.delegate = self;
    //存储序列号
    //long long seqNo = request2.sequenceID;
    //开启请求
    [_batchRequest start];
}

//定指标
- (KSBRequest *)createCustomLoansRequest
{
    //定指标
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KCustomLoansTradeId;
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    KSBRequest *request = [self createRequest:tradeId seqNo:seqNo data:params URL:SX_APP(tradeId) httpMethod:SQRequestMethodPost error:&error];
    return request;
}

//累计收益
- (KSBRequest *)createAcculateAssetsRequest
{
    //累计收益
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetUserAccumulatedIncomeTradeId;
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    KSBRequest *request = [self createRequest:tradeId seqNo:seqNo data:params URL:SX_APP(tradeId) httpMethod:SQRequestMethodPost error:&error];
    return request;
}

//奖励
- (KSBRequest *)createRewardsRequest
{
    //奖励
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetValidRewardsDetailTradeId;
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    KSBRequest *request = [self createRequest:tradeId seqNo:seqNo data:params URL:SX_APP(tradeId) httpMethod:SQRequestMethodPost error:&error];
    return request;
}

//账户信息
- (KSBRequest *)createUserNewAssetsRequest
{
    //账户信息
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KUserNewAssetsTradeId;
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    KSBRequest *request = [self createRequest:tradeId seqNo:seqNo data:params URL:SX_APP(tradeId) httpMethod:SQRequestMethodPost error:&error];
    return request;
}


@end
