//
//  KSDBHelper.m
//  kaisafax
//
//  Created by Semny on 15/3/20.
//  Copyright (c) 2015年 kaisafax. All rights reserved.
//

#import "KSDBHelper.h"
#import "NSString+Format.h"
#import "KSCacheMgr.h"
#import <sqlite3.h>

#define KDBVersionKey       @"DBVersionKeyValue"

#define BUNDLE(s)                   [[NSBundle mainBundle] pathForResource:s ofType:nil]
#define STRING_BUNDLE_FILE(s)       [NSString stringWithContentsOfFile:BUNDLE(s) encoding:NSUTF8StringEncoding error:nil]


@interface KSDBHelper()
{
}
@end

@implementation KSDBHelper

//@synthesize databaseQueue = _databaseQueue;

+ (id)sharedInstance
{
    static KSDBHelper *instance = nil;
    static dispatch_once_t dbpredicate;
    dispatch_once(&dbpredicate, ^{
        if (instance  == nil)
        {
            instance = [[KSDBHelper alloc] init];
        }
    });
    return instance;
}

-(id)init
{
    if (self = [super init])
    {
        //检测数据库文件是否存在
        BOOL isExist = [self checkDBFileExistAndCreate];
        
        if (!isExist)
        {
            ERROR(@"Create database file error!");
            return nil;
        }
        
        //初始化数据库队列对象
        NSString *dbPath = [KSDBHelper getDBFilePath];
        //初始化数据库对象
        //_database = [FMDatabase databaseWithPath:dbPath];
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath flags:SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE|SQLITE_OPEN_FULLMUTEX];
        
        //打开数据库连接
        //[_database openWithFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE|SQLITE_OPEN_FULLMUTEX];
    }
    return self;
}

#pragma mark -
#pragma mark -----------------初始化数据库对象及表格--------------------
- (void)startInitOrUpdate
{
    static dispatch_once_t once_time;
    __weak __typeof(self) weakSelf = self;
    dispatch_once(&once_time, ^{
        INFO(@"<<<>>> %s", __FUNCTION__);
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        BOOL isExist = [strongSelf checkDBFileExistAndCreate];
        if (isExist && strongSelf.databaseQueue != nil)
        {
            //查询数据库版本号并且根据版本号更新数据库
            [strongSelf queryDBVersionAnInitDB];
        }
        else
        {
            ERROR(@"Create database file error!");
            return;
        }
    });
}

#pragma mark ----- Private Methods -----
+ (NSString *)getDBFilePath
{
    NSString *databasePath = [KSCacheMgr getDBFilePath];
    return databasePath;
}

- (BOOL)checkDBFileExistAndCreate
{
    NSString *databasePath = [[self class] getDBFilePath];
    
#if DEBUG
   DEBUGG(@"Database file path%@",databasePath);
#endif
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileDirect = [databasePath stringByDeletingLastPathComponent];
    
    BOOL flag = YES;
    //检查数据库文件是否存在，不存在则创建
    if([fileManager fileExistsAtPath:databasePath])
    {
        return flag;
    }
    else
    {
        //外层文件夹
        if (![fileManager fileExistsAtPath:fileDirect])
        {
            //数据库文件夹
            flag = [fileManager createDirectoryAtPath:fileDirect
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:nil];
            if (!flag)
            {
                return NO;
            }
        }
        //文件夹存在或创建成功，创建数据库文件
        /**
         *  方案一
         */
        sqlite3 *db = nil;
        //打开数据库文件,如果不存在则创建数据库
        const char *dbFile = [databasePath UTF8String];
        if (sqlite3_open(dbFile, &db) != SQLITE_OK)
        {
            sqlite3_close(db);
            NSLog(@"数据库打开失败");
            return NO;
        }
        //方案二
//        NSError *error = nil;
//        NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"Cache" ofType:@"db"];
//        flag = [fileManager copyItemAtPath:dbPath toPath:databasePath error:&error];
    }
    return flag;
}

/**
 *  第一个版本初始化
 */
- (BOOL)initDBOrUpdate1By:(FMDatabase *)db
{
    BOOL flag = YES;
    if(db && [db open])
    {
        NSString *sql = nil;
        //BOOL result = NO;
        //视频信息表
        BOOL isExists1 = [db tableExists:@"TB_Media_Info"];
        if (!isExists1)
        {
            sql = STRING_BUNDLE_FILE(@"TB_Media_Info.sql");
            flag = flag&[KSDBHelper execute:db sql:sql];
        }
        
//        //视频信息关系表(本地，网络)
//        BOOL isExists2 = [db tableExists:@"TB_Video_Relation"];
//        if (!isExists2)
//        {
//            sql = STRING_BUNDLE_FILE(@"TB_Video_Relation.sql");
//            flag = flag&[KSDBHelper execute:db sql:sql];
//        }
        
        //创建数据库版本信息表
        BOOL isExists3 = [db tableExists:@"TB_Version"];
        if (!isExists3)
        {
            sql = STRING_BUNDLE_FILE(@"TB_Version.sql");
            flag = flag&[KSDBHelper execute:db sql:sql];
        }
        
        //设置版本信息
        flag = flag&[KSDBHelper updateDBVersion:db version:1];
        
    }
    return flag;
}

/**
 *  查询数据库版本信息数据
 *
 *  @param key 数据库版本信息唯一key
 *
 *  @return 数据库版本
 */
