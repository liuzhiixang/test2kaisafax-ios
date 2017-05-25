//
//  KSBaseBL.m
//  kaisafax
//
//  Created by semny on 15/10/10.
//  Copyright © 2015年 kaisafax. All rights reserved.
//

#import "KSBaseBL.h"

@interface KSBaseBL()

//请求的序列号
@property (nonatomic, strong) NSMutableDictionary *seqNumDict;

@end

@implementation KSBaseBL

- (id)init
{
    if (self = [super init])
    {
        self.seqNumDict = [NSMutableDictionary dictionary];
    }
    return self;
}

/**
 *  @author semny
 *
 *  清理当前的请求记录队列
 *
 *  @param seqno 请求序列号
 */
- (void)clearRecordStackBySeqno:(long long)seqNo
{
    NSNumber *seqNum = [NSNumber numberWithLongLong:seqNo];
    [self.seqNumDict removeObjectForKey:seqNum];
}

/**
 *  @author semny
 *
 *  更新当前的请求记录队列
 *
 *  @param seqno 请求序列号
 *  @param data  请求记录数据
 */
- (void)updateRecordStackBySeqno:(long long)seqNo data:(id)data
{
    if (!data)
    {
        return;
    }
    [self clearRecordStackBySeqno:seqNo];
    [self addRecordStackBySeqno:seqNo data:data];
}

- (void)addRecordStackBySeqno:(long long)seqNo data:(id)data
{
    if (!data)
    {
        return;
    }
    NSNumber *seqNum = [NSNumber numberWithLongLong:seqNo];
    [self.seqNumDict setObject:data forKey:seqNum];
}

/**
 *  @author semny
 *
 *  获取请求记录队列中的数据
 *
 *  @param seqno 请求序列号
 *
 *  @return 请求记录队列中的数据
 */
- (id)objectInRecordStackForSeqno:(long long)seqNo
{
    NSNumber *seqNum = [NSNumber numberWithLongLong:seqNo];
    id obj = [self.seqNumDict objectForKey:seqNum];
    return obj;
}
@end
