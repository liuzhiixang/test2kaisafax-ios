//
//  KSHomeBL.m
//  kaisafax
//
//  Created by semny on 16/7/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSHomeBL.h"
#import "KSBatchRequest.h"
#import "KSVersionMgr.h"
#import "KSUserMgr.h"

@interface KSHomeBL()<SQBatchRequestDelegate>

//多个组合请求
@property (strong, nonatomic) KSBatchRequest *batchRequest;

@end

//分页数据的一页数量
#define KPageMaxCount        10

@implementation KSHomeBL


#pragma mark - 业务请求
/**
 *  加载主页信息
 */
- (void)doGetHomeInfo
{
    //请求轮播图，公告信息，运营图
    SQBaseRequest *request1 = [self createHomeBannerAboutRequest];
    //新手标
    SQBaseRequest *request2 = [self createNewBeeRequest];
    //推荐标和物业宝标
    SQBaseRequest *request3 = [self createOwnerAndRecommendLoansRequest];
    //组合请求
    NSInteger homeSeqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSArray *requestArray = @[request1, request2, request3];
    NSString *tradeId = KHomeBatchRequestTradeId;
    _batchRequest = [[KSBatchRequest alloc] initWithSequenceID:homeSeqNo tradeId:tradeId requestArray:requestArray];
    _batchRequest.delegate = self;
    //开启请求
    [_batchRequest start];
}

/**
 *  @author semny
 *
 *  创建轮播图，公告信息，运营图 请求对象
 *
 *  @return 请求对象
 */
- (KSBRequest *)createHomeBannerAboutRequest
{
    NSString *tradeId1 = KGetHomeTogetherTradeId;
    NSInteger seqNo1 = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    KSBRequest *request1 = [self createRequest:tradeId1 seqNo:seqNo1 data:nil URL:SX_APP_API httpMethod:SQRequestMethodPost error:&error];
    return request1;
}

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
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KInvestNewBeeTradeId;
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    KSBRequest *request = [self createRequest:tradeId seqNo:seqNo data:nil URL:SX_APP_API httpMethod:SQRequestMethodPost error:&error];
    return request;
}

/**
 *  @author semny
 *
 *  创建 推荐标和物业宝标 请求对象
 *
 *  @return 请求对象
 */
- (KSBRequest *)createOwnerAndRecommendLoansRequest
{
    NSString *tradeId = KGetOwnerAndRecommendLoansTradeId;
    NSInteger seqNo3 = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSError *error = nil;
    KSBRequest *request3 = [self createRequest:tradeId seqNo:seqNo3 data:nil URL:SX_APP_API httpMethod:SQRequestMethodPost error:&error];
    return request3;
}

/**
 *  @author semny
 *
 *  请求轮播图，公告信息，运营图
 *
 *  @return 请求序列号
 */
- (NSInteger)doGetHomeBannerAbout
{
    NSString *channelID = kChannelVID;
    NSInteger platformType = kPlatformTypeValue;
    NSString *localVer = [[KSVersionMgr sharedInstance] getVersionName];
    NSString *switchAppRequestNameKey = kSwitchAppRequest1;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:localVer forKey:kAppVersionKey];
    [params setObject:@(platformType) forKey:kPlatformTypeKey];
    [params setObject:channelID forKey:kAppChannelKey];
    [params setObject:switchAppRequestNameKey forKey:kSwitchAppRequestNameKey];
    
    NSString *tradeId = KGetHomeTogetherTradeId;
    long long seqNo = [self requestWithTradeId:tradeId data:params];

    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:[NSNumber numberWithLong:seqNo]];
    return seqNo;
}

/**
 *  @author semny
 *
 *  获取新手标
 *
 *  @return 请求序列号
 */
- (NSInteger)doGetNewBee
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    //TODO: 所有获取用户信息的地方都需要重新使用用户登录管理类
//    NSString *imeiStr = USER_SESSIONID;
//    if(imeiStr && imeiStr.length > 0)
//    {
//        [params setObject:imeiStr forKey:KUserIMEIKey];
//    }
    NSString *tradeId = KInvestNewBeeTradeId;
    long long seqNo = [self requestWithTradeId:tradeId data:params];

    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:[NSNumber numberWithLong:seqNo]];
    return seqNo;
}

/**
 *  @author semny
 *
 *  推荐标和物业宝标的信息
 *
 *  @return 请求序列号
 */
- (NSInteger)doGetPTAndRecoInfo
{
    NSInteger pageIndex = 0;
    NSInteger pageCount = KPageMaxCount;
    long long seqNo = [self requestPTAndRecoInfoWithPageIndex:pageIndex pageCount:pageCount];

    //更新请求记录队列
    [self updateRecordStackBySeqno:seqNo data:[NSNumber numberWithLong:seqNo]];
    return seqNo;
}

- (NSInteger)requestPTAndRecoInfoWithPageIndex:(NSInteger)pageIndex pageCount:(NSInteger)pageCount
{
    if (pageIndex < 0 || pageCount <= 0)
    {
        ERROR(@"请求数据参数不对!");
        pageIndex = 0;
        pageCount = KPageMaxCount;
    }
    
    NSString *channelID = kChannelVID;
    NSInteger platformType = kPlatformTypeValue;
    NSString *localVer = [[KSVersionMgr sharedInstance] getVersionName];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:localVer forKey:kAppVersionKey];
    [params setObject:@(platformType) forKey:kPlatformTypeKey];
    [params setObject:channelID forKey:kAppChannelKey];
    NSInteger pageStart = pageIndex*pageCount;
    [params setObject:[NSNumber numberWithInteger:pageStart] forKey:kListPageStartKey];
    [params setObject:[NSNumber numberWithInteger:pageCount] forKey:kListPageCountKey];
    
    NSString *tradeId = KGetOwnerAndRecommendLoansTradeId;
    long long seqNo = [self requestWithTradeId:tradeId data:params];
    return seqNo;
}

#pragma mark -
#pragma mark -----------通知结果处理(网络请求回调使用)--------------
/**
 *  分支请求的回调
 */
//成功代理回调 (默认为父类实现，子类可扩展)
//- (void)succeedItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
//{
//    
//}
//
////失败代理回调 (默认为父类实现，子类可扩展)
//- (void)failedItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
//{
//    
//}
//
////系统级的错误
//- (void)sysErrorItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
//{
//    
//}
//
///**
// *  整个batch的回调
// */
////成功代理回调 (默认为父类实现，子类可扩展)
//- (void)succeedBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
//{
//    
//}
//
////失败代理回调 (默认为父类实现，子类可扩展)
//- (void)failedBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
//{
//    
//}



- (void)dealloc
{
    //清理数据
    _batchRequest = nil;
    [_batchRequest stop];
}
@end
