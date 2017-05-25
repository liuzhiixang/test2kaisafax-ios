//
//  KSJDExtractListBL.m
//  kaisafax
//
//  Created by semny on 17/3/23.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDExtractListBL.h"
#import "KSBJDExtractListEntity.h"
#import "KSJDExtractListEntity.h"

//分页数据的一页数量
#define KPageMaxCount        10

@interface KSJDExtractListBL ()

//页数(从0开始)
@property (nonatomic, assign) long pageIndex;

//返回数据
@property (nonatomic, strong) KSBJDExtractListEntity *dataList;

@end

@implementation KSJDExtractListBL

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _dataList = [[KSBJDExtractListEntity alloc] init];
    }
    return self;
}

/**
 * 加载最新的京东制卡纪录列表数据
 */
- (void)refreshJDExtractList
{
    NSInteger pageCount = KPageMaxCount;
    NSInteger pageIndex = 1;
    long long seqNo = [self requestInviteListWithPageIndex:pageIndex pageCount:pageCount];
    
    //DEBUGG(@"%@ %s: %ld <<>> %ld", self, __FUNCTION__, (long)pageIndex, (long)seqNo);
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@YES, KPageIndexKey:@(pageIndex)}];
}

/**
 *  加载更多京东制卡纪录列表数据
 */
- (void)requestNextPageJDExtractList
{
    NSInteger pageCount = KPageMaxCount;
    NSInteger pageIndex = self.pageIndex;
    long long seqNo = [self requestInviteListWithPageIndex:pageIndex pageCount:pageCount];
    //DEBUGG(@"%@ %s: %ld <<>> %ld", self, __FUNCTION__, (long)pageIndex, (long)seqNo);
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@NO, KPageIndexKey:@(pageIndex)}];
}

#pragma mark -
#pragma mark ------------------获取网络数据-------------------
- (long)requestInviteListWithPageIndex:(NSInteger)pageIndex pageCount:(NSInteger)pageCount
{
    if (pageIndex < 0 || pageCount <= 0)
    {
        ERROR(@"请求数据参数不对!");
        pageIndex = 1;
        pageCount = KPageMaxCount;
    }
    
    //DEBUGG(@"%@ requestInviteListWithPageIndex: %ld", self, (long)pageIndex);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSInteger pageStart = pageIndex;
    [params setObject:[NSNumber numberWithInteger:pageStart] forKey:kListPageStartKey];
    [params setObject:[NSNumber numberWithInteger:pageCount] forKey:kListPageCountKey];
    
    NSString *tradeId = KGetJDExtractListTradeId;
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
    if ([tradeId isEqualToString:KGetJDExtractListTradeId])
    {
        BOOL isRefresh = [self isRefreshFromSeqNo:sid];
        NSInteger tPageIndex = [self getPageIndexFromSeqNo:sid];
        
        //京东卡制卡纪录
        KSJDExtractListEntity *pageData = (KSJDExtractListEntity*)body;
        //纪录列表
        NSMutableArray<KSJDExtractItemEntity*> *array = pageData.list;
        _dataList.jdAccount = pageData.jdAccount;
        //下拉刷新
        if (isRefresh)
        {
            //DEBUGG(@"%@ succeedAndFailCallbackWithDictionary111", self);
            //[self saveInfos:resultArr type:searchType clean:YES];
            //DEBUGG(@"%@ succeedAndFailCallbackWithDictionary222", self);
            if (array && array.count > 0)
            {
                //数据缓存好后，index必须立即改变，后续的缓存获取操作都需要使用到
                // 从网络获取到最新数据
                self.pageIndex = 2;
                //DEBUGG(@"(1)%@ resultArr: %zd <<>> pageIndex: %ld", self, array.count, self.pageIndex);
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
                //DEBUGG(@"");
                //加载更多的时候其实是第0页
                //[self saveInfos:resultArr type:searchType clean:YES];
                if (array && array.count > 0)
                {
                    self.pageIndex = tPageIndex+1;
                    //DEBUGG(@"(2)%@ resultArr:%d <<>> pageIndex: %ld", self, (int)array.count, self.pageIndex);
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
                    //DEBUGG(@"(3)%@ resultArr:%d <<>> pageIndex: %ld", self, (int)array.count, self.pageIndex);
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
    [super succeedCallbackWithResponse:resp];
}

- (void)failedCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //实体结果数据
    long long sid = responseEntity.sid;
    NSString *tradeId = responseEntity.tradeId;
    KSResponseEntity *resp = responseEntity;
    //列表
    if ([tradeId isEqualToString:KGetJDExtractListTradeId])
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
    if ([tradeId isEqualToString:KGetJDExtractListTradeId])
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
