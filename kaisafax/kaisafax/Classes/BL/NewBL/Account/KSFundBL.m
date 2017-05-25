//
//  KSFundBL.m
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSFundBL.h"
#import "KSUserMgr.h"
#import "KSUserFREntity.h"
#import "KSBUFRListEntity.h"
#import "KSUserFRGroupEntity.h"
#import "KSAccountFundRecordModel.h"
#import "NSDate+Utilities.h"

//分页数据的一页数量
#define KUserInvestRecordPageMaxCount        20

@interface KSFundBL ()

//页数(从0开始)
@property (nonatomic, assign) long pageIndex;
//返回数据
@property (nonatomic, strong) KSBUFRListEntity *dataList;
//交易记录的原始数据
//@property (nonatomic, strong) NSMutableArray *dataArray;

@end


@implementation KSFundBL

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //返回报文
        _dataList = [[KSBUFRListEntity alloc] init];
        //原始数据
//        _dataArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 交易记录
/**
 *  加载最新的交易记录列表数据
 */
- (void)refreshUserFundRecords
{
    NSInteger pageCount = KUserInvestRecordPageMaxCount;
    NSInteger pageIndex = 1;
//    //TODO: 所有获取用户信息的地方都需要重新使用用户登录管理类
//    NSString *imei = USER_SESSIONID;
    long long fromTime = self.fromTime;
    long long toTime = self.toTime;
    NSString *filterType = self.filterType;
    long long seqNo = [self requestUserFundRecordsWithFrom:fromTime to:toTime filterType:filterType pageIndex:pageIndex pageCount:pageCount];
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@YES, KRequestSearchType:filterType, KPageIndexKey:@(pageIndex)}];
}

/**
 *  加载更多交易记录列表数据
 */
- (void)requestNextPageUserFundRecords
{
    NSInteger pageCount = KUserInvestRecordPageMaxCount;
    NSInteger pageIndex = self.pageIndex;
//    //TODO: 所有获取用户信息的地方都需要重新使用用户登录管理类
//    NSString *imei = USER_SESSIONID;
    long long fromTime = self.fromTime;
    long long toTime = self.toTime;
    NSString *filterType = self.filterType;
    long long seqNo = [self requestUserFundRecordsWithFrom:fromTime to:toTime filterType:filterType pageIndex:pageIndex pageCount:pageCount];
    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:@{KRequestISRefreshKey:@NO, KRequestSearchType:filterType, KPageIndexKey:@(pageIndex)}];
}

