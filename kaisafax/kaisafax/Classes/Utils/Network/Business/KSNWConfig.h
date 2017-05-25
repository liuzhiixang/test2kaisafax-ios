//
//  KSNWConfig.h
//  kaisafax
//
//  Created by semny on 16/7/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#ifndef KSNWConfig_h
#define KSNWConfig_h

#pragma mark - 结果编码
//返回的结果编码
typedef enum {
    //系统级别错误，属于接入层，与具体业务可剥离
    
    
    KSNW_RES_UNKNOWN_ERR = -6,              //未知错误
    KSNW_RES_TRADEID_ERR = -5,              //tradeid错误(请求method)
    KSNW_RES_URL_ERR = -4,                  //URL地址错误
    KSNW_RES_PARSER_ERR = -3,               //数据解析错误
    KSNW_RES_NETWORK_ERR = -2,              //网络连接错误
    KSNW_RES_TIMEOUT_ERR = -1,              //本地请求超时
    KSNW_RES_SUCCESS = 0,                   //成功
    KSNW_RES_SERVICE_ERR = 1,               //服务不可用
    KSNW_RES_DEVELOP_PERMISSIONS_ERR = 2,   //开发者权限不够
    KSNW_RES_USER_PERMISSIONS_ERR = 3,      //用户权限不足
    KSNW_RES_UPLOAD_PICTURE_ERR = 4,        //图片上传失败
    KSNW_RES_METHOD_FORBIDDEN_ERR = 5,       //方法被禁止
    KSNW_RES_ENCODE_ERR = 6,                //编码错误
    KSNW_RES_REQUEST_FORBIDDEN_ERR = 7,      //请求被禁止
    KSNW_RES_METHOD_ABOLISHED_ERR = 8,       //已经作废
    KSNW_RES_BUSINESS_ERR = 9,               //业务逻辑出错
    KSNW_RES_MISS_SESSIONID_ERR = 20,         //缺少会话参数
    KSNW_RES_INVALID_SESSIONID_ERR = 21,      //会话ID无效
    KSNW_RES_MISS_APPKEY_ERR = 22,              //缺少appkey
    KSNW_RES_INVALID_APPKEY_ERR = 23,         //无效appkey
    KSNW_RES_MISS_SIGN_ERR = 24,                //无SIGN
    KSNW_RES_INVALID_SIGN_ERR = 25,            //无效SIGN
    KSNW_RES_MISS_METHOD_ERR = 26,            //缺少method
    KSNW_RES_UNKNOWN_METHOD_ERR = 27,         //不存在的method
    KSNW_RES_MISS_VERSION_ERR = 28,            //缺少VERSION
    KSNW_RES_UNKNOWN_VERSION_ERR = 29,          //不存在的version
    KSNW_RES_INVALID_VERSION_ERR = 30,          //不支持对应的版本号
    KSNW_RES_PKG_FORMAT_ERR = 31,               //报文数据格式无效
    KSNW_RES_MISS_PARAMS_ERR = 32,               //缺少必要的参数
    KSNW_RES_PARAMS_ERR = 33,                    //参数非法
    KSNW_RES_REQUEST_TIMES_ERR = 34,             //请求次数超限
//    35    用户会话调用服务的次数超限
//    36    应用调用服务的次数超限
//    37    应用调用服务的频率超限
    KSNW_RES_REQUEST_BUSSINESS_ERR = 10000,             //业务错误分界点
    
    
    /**
    KSNW_RES_TRADEID_ERR = -5,              //tradeid错误(请求method)
    KSNW_RES_URL_ERR = -4,                  //URL地址错误
    KSNW_RES_PARSER_ERR = -3,               //数据解析错误
    KSNW_RES_NETWORK_ERR = -2,              //网络连接错误
    KSNW_RES_TIMEOUT_ERR = -1,              //本地请求超时
    KSNW_RES_SUCCESS = 0,                   //成功
    KSNW_RES_UNKNOWN_ERR = 1,                   //未知错误
    KSNW_RES_PKG_ERR = 2,                   //消息体打包错误
    KSNW_RES_NORELAY = 3,                   //接入层不要转发
    KSNW_RES_PERMISSION_ERR = 4,            //没有权限
    KSNW_RES_MISS_PARAMS_ERR = 5,                //缺少参数
    KSNW_RES_BUSINESS_ERR = 6,              //业务错误(临时)
    
    //用户相关的错误，登录注册等接口使用
    KSNW_RES_VERIFY_CODE_ERR = 101,         //验证码错误
    KSNW_RES_SID_ERR = 102,                 //sid错误
    KSNW_RES_MOBILENO_EXISTED = 103,        //手机帐号已存在(注册)
    KSNW_RES_MOBILENO_NOTEXISTED = 104,     //手机帐号不存在(找回密码)
    KSNW_RES_ERR_PASS = 105,                //帐号或密码错
    KSNW_RES_USERID_NOTEXISTED = 106,		//用户id不存在
    KSNW_RES_TOKEN_EXPIRED = 107,           //token过期
    KSNW_RES_USER_FORBIDDEN = 108,           //用户被封禁
    //新定义的用户未登录
    KSNW_RES_USER_UNLOGIN_ERR = 10101           //用户未登录
     */
}KSNWResponseCode;


