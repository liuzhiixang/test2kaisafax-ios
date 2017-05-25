//
//  WXHTTPRequest.h
//  
//
//  Created by Semny on 14-9-28.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  SocialAPIWeChatHttpRequestDelegate;

@interface WXHTTPRequest : NSObject {
    NSURLConnection *_connection;
    NSMutableData *_responseData;
}

/**
 用户自定义请求地址URL
 */
@property (nonatomic, copy) NSString *url;

/**
 用户自定义请求方式
 
 支持"GET" "POST"
 */
@property (nonatomic, copy) NSString *httpMethod;

/**
 用户自定义请求参数字典
 */
@property (nonatomic, strong) NSDictionary *params;

/**
 WXHTTPRequestDelegate对象，用于接收微信SDK对于发起的接口请求的请求的响应
 */
@property (nonatomic, assign) id<SocialAPIWeChatHttpRequestDelegate> delegate;

/**
 用户自定义TAG
 
 用于区分回调Request
 */
@property (nonatomic, copy) NSString* tag;

/**
 统一HTTP请求接口
 调用此接口后，将发送一个HTTP网络请求
 @param url 请求url地址
 @param httpMethod  支持"GET" "POST"
 @param params 向接口传递的参数结构
 @param delegate WBHttpRequestDelegate对象，用于接收微信SDK对于发起的接口请求的请求的响应
 @param tag 用户自定义TAG,将通过回调WBHttpRequest实例的tag属性返回
 */
- (void)requestWithWXURL:(NSString *)url
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                         delegate:(id<SocialAPIWeChatHttpRequestDelegate>)delegate
                          withTag:(NSString *)tag;

/**
 取消网络请求
 调用此接口后，将取消当前网络请求;
 */
- (void)disconnect;

@end

#pragma mark - SocialAPIWeChatHttpRequestDelegate

/**
 接收并处理来自微信sdk对于网络请求接口的调用响应 以及openAPI
 */
@protocol SocialAPIWeChatHttpRequestDelegate <NSObject>

/**
 收到一个来自微信Http请求的响应
 
 @param response 具体的响应对象
 */
@optional
- (void)requestWeChat:(WXHTTPRequest *)request didReceiveData:(NSData *)data;

/**
 收到一个来自微信Http请求失败的响应
 
 @param error 错误信息
 */
@optional
- (void)requestWeChat:(WXHTTPRequest *)request didFailWithError:(NSError *)error;

@end

