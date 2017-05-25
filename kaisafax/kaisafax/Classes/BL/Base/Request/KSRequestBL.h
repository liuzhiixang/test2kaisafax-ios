//
//  KSRequestBL
//  kaisafax
//
//  Created by semny on 15/10/10.
//  Copyright © 2015年 kaisafax. All rights reserved.
//

#import "KSBaseBL.h"
#import "KSSequenceNo.h"
#import "KSBRequest.h"
#import "KSResponseEntity.h"
#import "KSAPIDataMgr.h"
#import "KSBaseEntity.h"

#pragma mark -公共的请求参数名称
//是否是刷新请求的标志
//#define KRequestRefreshKey    @"RequestRefreshKey"
//#define KRequestBLKeyCode       @"code"


//下拉刷新标志
#define KRequestISRefreshKey                   @"isRefresh"
#define KPageIndexKey                   @"pageIndex"
#define KRequestSearchType                   @"searchType"


@interface KSRequestBL : KSBaseBL<SQRequestDelegate>

/**
 *  请求网络数据(请求完成或即将开始的时候使用delegate)
 *
 *  @param tradeId 网络请求的接口业务id
 *  @param data    需要提交的请求数据
 *
 *  @return 请求编号
 */
- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data;
- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data updateSession:(BOOL)updateSession;

/**
 *  @author semny
 *
 *  请求网络数据(请求完成或即将开始的时候使用delegate)
 *
 *  @param tradeId 网络请求的接口业务id
 *  @param data    需要提交的请求数据
 *  @param delegate 网络delegate
 *
 *  @return 序列号
 */
- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data delegate:(id<SQRequestDelegate>)delegate;
- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data updateSession:(BOOL)updateSession delegate:(id<SQRequestDelegate>)delegate;

/**
 *  请求网络数据
 *
 *  @param tradeId 网络请求的接口业务id
 *  @param data    需要提交的请求数据(如果为GET方法，不需要传此参数)
 *  @param url     请求网络地址
 *  @param method  请求方法(GET,POST,等等，默认为GET)
 *
 *  @return 请求编号
 */
- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method;
- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method updateSession:(BOOL)updateSession;

/**
 *  判断当前网络请求resp是下拉刷新 还是上拉加载更多
 *
 *  @param seqno 请求序列号
 *
 *  @return 是否是下拉刷新
 */
- (BOOL)isRefreshFromSeqNo:(long long)seqNo;

/**
 *  请求的类型
 *
 *  @param seqno 请求序列号
 *
 *  @return 请求的类型
 */
- (NSString *)getSearchTypeFromSeqNo:(long long)seqNo;

//获取当前请求返回的页数
- (NSInteger)getPageIndexFromSeqNo:(long long)seqNo;

/**
 *  @author semny
 *
 *  根据提供的参数创建默认的请求对象
 *
 *  @param tradeId      请求接口业务编号
 *  @param seqNo        序列号
 *  @param data         请求业务数据(body)
 *  @param url          请求URL(字符串)
 *  @param method       请求方法(HTTP）
 *  @param cachePolicy  请求缓存模式
 *  @param error        错误
 *
 *  @return 请求对象
 */
- (KSBRequest *)createRequest:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 URL:(NSString *)url httpMethod:(SQRequestMethod)method cachePolicy:(NSURLRequestCachePolicy)cachePolicy error:(NSError **)error;

//默认忽略缓存
- (KSBRequest *)createRequest:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 URL:(NSString *)url httpMethod:(SQRequestMethod)method error:(NSError **)error;

//创建post相关请求参数
+ (NSDictionary *)createPostArgumentWithTradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error;

//创建请求带参数组合url字符串(不带?)
+ (NSString *)createGetRequestURLWithTradeId:(NSString *)tradeId data:(NSDictionary *)data1 error:(NSError **)error;
//创建请求参数组合字符串(不带?)
//+ (NSString *)createGetArgumentWithTradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error;

+ (NSString *)createGetRequestURLWithURL:(NSString*)url tradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error;

#pragma mark - 数据解析相关
/**
 *  @author semny
 *
 *  解析请求返回结果
 *
 *  @param dict 返回的数据字典
 *  @param tradeId tradeId
 *
 *  @return 数据model/dict
 */
- (id)parserResponse:(NSDictionary *)dict withTradeId:(NSString *)tradeId;

#pragma mark -
#pragma mark -----------通知结果处理(网络请求回调使用)--------------
//成功代理回调 (默认为父类实现，子类可扩展)
- (void)succeedCallbackWithResponse:(KSResponseEntity*)responseEntity;

//失败代理回调 (默认为父类实现，子类可扩展)
- (void)failedCallbackWithResponse:(KSResponseEntity*)responseEntity;

//系统级的错误
- (void)sysErrorCallbackWithResponse:(KSResponseEntity*)responseEntity;
@end