/**
 0     成功
 1     服务不可用
 2     开发者权限不足
 3     服务方法({0}:{1})用户权限不足
 4     服务方法({0}:{1})图片上传失败,原因为:{2}
 5     服务方法({0}:{1})HTTP方法{2}被禁止
 6     服务方法({0}:{1})编码错误
 7     服务方法({0}:{1})请求被禁止
 8     服务方法({0}:{1})已经作废
 9     服务方法({0}:{1})业务逻辑出错
 20    服务方法({0}:{1})缺少会话参数:{2}
 21    服务方法({0}:{1})的会话ID:{2}无效
 22    服务方法({0}:{1})缺少应用键参数:{2}
 23    服务方法({0}:{1})的应用键参数{2}无效
 24    服务方法({0}:{1})需要签名,缺少签名参数:{2}
 25    服务方法({0}:{1})的签名无效
 26    服务请求缺少方法名参数:{0}
 27    调用不存在的服务方法:{0}
 28    服务方法({0})缺少版本参数:{1}
 29    服务方法({0})不存在对应的版本({1})
 30    服务方法({0})不支持对应的版本号({1})
 31    服务方法({0}:{1})的报文数据格式无效({2})
 32    服务方法({0}:{1})缺少必要的参数
 33    服务方法({0}:{1})的参数非法
 34    服务方法({0}:{1})的调用次数超限
 35    用户会话调用服务的次数超限
 36    应用调用服务的次数超限
 37    应用调用服务的频率超限
 
 业务类型错误码说明 >10000
 用户类型错误码
 注册业务类型错误码   100**
 登录业务类型错误码   101**
 终端检查业务错误码（版本、设备上报） 102**
 银行卡业务类型错误码  103**
 账户理财业务类型错误码 104**
 投资记录、自动投标业务类型错误码 105**
 红包、奖励模块业务类型错误码 106**
 资金记录业务类型错误码 107**
 我的推广业务类型错误码 108**
 账户安全业务类型错误码 109**
 京东E卡业务类型错误码  110**
 统一短信类型错误码 199**
 */


#pragma mark - 请求和返回的报文字段
//报文头
//交易ID	用于区分报文体的类型
#define KRequestTradeId         @"tradeId"
//报文返回时间		报文返回时间，格式yyyyMMddHHmmss
#define KRequestTimestamp       @"timestamp"

#pragma mark - 返回的报文字段
#define KResponseHeadKey            @"head"
#define KResponseBodyKey            @"body"
//请求方法
#define KResponseMethodKey          @"method"
//返回码 0表示成功，否则失败，没有报文体(只是业务错误码，http相关的错误在在http头中，由服务端约定好，最好是多个平台统一错误编码)
#define KResponseErrorCodeKey       @"errorCode"
//返回信息
#define KResponseErrorMsgKey        @"errorMsg"

//登录相关信息
#define KLoginUserEncryptedKey     @"LoginUserEncrypted"

//网络请求错误信息
#define KResultErrorMsgKey                  @"ResultErrorMsgKey"
#define KResultErrorDomain                  @"com.kaisafax.app"


#define KConnectionEncryptedKey             @"ConnectionEncryptedKey"
#define KConnectionSessionIdKey             @"ConnectionSessionId"


#define KRequestFailedMsgText      NSLocalizedString(@"RequestFailedMsgText",@"Request Failed")


#endif /* KSNWConfig_h */
