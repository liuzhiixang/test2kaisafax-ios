//
//  KSInvestBL.m
//  kaisafax
//
//  Created by semny on 16/7/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestBL.h"
#import "KSBatchRequest.h"
#import "KSUserMgr.h"
#import "KSLoansEntity.h"
#import "KSBLoanListEntity.h"

@interface KSInvestBL()<SQBatchRequestDelegate>

//多个组合请求
@property (strong, nonatomic) KSBatchRequest *batchRequest;

//页数(从0开始)
@property (nonatomic, assign) long pageIndex;
//返回数据
@property (nonatomic, strong) KSBLoanListEntity *dataList;
@end


//分页数据的一页数量(服务端API写屎了，只能是这么多了，不能多不能少，不然会出问题的，看着办吧)
#define KPageMaxCount        10

@implementation KSInvestBL
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _dataList = [[KSBLoanListEntity alloc] init];
    }
    return self;
}

#pragma mark - batch组合接口
/**
 *  @author semny
 *
 *  (刷新)加载投资标的列表数据(新手标＋普通标)
 */
//- (void)doGetInvestList
//{
//    //新手标
//    SQBaseRequest *request1 = [self createNewBeeRequest];
//    //普通标
//    SQBaseRequest *request2 = [self createRefreshInvestListRequest];
//    //组合请求
//    NSInteger homeSeqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
//    NSArray *requestArray = @[request1, request2];
//    NSString *tradeId = KInvestBatchRequestTradeId;
//    _batchRequest = [[KSBatchRequest alloc] initWithSequenceID:homeSeqNo tradeId:tradeId requestArray:requestArray];
//    _batchRequest.delegate = self;
//    //开启请求
//    [_batchRequest start];
//}

/**
 *  @author semny
 *
 *  加载投资标的列表数据(新手标＋普通标)
 */
- (void)refreshInvestList
{
    //新手标
    KSBRequest *request1 = [self createNewBeeRequest];
    //普通标
    KSBRequest *request2 = [self createRefreshInvestListRequest];
    //组合请求
    long long homeSeqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSArray *requestArray = @[request1, request2];
    NSString *tradeId = KInvestBatchRequestTradeId;
    _batchRequest = [[KSBatchRequest alloc] initWithSequenceID:homeSeqNo tradeId:tradeId requestArray:requestArray];
    _batchRequest.delegate = self;
    //存储序列号
    //long long seqNo = request2.sequenceID;
    //开启请求
    [_batchRequest start];
}

/**
 *  加载更多投资列表数据（暂时只加载下一页普通的投资列表）
 */
- (void)requestNextPageInvestList
{
    //普通标
    KSBRequest *request2 = [self createNextPageInvestListRequest];
    //组合请求
    long long homeSeqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSArray *requestArray = @[request2];
    NSString *tradeId = KInvestBatchRequestTradeId;
    _batchRequest = [[KSBatchRequest alloc] initWithSequenceID:homeSeqNo tradeId:tradeId requestArray:requestArray];
    _batchRequest.delegate = self;
    //存储序列号
    //long long seqNo = request2.sequenceID;
    //开启请求
    [_batchRequest start];
}

#pragma mark - 创建请求
/**
 *  @author semny
 *
 *  创建 新手标 请求对象
 *
 *  @return 请求对象
 */
- (KSBRequest *)createNewBeeRequest
{
    //新手标
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KInvestNewBeeTradeId;
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    KSBRequest *request = [self createRequest:tradeId seqNo:seqNo data:params URL:SX_APP_API httpMethod:SQRequestMethodPost error:&error];
    return request;
}

/**
 *  加载最新的投资列表数据
 */
- (KSBRequest *)createRefreshInvestListRequest
{
    NSInteger pageCount = KPageMaxCount;
    self.pageIndex = 1;
    NSInteger pageIndex = 1;
    KSBRequest *request = [self createInvestListRequestWithPageIndex:pageIndex pageCount:pageCount];
    long long seqNo = request.sequenceID;
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@YES , KPageIndexKey:@(pageIndex)}];
    return request;
}

/**
 *  加载最新的投资列表数据
 */
- (KSBRequest *)createNextPageInvestListRequest
{
    NSInteger pageCount = KPageMaxCount;
    NSInteger pageIndex = self.pageIndex;
    KSBRequest *request = [self createInvestListRequestWithPageIndex:pageIndex pageCount:pageCount];
    long long seqNo = request.sequenceID;
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@NO, KPageIndexKey:@(pageIndex)}];
    return request;
}

/**
 *  @author semny
 *
 *  请求投资列表
 */
