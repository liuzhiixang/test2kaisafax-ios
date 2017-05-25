//
//  KSInvestListBL.m
//  kaisafax
//
//  Created by semny on 16/6/30.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestListBL.h"
#import "KSConfig.h"
#import "KSUserMgr.h"
#import "KSBUserInvestListEntity.h"

//分页数据的一页数量
#define KInvestPageMaxCount        10

@interface KSInvestListBL ()

//页数(从0开始)
@property (nonatomic, assign) int pageIndex;

//返回数据
@property (nonatomic, strong) KSBUserInvestListEntity *dataList;
@end

@implementation KSInvestListBL

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _dataList = [[KSBUserInvestListEntity alloc] init];
    }
    return self;
}

#pragma mark - 业务请求
/**
 *  加载最新的投资列表数据
 */
- (void)refreshUserInvestList
{
    NSInteger pageCount = KInvestPageMaxCount;
    NSInteger pageIndex = 1;
    NSInteger status = self.status;
    long long seqNo = [self requestInvestListWithStatus:status pageIndex:pageIndex pageCount:pageCount];
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@YES,KRequestSearchType:@(status)}];
}

/**
 *  加载更多投资列表数据
 */
- (void)requestNextPageUserInvestList
{
    NSInteger pageCount = KInvestPageMaxCount;
    NSInteger pageIndex = self.pageIndex;
    NSInteger status = self.status;
    long long seqNo = [self requestInvestListWithStatus:status pageIndex:pageIndex pageCount:pageCount];
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@NO,KRequestSearchType:@(status)}];
}

#pragma mark -
#pragma mark ------------------获取网络数据-------------------
- (long)requestInvestListWithStatus:(NSInteger)status pageIndex:(NSInteger)pageIndex pageCount:(NSInteger)pageCount
{
    if (pageIndex < 0 || pageCount <= 0)
    {
        ERROR(@"请求数据参数不对!");
        pageIndex = 1;
        pageCount = KInvestPageMaxCount;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(status) forKey:kStatusKey];
    NSInteger pageStart = pageIndex;
    [params setObject:[NSNumber numberWithInteger:pageStart] forKey:kListPageStartKey];
    [params setObject:[NSNumber numberWithInteger:pageCount] forKey:kListPageCountKey];
    
    NSString *tradeId = KUserInvestListTradeId;
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
    if ([tradeId isEqualToString:KUserInvestListTradeId])
    {
        BOOL isRefresh = [self isRefreshFromSeqNo:sid];
        //NSString *searchType = [self getSearchTypeFromSeqno:sid];
        
        //用户投资记录列表
        KSUserInvestsEntity *userInvests = (KSUserInvestsEntity *)body;
        //列表数据
        NSArray<KSUIItemEntity*> *array =  userInvests.investList;
        //下拉刷新
        if (isRefresh)
        {
            DEBUGG(@"%@ succeedAndFailCallbackWithDictionary111", self);
            //[self saveInfos:resultArr type:searchType clean:YES];
            DEBUGG(@"%@ succeedAndFailCallbackWithDictionary222", self);
            if (array && array.count > 0)
            {
                //数据缓存好后，index必须立即改变，后续的缓存获取操作都需要使用到
                // 从网络获取到最新数据
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
            _dataList.isRefresh = NO;
            [_dataList appendDataList:array];
        }
        resp = [KSResponseEntity responseFromTradeId:tradeId sid:sid body:_dataList];
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
    [super sysErrorCallbackWithResponse:resp];
}

@end
