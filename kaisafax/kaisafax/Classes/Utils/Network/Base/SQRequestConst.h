//
//  SQRequestConst.h
//  kaisafax
//
//  Created by semny on 15/10/6.
//  Copyright © 2015年 kaisafax. All rights reserved.
//

#ifndef SQRequestConst_h
#define SQRequestConst_h

////请求错误
//typedef enum:NSInteger
//{
//    SQRequest_RES_REQUESTBUSINESS_ERR = -7,     //业务错误
//    SQRequest_RES_REQUESTNULL_ERR = -6,         //本地请求空
//    SQRequest_RES_NO_SOURCE = -5,               //请求不到资源
//    SQRequest_RES_URL_ERR = -4,                 //网络URL错误
//    SQRequest_RES_PARSER_ERR = -3,              //数据解析错误
//    SQRequest_RES_NETWORK_ERR = -2,             //网络连接错误
//    SQRequest_RES_TIMEOUT_ERR = -1,             //本地请求超时
//    SQRequest_RES_SUCCESS = 0                   // 成功
//}SQRequestErrorCode;

//请求的结果码
//typedef NS_ENUM(NSUInteger, SQRESPONSE_CODE)
//{
//    SQRequest_RES_SUCESS = 100, //请求成功
//};

//请求方法类型
typedef NS_ENUM(NSInteger , SQRequestMethod) {
    SQRequestMethodGet = 0,
    SQRequestMethodPost,
    SQRequestMethodHead,
    SQRequestMethodPut,
    SQRequestMethodDelete,
    SQRequestMethodPatch,
};

typedef NS_ENUM(NSInteger,SQCachePolicy)
{
    SQCachePolicyNoCache = 0,                   //不使用缓存
    SQCachePolicyCacheWithEntireURI,			//使用URI标识缓存
    SQCachePolicyCacheWithIdentifier			//使用自定义的cacheIdentifier作为缓存
};

//序列化类型
typedef NS_ENUM(NSInteger , SQRequestSerializerType) {
    SQRequestSerializerTypeHTTP = 0,
    SQRequestSerializerTypeJSON,
};

//网络状态
typedef NS_ENUM(NSInteger, SQRequestReachabilityStatus) {
    SQRequestReachabilityStatusUnknown          = -1,
    SQRequestReachabilityStatusNotReachable     = 0,
    SQRequestReachabilityStatusReachableViaWWAN = 1,
    SQRequestReachabilityStatusReachableViaWiFi = 2,
};

#endif /* SQRequestConst_h */