#pragma mark -
#pragma mark ------------------获取网络数据-------------------
- (long)requestUserFundRecordsWithFrom:(long long)fromTime to:(long long)toTime filterType:(NSString *)filterType pageIndex:(NSInteger)pageIndex pageCount:(NSInteger)pageCount
{
    if (pageIndex <= 1 || pageCount <= 0)
    {
        ERROR(@"请求数据参数不对!");
        pageIndex = 1;
        pageCount = KUserInvestRecordPageMaxCount;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (filterType)
    {
        [params setObject:filterType forKey:kFilterTypeKey];
    }
    
    NSInteger pageStart = pageIndex;
    [params setObject:[NSNumber numberWithInteger:pageStart] forKey:kListPageStartKey];
    [params setObject:[NSNumber numberWithInteger:pageCount] forKey:kListPageCountKey];
    if(fromTime > 0 || toTime > 0)
    {
        [params setObject:[NSNumber numberWithLongLong:fromTime] forKey:kFromKey];
        [params setObject:[NSNumber numberWithLongLong:toTime] forKey:kToKey];
    }
    
    NSString *tradeId = KUserFundRecordTradeId;
    return [self requestWithTradeId:tradeId data:params];
}

#pragma mark - 归并排序算法
- (NSMutableArray *)sortFundRecord:(NSArray<KSUserFRItemEntity*> *)objects with:(NSArray *)dataList
{
    NSMutableArray *ds = nil;
    
    if (!dataList)
    {
        ds = [NSMutableArray array];
    }
    else if([dataList isKindOfClass:[NSMutableArray class]])
    {
        ds = (NSMutableArray*)dataList;
    }
    else
    {
        ds = [NSMutableArray arrayWithArray:dataList];
    }
    
    NSInteger count = 0;
    if (objects && (count=objects.count) > 0)
    {
        //排序规则
        DEBUGG(@"%s, begin sort count: %d", __FUNCTION__, (int)count);
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"recordTime" ascending:NO];
        [objects sortedArrayUsingDescriptors:@[sort]];
        DEBUGG(@"%s, end sort", __FUNCTION__);
        //组织数据(获取上次存储排序好的最后一个组数据)
        KSUserFRGroupEntity *lastGroup = ds.lastObject;
        NSMutableArray *tempDataList = lastGroup.dataList;
        
        //普通枚举 for (ARVAsset *asset in objects)
        //加速枚举
        NSEnumerator *enumerator = [objects objectEnumerator];
        KSUserFRItemEntity *curItem = nil;
        while ((curItem = [enumerator nextObject]) != nil)
        {
            //日期数据
            NSDate *recordTime = curItem.recordTime;
            DEBUGG(@"sortMomentWithDate() asset recordTime: %@", recordTime);
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:recordTime];
            NSUInteger month = [components month];
            NSUInteger year  = [components year];
            NSUInteger day   = [components day];
            
            //按照年份归并
            if (!lastGroup || lastGroup.sectionYear!=year)
            {
                lastGroup = [[KSUserFRGroupEntity alloc] init];
                lastGroup.sectionMonth = month;
                lastGroup.sectionYear = year;
                lastGroup.sectionDay = day;
                lastGroup.sectionDate = recordTime;
                NSString *sectionDateTitle = [NSString stringWithFormat:@"%lu",(unsigned long)year];
                lastGroup.sectionDateTitle = sectionDateTitle;
                [ds addObject:lastGroup];
                
                //数据列表
                tempDataList = [[NSMutableArray alloc] init];
                lastGroup.dataList = tempDataList;
            }
            
            //查找到的数据
            KSAccountFundRecordModel *lastModel = [lastGroup.dataList lastObject];
            DEBUGG(@"%s, lastModel: %@ ", __FUNCTION__ ,lastModel);
            {
                KSAccountFundRecordModel *model = [[KSAccountFundRecordModel alloc]init];
                model.data = curItem;
  
                //按照日期归并
                if(tempDataList.count==0)
                {
                    //判断是不是第一个
                    model.isShowDate = YES;
                }
                else
                {
                    KSUserFRItemEntity *proItem = lastModel.data;
                    if ((curItem.recordTime.month == proItem.recordTime.month) &&
                        (curItem.recordTime.year == proItem.recordTime.year) &&
                        (curItem.recordTime.day == proItem.recordTime.day))
                    {
                        model.isShowDate = NO;
                    }
                    else
                    {
                        model.isShowDate = YES;
                    }
                }
                
                //过滤掉已经存储了的数据
                if ([model.data.recordTime isLaterThanDate:lastModel.data.recordTime]
                    /*||[model.data isEqual:lastModel.data]*/) {
                    break;
                }
                
                [tempDataList addObject:model];
            }
        }
    }
    return ds;
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
    if ([tradeId isEqualToString:KUserFundRecordTradeId])
    {
        BOOL isRefresh = [self isRefreshFromSeqNo:sid];
        NSInteger tPageIndex = [self getPageIndexFromSeqNo:sid];
        
        //用户投资记录列表
        KSUserFREntity *frData = (KSUserFREntity *)body;
        //列表数据
        NSArray<KSUserFRItemEntity*> *array =  frData.fundList;
        
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
                self.pageIndex = 1;
                //DEBUGG(@"(1)%@ resultArr: %zd <<>> pageIndex: %d", self, array.count, self.pageIndex);
                //DEBUGG(@"(1)%@ resultArr: %@", self, array);
            }
            //创建刷新后的数据列表
            _dataList.isRefresh = YES;
            
            //归并排序
            _dataList.dataList = nil;
            NSMutableArray *tempArray = [self sortFundRecord:array with:_dataList.dataList];
            _dataList.dataList = tempArray;
        }
        else
        {
            // 上拉加载更多
            if (tPageIndex == 0)
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
            //归并排序
            NSMutableArray *tempArray = [self sortFundRecord:array with:_dataList.dataList];
            _dataList.dataList = tempArray;
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
    if ([tradeId isEqualToString:KUserFundRecordTradeId])
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
    if ([tradeId isEqualToString:KUserFundRecordTradeId])
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
