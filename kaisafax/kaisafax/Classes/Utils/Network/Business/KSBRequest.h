//
//  KSBRequest.h
//  kaisafax
//
//  Created by semny on 16/7/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQBaseRequest.h"
#import "KSNWConfig.h"

@interface KSBRequest : SQBaseRequest

//接口名称
@property (nonatomic, copy, readonly) NSString *tradeId;
//SID
@property (nonatomic, assign, readonly) long long sequenceID;
//header
@property (nonatomic, strong, readonly) NSDictionary *header;
//body
@property (nonatomic, strong, readonly) NSDictionary *body;
//是否需要更新session的标志
@property (nonatomic, assign, readonly) BOOL updateSession;

/**
 *  根据请求序列号初始化请求对象
 *
 *  @param seqNo 请求序列号
 *  @param tradeId 接口编号，表示请求的业务类型
 *
 *  @return 请求对象
 */
- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId;
- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId updateSession:(BOOL)updateSession;

- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId header:(NSDictionary*)header body:(NSDictionary*)body;
- (instancetype)initWithSequenceID:(long long)seqNo tradeId:(NSString *)tradeId header:(NSDictionary*)header body:(NSDictionary*)body  updateSession:(BOOL)updateSession;
@end
