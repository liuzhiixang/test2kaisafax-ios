//
//  KSInvestAboutBL.m
//  kaisafax
//
//  Created by semny on 16/8/17.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestAboutBL.h"
#import "KSUserMgr.h"
#import "KSInvestRecordEntity.h"
#import "KSInvestRecordItemEntity.h"

@interface KSInvestAboutBL()
@property (assign, nonatomic) NSInteger pageIndex;
@property (strong, nonatomic) KSInvestRecordEntity *reentity;
@end

@implementation KSInvestAboutBL

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _reentity = [[KSInvestRecordEntity alloc] init];
        _reentity.investData = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 独立的请求接口
/**
 *  @author semny
 *
 *  获取投资标的的详情数据
 *
 *  @param loanId 标的id
 */
- (NSInteger)doGetInvestDetailByLoanId:(long long)loanId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(loanId) forKey:kLoanIdKey];
    NSString *tradeId = KInvestDetailTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

/**
 *  @author semny
 *
 *  获取投资记录
 *
 *  @param loanId 标的id
 */
- (NSInteger)doGetInvestRecordByLoanId:(long long)loanId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSInteger start = 1;
    self.pageIndex = 1;
    NSInteger length = KInvestRecordPageMaxCount;
    [params setObject:[NSNumber numberWithInteger:start] forKey:kListPageStartKey];
    [params setObject:[NSNumber numberWithInteger:length] forKey:kListPageCountKey];
    [params setObject:@(loanId) forKey:kInvestLoanIdKey];
    NSString *tradeId = KInvestBidRecordTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}


/**
 *  加载更多投资列表数据
 */
- (void)doGetNextPageInvestRecordByLoanId:(long long)loanId
{
    NSInteger pageCount = KInvestRecordPageMaxCount;
    NSInteger pageIndex = self.pageIndex;
    long long seqNo = [self requestInvestRecordWithPageIndex:pageIndex pageCount:pageCount loanId:loanId];
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@NO,KRequestSearchType:@(1)}];
}

/**
 *  @author semny
 *
 *  获取投资标的回款计划数据(登录用户)
 *
 *  @param investId 投资记录id
 */
- (NSInteger)doGetInvestRepaysByInvestId:(long long)investId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(investId) forKey:kIdKey];
    NSString *tradeId = KReceivedRepaysTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

#pragma mark ------------------获取网络数据-------------------
- (long)requestInvestRecordWithPageIndex:(NSInteger)pageIndex pageCount:(NSInteger)pageCount loanId:(long long)loanId
{
    if (pageIndex <= 1 || pageCount <= 0)
    {
        ERROR(@"请求数据参数不对!");
        pageIndex = 1;
        pageCount = KInvestRecordPageMaxCount;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSInteger pageStart = pageIndex;
    [params setObject:[NSNumber numberWithInteger:pageStart] forKey:kListPageStartKey];
    [params setObject:[NSNumber numberWithInteger:pageCount] forKey:kListPageCountKey];
    [params setObject:@(loanId) forKey:kLoanIdKey];

    NSString *tradeId = KInvestBidRecordTradeId;
    return [self requestWithTradeId:tradeId data:params];
}

#pragma mark - BL请求回调
- (void)succeedCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //实体结果数据
    id body = responseEntity.body;
    long long sid = responseEntity.sid;
    NSString *tradeId = responseEntity.tradeId;
    KSResponseEntity *resp = responseEntity;
    //列表
    if ([tradeId isEqualToString:KInvestBidRecordTradeId])
    {
    
        //用户投资记录列表
        KSInvestRecordEntity *recordEntity = (KSInvestRecordEntity *)body;
        //列表数据
        NSArray<KSInvestRecordItemEntity*> *array =  recordEntity.investData;
        //下拉刷新

        {
            // 上拉加载更多
            if (self.pageIndex == 1)
            {
                DEBUGG(@"");
                //加载更多的时候其实是第0页
                //[self saveInfos:resultArr type:searchType clean:YES];
                if (array && array.count > 0)
                {
                    ++self.pageIndex;
                    //DEBUGG(@"(2)%@ resultArr:%d <<>> pageIndex: %d", self, (int)array.count, self.pageIndex);
                    //DEBUGG(@"(2)%@ resultArr:%@", self, array);
                }
            }
            else
            {
                //加载更多正常的时候
                //数据缓存好后，index必须立即改变，后续的缓存获取操作都需要使用到
                if (array && array.count > 0)
                {
                    //[self saveInfos:resultArr type:searchType];
                    ++self.pageIndex;
                    //DEBUGG(@"(3)%@ resultArr:%d <<>> pageIndex: %d", self, (int)array.count, self.pageIndex);
                    //DEBUGG(@"(3)%@ resultArr:%@", self, array);
                }
            }
            //创建刷新后的数据列表
            if (array && array.count > 0)
            {
                [_reentity.investData addObjectsFromArray:array];
                _reentity.totalSize = _reentity.investData.count;
            }
        }
        resp = [KSResponseEntity responseFromTradeId:tradeId sid:sid body:_reentity];
        resp.errorCode = responseEntity.errorCode;
        resp.errorDescription = responseEntity.errorDescription;
    }
    [super succeedCallbackWithResponse:resp];
}

- (void)failedCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //实体结果数据
    long long sid = responseEntity.sid;
    NSString *tradeId = responseEntity.tradeId;
    KSResponseEntity *resp = responseEntity;
    //列表
    if ([tradeId isEqualToString:KUserInvestListTradeId])
    {

        resp = [KSResponseEntity responseFromTradeId:tradeId sid:sid body:_reentity];
        resp.errorCode = responseEntity.errorCode;
        resp.errorDescription = responseEntity.errorDescription;
    }
    [super failedCallbackWithResponse:resp];
}

- (void)sysErrorCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //实体结果数据
    long long sid = responseEntity.sid;
    NSString *tradeId = responseEntity.tradeId;
    KSResponseEntity *resp = responseEntity;
    //列表
    if ([tradeId isEqualToString:KUserInvestListTradeId])
    {

        resp = [KSResponseEntity responseFromTradeId:tradeId sid:sid body:_reentity];
        resp.errorCode = responseEntity.errorCode;
        resp.errorDescription = responseEntity.errorDescription;
    }
    [super sysErrorCallbackWithResponse:resp];
}

@end
