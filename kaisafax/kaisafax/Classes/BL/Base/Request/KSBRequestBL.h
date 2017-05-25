//
//  KSBRequestBL.h
//  kaisafax
//
//  Created by semny on 16/7/18.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

/// Batch业务请求的BL
@class KSBRequestBL;

/**
 *  业务类委托协议
 */
@protocol KSBatchBLDelegate <NSObject>

@optional

/**
 *  即将处理业务逻辑
 *
 *  @param blEntiy   业务对象
 */
- (void)willBatchHandle:(KSBRequestBL *)blEntity;

/**
 *  @author semny
 *
 *  整个batch处理结束的回调
 *
 *  @param blEntity batch request bl对象
 */
- (void)finishBatchHandle:(KSBRequestBL *)blEntity;

/**
 *  @author semny
 *
 *  整个batch处理结束的回调(其中某一个分支请求失败)
 *
 *  @param blEntity blEntity batch request bl对象
 */
- (void)failedBatchHandle:(KSBRequestBL *)blEntity;

/**
 *  业务处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result 业务处理之后的返回数据
 */
- (void)finishBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity *)result;

/**
 *  错误处理完成回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)failedBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity*)result;

/**
 *  业务处理完成非业务错误回调方法
 *
 *  @param blEntiy   业务对象
 *  @param result    包括错误信息的对象
 */
- (void)sysErrorBatchHandle:(KSBRequestBL *)blEntity itemResponse:(KSResponseEntity*)result;

@end

/**
 *  即将处理的机制
 *
 *  @param bl    业务处理类
 *  @param error 错误信息
 */
typedef void (^KSBBLWillHandleBatchBlock) (KSBRequestBL *bl);
typedef void (^KSBBLFinishHandleBatchBlock) (KSBRequestBL *bl);
typedef void (^KSBBLFailedHandleBatchBlock) (KSBRequestBL *bl);

/**
 *  委托处理成功回调
 *
 *  @param bl        业务对象
 *  @param result 经业务类处理之后的返回数据
 */
typedef void (^KSBBLFinishBlock) (KSBRequestBL *bl, KSResponseEntity *response);

/**
 *  委托处理失败回调
 *
 *  @param bl        业务对象
 *  @param error     错误对象
 */
typedef void (^KSBBLFailedBlock) (KSBRequestBL *bl, KSResponseEntity *response);

/**
 *  委托处理失败回调
 *
 *  @param bl        业务对象
 *  @param error     错误对象
 */
typedef void (^KSBBLSysErrorBlock) (KSBRequestBL *bl, KSResponseEntity *response);

@interface KSBRequestBL : KSRequestBL

//结果代理
@property (nonatomic, weak) id<KSBatchBLDelegate> batchDelegate;

//结果回调block
@property (nonatomic, copy) KSBLFinishBlock finishBBlock;
//失败回调block
@property (nonatomic, copy) KSBBLFailedBlock failedBBlock;
//系统错误回调block
@property (nonatomic, copy) KSBBLSysErrorBlock sysErrorBBlock;
//请求即将处理的block
@property (nonatomic, copy) KSBBLWillHandleBatchBlock willHandleBBlock;
@property (nonatomic, copy) KSBBLFinishHandleBatchBlock finishHandleBBlock;
@property (nonatomic, copy) KSBBLFailedHandleBatchBlock failedHandleBBlock;

/**
 *  @author semny
 *
 *  请求网络数据(请求完成或即将开始的时候使用delegate)
 *
 *  @param tradeId      网络请求的接口业务id
 *  @param requestArray 子分支请求的数组
 *
 *  @return 请求序列号
 */
- (long long)requestWithTradeId:(NSString *)tradeId array:(NSArray *)requestArray;

#pragma mark -
#pragma mark -----------通知结果处理(网络请求回调使用)--------------
/**
 *  分支请求的回调
 */
//成功代理回调 (默认为父类实现，子类可扩展)
- (void)succeedItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity;

//失败代理回调 (默认为父类实现，子类可扩展)
- (void)failedItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity;

//系统级的错误
- (void)sysErrorItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity;

/**
 *  整个batch的回调
 */
//成功代理回调 (默认为父类实现，子类可扩展)
- (void)succeedBatchCallbackWithResponse:(KSResponseEntity*)responseEntity;

//失败代理回调 (默认为父类实现，子类可扩展)
- (void)failedBatchCallbackWithResponse:(KSResponseEntity*)responseEntity;

#pragma mark - 老的回调方法
- (void)succeedCallbackWithResponse:(KSResponseEntity *)responseEntity __deprecated_msg("Method deprecated. Batch请求BL中使用succeedItemBatchCallbackWithResponse");
- (void)failedCallbackWithResponse:(KSResponseEntity *)responseEntity __deprecated_msg("Method deprecated. Batch请求BL中使用failedItemBatchCallbackWithResponse");
- (void)sysErrorCallbackWithResponse:(KSResponseEntity *)responseEntity __deprecated_msg("Method deprecated. Batch请求BL中使用sysErrorItemBatchCallbackWithResponse");
@end
