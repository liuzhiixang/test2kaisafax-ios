//
//  KSResponseEntity.h
//  kaisafax
//
//  Created by semny on 15/7/7.
//  Copyright (c) 2015年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSNWConfig.h"

@interface KSResponseEntity : NSObject

#pragma mark - Header
//业务命令字
@property (nonatomic, copy) NSString  *tradeId;
//网络请求序列号
@property (nonatomic, assign) long long sid;

//参照KSNWResponseCode//错误码（success）
@property (nonatomic, assign) NSInteger errorCode;
//错误描述信息（message）
@property (nonatomic, copy) NSString *errorDescription;

//整个流程的标志
@property (nonatomic, copy) NSString  *processTradeId;
@property (nonatomic, assign) NSInteger  processSeqNo;

#pragma mark - Body
@property (nonatomic, strong) id body;

/**
 *  结果实体构造函数
 *
 *  @param rid  请求的接口id
 *  @param sid  请求的序列号
 *  @param body 包体数据
 *
 *  @return 结果实体
 */
+ (KSResponseEntity*)responseFromTradeId:(NSString *)rid sid:(long long)sid body:(id)body;

@end
