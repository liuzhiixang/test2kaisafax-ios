//
//  KSBaseBL.h
//  kaisafax
//
//  Created by semny on 15/10/10.
//  Copyright © 2015年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSBLDelegate.h"
#import "KSResponseEntity.h"

@class KSBaseBL;

/**
 *  即将处理的机制
 *
 *  @param bl    业务处理类
 *  @param error 错误信息
 */
typedef void (^KSBLWillHandleBlock) (KSBaseBL *bl);

/**
 *  委托处理成功回调
 *
 *  @param bl        业务对象
 *  @param result 经业务类处理之后的返回数据
 */
typedef void (^KSBLFinishBlock) (KSBaseBL *bl, KSResponseEntity *response);

/**
 *  委托处理失败回调
 *
 *  @param bl        业务对象
 *  @param error     错误对象
 */
typedef void (^KSBLFailedBlock) (KSBaseBL *bl, KSResponseEntity *response);

/**
 *  委托处理失败回调
 *
 *  @param bl        业务对象
 *  @param error     错误对象
 */
typedef void (^KSBLSysErrorBlock) (KSBaseBL *bl, KSResponseEntity *response);

/**
 *  业务处理父类，所有的业务处理类都应从此类继承
 *  假如不支持ARC的话，尽量使用委托回调方式；
 *  在不支持ARC的环境中使用block回调的时候，需要注意self循环引用问题，并保证调用对象中持有KSBaseBL业务对象，以避免崩溃情况的出现
 *
 *  如果在一个VC里面存在多个不同的业务逻辑处理，一般需要在VC里面保留全局的业务逻辑处理对象，方便判断业务逻辑处理类型
 */
@interface KSBaseBL : NSObject

//错误信息
@property (nonatomic, retain) NSError *error;

//结果代理
@property (nonatomic, weak) id<KSBLDelegate> delegate;

//结果回调block
@property (nonatomic, copy) KSBLFinishBlock finishBlock;
//失败回调block
@property (nonatomic, copy) KSBLFailedBlock failedBlock;
//系统错误回调block
@property (nonatomic, copy) KSBLSysErrorBlock sysErrorBlock;
//请求即将处理的block
@property (nonatomic, copy) KSBLWillHandleBlock willHandleBlock;

/**
 *  @author semny
 *
 *  清理当前的请求记录队列
 *
 *  @param seqno 请求序列号
 */
- (void)clearRecordStackBySeqno:(long long)seqNo;

/**
 *  @author semny
 *
 *  更新当前的请求记录队列
 *
 *  @param seqno 请求序列号
 *  @param data  请求记录数据
 */
- (void)updateRecordStackBySeqno:(long long)seqNo data:(id)data;

/**
 *  @author semny
 *
 *  获取请求记录队列中的数据
 *
 *  @param seqno 请求序列号
 *
 *  @return 请求记录队列中的数据
 */
- (id)objectInRecordStackForSeqno:(long long)seqNo;

@end
