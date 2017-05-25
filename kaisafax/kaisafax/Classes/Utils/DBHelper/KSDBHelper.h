//
//  KSDBHelper.h
//  kaisafax
//
//  Created by Semny on 15/3/20.
//  Copyright (c) 2015年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

#define KSDBHELPER_H  YES

//数据库操作结果的错误信息
#define  KDBErrorDomainKey  @"DBErrorDomain"
//#define  KDBErrorCode       -1
typedef enum:NSUInteger
{
    KSDBErrorCodeNormal = -1,           //普通错误
    KSDBErrorCodeTableNotExist = -2    //数据表不存在
}KSDBErrorCode;

/**
 *  数据库操作处理结果回调block
 *
 *  @param result 结果对象
 *  @param error  错误
 */
typedef void (^KSDBHandleBlock)(id result, NSError *error);

@interface KSDBHelper : NSObject

//@property (nonatomic,readonly,retain) FMDatabase   *database;
@property (nonatomic,readonly,strong) FMDatabaseQueue   *databaseQueue;

/**
 *  @brief 单例方法
 *
 *  @return 数据库helper对象
 */
+(id)sharedInstance;

/**
 *  初始化并且更新数据库
 */
- (void)startInitOrUpdate;

/**
 *  清理数据库缓存
 *  @param resultBlock 结果回调
 */
+ (void)clearDBCachedData:(KSDBHandleBlock)resultBlock;

@end
