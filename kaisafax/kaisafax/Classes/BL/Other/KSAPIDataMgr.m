//
//  KSAPIDataMgr.m
//  kaisafax
//
//  Created by semny on 16/7/29.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAPIDataMgr.h"

//#define KAPICSHashMapName         @"APICSHash"
#define KAPISCHashMapName         @"APISCHash"

@interface KSAPIDataMgr()

//请求返回的接口数据对象, key: tradeId, value:return model class
@property (nonatomic, retain) NSDictionary *apiSCHashMap;
//请求发送的数据对象 key: tradeId, value:cs class
//@property (nonatomic, retain) NSDictionary *apiCSHashMap;

@end

@implementation KSAPIDataMgr
/**
 *  初始化API的数据包管理单例对象
 *
 *  @return API的数据包管理单例对象
 */
+(id)sharedInstance
{
    static KSAPIDataMgr *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^
                  {
                      if (instance  == nil)
                      {
                          instance = [[KSAPIDataMgr alloc] init];
                      }
                  });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
//        NSString *csPath = [[NSBundle mainBundle] pathForResource:KAPICSHashMapName ofType:@"plist"];
//        _apiCSHashMap = [[NSDictionary alloc] initWithContentsOfFile:csPath];
        NSString *scPath = [[NSBundle mainBundle] pathForResource:KAPISCHashMapName ofType:@"plist"];
        _apiSCHashMap = [[NSDictionary alloc] initWithContentsOfFile:scPath];
    }
    return self;
}

/**
 *  获取请求返回的数据类对象(空的，需要填充属性)
 *
 *  @param tradeId 网络请求业务接口编号(老的服务端没有定义)
 *
 *  @return 网络请求返回的数据类对象
 */
-(Class)returnedClassBy:(NSString *)tradeId
{
    id returnObj = nil;
    if(!tradeId || tradeId.length <= 0)
    {
        return returnObj;
    }
    
    //获取映射类对象
    if(_apiSCHashMap && _apiSCHashMap.count > 0)
    {
        NSString *keStr = tradeId;
        NSString *returnInfoName = [_apiSCHashMap objectForKey:keStr];
        
        if (returnInfoName && returnInfoName.length > 0)
        {
            //固定格式组合的Model class name
            NSString *returnObjClassName = [NSString stringWithFormat:@"KS%@Entity", returnInfoName];
            returnObj = NSClassFromString(returnObjClassName);
        }
    }
    return returnObj;
}

/**
 *  根据Class名称字符串初始化对象
 *
 *  @param className Class名称字符串
 *
 *  @return Class名称字符串对应的对象，或者nil
 */
-(id)objectFromClassName:(NSString *)className
{
    id obj = nil;
    if (className)
    {
        Class objClass = NSClassFromString(className);
        if (objClass)
        {
            obj = [[objClass alloc] init];
        }
    }
    return obj;
}

@end