- (KSBRequest *)createInvestListRequestWithPageIndex:(NSInteger)pageIndex pageCount:(NSInteger)pageCount
{
    if (pageIndex <= 1 || pageCount <= 0)
    {
        ERROR(@"请求数据参数不对!");
        pageIndex = 1;
        pageCount = KPageMaxCount;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    NSInteger pageStart = pageIndex*pageCount;
    [params setObject:[NSNumber numberWithInteger:pageIndex] forKey:kListPageStartKey];
    [params setObject:[NSNumber numberWithInteger:pageCount] forKey:kListPageCountKey];
    
    NSString *tradeId = KInvestListTradeId;
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    
    KSBRequest *request = [self createRequest:tradeId seqNo:seqNo data:params URL:SX_APP_API httpMethod:SQRequestMethodPost error:&error];
    return request;
}

#pragma mark - BL请求回调
- (void)succeedItemBatchCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //实体结果数据
    id body = responseEntity.body;
    long long sid = responseEntity.sid;
    NSString *tradeId = responseEntity.tradeId;
    KSResponseEntity *resp = responseEntity;
    //列表
    if ([tradeId isEqualToString:KInvestListTradeId])
    {
        BOOL isRefresh = [self isRefreshFromSeqNo:sid];
        NSInteger tPageIndex = [self getPageIndexFromSeqNo:sid];
        
        //普通投资列表
        KSLoansEntity *loanList = (KSLoansEntity *)body;
        //列表数据
        NSArray<KSLoanItemEntity*> *array =  loanList.loanList;
        //下拉刷新
        if (isRefresh)
        {
            DEBUGG(@"%@ succeedAndFailCallbackWithDictionary111", self);
            //[self saveInfos:resultArr type:searchType clean:YES];
            DEBUGG(@"%@ succeedAndFailCallbackWithDictionary222", self);
            if (array && array.count > 0)
            {
                //数据缓存好后，index必须立即改变，后续的缓存获取操作都需要使用到
                // 从网络获取到最新数据,下次拉取数据的时候从第二页请求起
                self.pageIndex = 2;
                //DEBUGG(@"(1)%@ resultArr: %zd <<>> pageIndex: %d", self, array.count, self.pageIndex);
                //DEBUGG(@"(1)%@ resultArr: %@", self, array);
            }
            //创建刷新后的数据列表
            _dataList.isRefresh = YES;
            [_dataList appendDataList:array];
        }
        else
        {
            // 上拉加载更多
            if (tPageIndex == 1)
            {
                DEBUGG(@"");
                //加载更多的时候其实是第0页
                //[self saveInfos:resultArr type:searchType clean:YES];
                if (array && array.count > 0)
                {
                    self.pageIndex = tPageIndex+1;
                    //DEBUGG(@"(2)%@ resultArr:%d <<>> pageIndex: %d", self, (int)array.count, self.pageIndex);
                    //DEBUGG(@"(2)%@ resultArr:%@", self, array);
                    _dataList.isRefresh = YES;
                }
                else
                {
                    _dataList.isRefresh = NO;
                }
            }
            else
            {
                //加载更多正常的时候
                //数据缓存好后，index必须立即改变，后续的缓存获取操作都需要使用到
                if (array && array.count > 0)
                {
                    //[self saveInfos:resultArr type:searchType];
                    self.pageIndex = tPageIndex+1;
                    //DEBUGG(@"(3)%@ resultArr:%d <<>> pageIndex: %d", self, (int)array.count, self.pageIndex);
                    //DEBUGG(@"(3)%@ resultArr:%@", self, array);
                }
                _dataList.isRefresh = NO;
            }
            //创建刷新后的数据列表
            [_dataList appendDataList:array];
        }
        resp = [KSResponseEntity responseFromTradeId:tradeId sid:sid body:_dataList];
        resp.errorCode = responseEntity.errorCode;
        resp.errorDescription = responseEntity.errorDescription;
    }
    [super succeedItemBatchCallbackWithResponse:resp];
}

- (void)failedItemBatchCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //实体结果数据
    long long sid = responseEntity.sid;
    NSString *tradeId = responseEntity.tradeId;
    KSResponseEntity *resp = responseEntity;
    //列表
    if ([tradeId isEqualToString:KInvestListTradeId])
    {
        BOOL isRefresh = [self isRefreshFromSeqNo:sid];
        //下拉刷新
        if (isRefresh)
        {
            //创建刷新后的数据列表
            _dataList.isRefresh = YES;
        }
        else
        {
            // 上拉加载更多
            _dataList.isRefresh = NO;
        }
        resp = [KSResponseEntity responseFromTradeId:tradeId sid:sid body:_dataList];
        resp.errorCode = responseEntity.errorCode;
        resp.errorDescription = responseEntity.errorDescription;
    }
    [super failedItemBatchCallbackWithResponse:resp];
}

- (void)sysErrorItemBatchCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //实体结果数据
    long long sid = responseEntity.sid;
    NSString *tradeId = responseEntity.tradeId;
    KSResponseEntity *resp = responseEntity;
    //列表
    if ([tradeId isEqualToString:KInvestListTradeId])
    {
        BOOL isRefresh = [self isRefreshFromSeqNo:sid];
        //下拉刷新
        if (isRefresh)
        {
            //创建刷新后的数据列表
            _dataList.isRefresh = YES;
        }
        else
        {
            // 上拉加载更多
            _dataList.isRefresh = NO;
        }
        resp = [KSResponseEntity responseFromTradeId:tradeId sid:sid body:_dataList];
        resp.errorCode = responseEntity.errorCode;
        resp.errorDescription = responseEntity.errorDescription;
    }
    [super sysErrorItemBatchCallbackWithResponse:resp];
}
@end
