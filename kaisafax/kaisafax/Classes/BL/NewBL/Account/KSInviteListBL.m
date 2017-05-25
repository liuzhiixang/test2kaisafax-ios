//
//  KSInviteListBL.m
//  kaisafax
//
//  Created by semny on 16/8/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInviteListBL.h"
#import "KSInviteUserEntity.h"
#import "KSBInviteUserListEntity.h"

//分页数据的一页数量
#define KInviteListPageMaxCount        10

@interface KSInviteListBL ()

//页数(从1开始)
@property (nonatomic, assign) long pageIndex;

//返回数据
@property (nonatomic, strong) KSBInviteUserListEntity *dataList;
@end

@implementation KSInviteListBL

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _dataList = [[KSBInviteUserListEntity alloc] init];
    }
    return self;
}

/**
 *  加载最新的推荐人列表数据
 */
- (void)refreshInviteList
{
    NSInteger pageCount = KInviteListPageMaxCount;
    NSInteger pageIndex = 1;
	self.pageIndex = 1;
    long long seqNo = [self requestInviteListWithPageIndex:pageIndex pageCount:pageCount];
    
    DEBUGG(@"%@ %s: %ld <<>> %ld", self, __FUNCTION__, (long)pageIndex, (long)seqNo);
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@YES, KPageIndexKey:@(pageIndex)}];
}

/**
 *  加载更多推荐人列表数据
 */
- (void)requestNextPageInviteList
{
    NSInteger pageCount = KInviteListPageMaxCount;
    NSInteger pageIndex = self.pageIndex;
    long long seqNo = [self requestInviteListWithPageIndex:pageIndex pageCount:pageCount];
    DEBUGG(@"%@ %s: %ld <<>> %ld", self, __FUNCTION__, (long)pageIndex, (long)seqNo);
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@NO, KPageIndexKey:@(pageIndex)}];
}

#pragma mark -
#pragma mark ------------------获取网络数据-------------------
- (long long)requestInviteListWithPageIndex:(NSInteger)pageIndex pageCount:(NSInteger)pageCount
{
    if (pageIndex < 0 || pageCount <= 0)
    {
        ERROR(@"请求数据参数不对!");
        pageIndex = 1;
        pageCount = KInviteListPageMaxCount;
    }
    
    DEBUGG(@"%@ requestInviteListWithPageIndex: %ld", self, (long)pageIndex);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSInteger pageStart = pageIndex;
    [params setObject:[NSNumber numberWithInteger:pageStart] forKey:kListPageStartKey];
    [params setObject:[NSNumber numberWithInteger:pageCount] forKey:kListPageCountKey];
    
    NSString *tradeId = KCommissionInviteListTradeId;
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
    if ([tradeId isEqualToString:KCommissionInviteListTradeId])
    {
        BOOL isRefresh = [self isRefreshFromSeqNo:sid];
        //推荐人列表
        NSArray<KSInviteUserEntity*> *array = (NSArray<KSInviteUserEntity*> *)[body objectForKey:@"inviteList"];
    
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
                DEBUGG(@"(1)%@ resultArr: %zd <<>> pageIndex: %ld", self, array.count, self.pageIndex);
                DEBUGG(@"(1)%@ resultArr: %@", self, array);
            }
            //创建刷新后的数据列表
            _dataList.isRefresh = YES;
            [_dataList appendDataList:array];
        }
        else
        {
            // 上拉加载更多
            if (array.count == 0)
            {
                DEBUGG(@"");
                ++self.pageIndex;
                
            }
            else
            {
                //加载更多正常的时候
                //数据缓存好后，index必须立即改变，后续的缓存获取操作都需要使用到
                if (array && array.count > 0)
                {
                    //[self saveInfos:resultArr type:searchType];
                    ++self.pageIndex;
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
    if ([tradeId isEqualToString:KCommissionInviteListTradeId])
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
    if ([tradeId isEqualToString:KCommissionInviteListTradeId])
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