- (void)queryDBVersion:(NSString *)key resultBlock:(KSDBHandleBlock)resultBlock
{
    FMDatabaseQueue *dbQueue = self.databaseQueue;
    [dbQueue inDatabase:^(FMDatabase *db) {
        BOOL flag = [db tableExists:@"TB_Version"];
        NSError *qError = nil;
        NSNumber *versionNum = nil;
        if (flag)
        {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'TB_Version' WHERE versionKey='%@'", key];
            FMResultSet *rs = [db executeQuery:sql];
            while ([rs next])
            {
                versionNum = [rs objectForColumnName:@"version"];
            }
        }
        else
        {
            //不存在版本表
            qError = [NSError errorWithDomain:KDBErrorDomainKey code:KSDBErrorCodeTableNotExist userInfo:nil];
        }
        resultBlock(versionNum, qError);
    }];
}

- (void)queryDBVersionAnInitDB
{
    FMDatabaseQueue *dbQueue = self.databaseQueue;
    __weak __typeof(self) weakSelf = self;
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL flag = [db tableExists:@"TB_Version"];
        //NSError *qError = nil;
        NSNumber *versionNum = nil;
        if (flag)
        {
            NSString *key = KDBVersionKey;
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM 'TB_Version' WHERE versionKey='%@'", key];
            FMResultSet *rs = [db executeQuery:sql];
            while ([rs next])
            {
                versionNum = [rs objectForColumnName:@"version"];
            }
        }
        else
        {
            //不存在版本表
        }
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSInteger dbVersion = versionNum.integerValue;
        //升级数据库。第一次创建版本version为0或者查不到版本信息，则初始化数据库；后续版本依次升级，因此不可以有break；
        switch (dbVersion) {
            case 0:
                //第一次，新建并初始化各表
                flag = [strongSelf initDBOrUpdate1By:db];
            default:
                break;
        }
        
        if (!flag)
        {
            //回滚
            *rollback = YES;
        }
    }];
}


/**
 *  更新数据库版本信息
 *
 *  @param db      数据库实体
 *  @param version 版本数字编号
 *
 *  @return 是否操作成功
 */
+ (BOOL)updateDBVersion:(FMDatabase *)db version:(int)version
{
    BOOL flag = NO;
    if(!db || version <= 0)
    {
        return flag;
    }
    
    NSString *alertSql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO TB_Version(versionKey,version) values('%@',%d);", KDBVersionKey, version];
    
    flag = [KSDBHelper execute:db sql:alertSql];
    
    return flag;
}

/**
 *  清理数据库缓存
 *
 *  @return 是否清理成功
 */
+ (void)clearDBCachedData:(KSDBHandleBlock)resultBlock
{
    //删除数据库中所有的表数据
    NSString *sql = @"SELECT name FROM sqlite_master where type='table'";
    
    FMDatabaseQueue *dbQueue = [[KSDBHelper sharedInstance] databaseQueue];
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:sql];
        
        BOOL resultVal = YES;
        while ([rs next])
        {
            NSString *tableName = [rs stringForColumn:@"name"];
            if (tableName && tableName.length > 0)
            {
                if([tableName isEqualToString:@"TB_Version"])
                {
                    //什么也不做
                }
                else
                {
                    NSString *dropSql = [NSString stringWithFormat:@"DELETE FROM '%@'",tableName];
                    resultVal = resultVal&[db executeUpdate:dropSql];
                }
            }
        }
        if (!resultVal)
        {
            *rollback = YES;
            ERROR(@"Clear database data failed, error: %@",[db lastErrorMessage]);
        }
    }];
}

#pragma mark -
#pragma mark ------------外部接口操作-----------------
/**
 *  添加表格的属性列
 *
 *  @param db       数据库实体
 *  @param table    表格名称
 *  @param column   列名
 *  @param typeName 类型名称字符串
 *  @param value    默认数据
 *
 *  @return 是否操作成功
 */
+ (BOOL)add:(FMDatabase *)db table:(NSString *)table column:(NSString *)column columnType:(NSString *)typeName defaultValue:(id)value
{
    BOOL flag = NO;
    if(!db || !table || !column || !typeName)
    {
        return flag;
    }
    
    NSString *alertSql = [NSString stringWithFormat:@"ALTER TABLE '%@' ADD '%@' %@ DEFAULT %@;", table, column, typeName, value];
    
    flag = [KSDBHelper execute:db sql:alertSql];
    
    return flag;
}

/**
 *  删除表格的属性列
 *
 *  @param db       数据库实体
 *  @param table    表格名称
 *  @param column   列名
 *  @param typeName 类型名称字符串
 *  @param value    默认数据
 *
 *  @return 是否操作成功
 */
+ (BOOL)delete:(FMDatabase *)db table:(NSString *)table column:(NSString *)column columnType:(NSString *)typeName defaultValue:(id)value
{
    BOOL flag = NO;
    if(!db || !table || !column || !typeName)
    {
        return flag;
    }
    
    NSString *alertSql = [NSString stringWithFormat:@"ALTER TABLE '%@' DELETE '%@' %@ DEFAULT %@;", table, column, typeName, value];
    
    flag = [KSDBHelper execute:db sql:alertSql];
    
    return flag;
}

/**
 *  执行数据库表操作
 *
 *  @param db       数据库DB文件
 *  @param sql      数据库操作sql语句
 *
 *  @return 创建是否成功
 */
+ (BOOL)execute:(FMDatabase *)db sql:(NSString *)sql
{
    if(!db)
    {
        return NO;
    }
    
    sql = [sql trim];
    if(!sql || sql.length <= 0)
    {
        return NO;
    }
    
    BOOL flag = [db executeUpdate:sql];
    if (!flag)
    {
        ERROR(@"Database execute error, sql: %@", sql);
    }
    return flag;
}

@end
