//
//  WX_m
//  
//
//  Created by Semny on 14-9-28.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "WXHTTPRequest.h"

@interface WXHTTPRequest () <NSURLConnectionDataDelegate>

@end

@implementation WXHTTPRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)requestWithWXURL:(NSString *)url
              httpMethod:(NSString *)httpMethod
                  params:(NSDictionary *)params
                delegate:(id<SocialAPIWeChatHttpRequestDelegate>)delegate
                 withTag:(NSString *)tag {
    
    _url = url;
    _httpMethod = httpMethod;
    _params = params;
    _delegate = delegate;
    _tag = tag;
    
    NSURLRequest *request = nil;
    
    if ([_httpMethod isEqualToString:@"GET"]) {
        // 拼接URL字符串
        NSString *requestURLStr = [_url stringByAppendingString:@"?"];
        for (NSString *key in [_params allKeys]) {
            requestURLStr = [NSString stringWithFormat:@"%@%@=%@&", requestURLStr, key, _params[key]];
        }
        requestURLStr = [requestURLStr substringToIndex:(requestURLStr.length - 1)];
        
        // 创建请求
        NSURL *requestURL = [NSURL URLWithString:requestURLStr];
        NSURLRequest *getRequest = [NSURLRequest requestWithURL:requestURL
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:10.0];
        request = getRequest;
    }
    else if ([_httpMethod isEqualToString:@"POST"]) {
        // 创建url
        NSURL *requestURL = [NSURL URLWithString:_url];
        
        // 创建请求
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:requestURL
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10];
        [postRequest setHTTPMethod:@"POST"];
        NSData *paramData = [NSJSONSerialization dataWithJSONObject:_params options: NSJSONWritingPrettyPrinted error:nil];
        [postRequest setHTTPBody:paramData];
        request = postRequest;
    }
    else
    {
        NSURL *requestURL = [NSURL URLWithString:_url];
        request = [NSURLRequest requestWithURL:requestURL
                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                               timeoutInterval:10.0];;
    }
    
   _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void)disconnect {
    [_connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_delegate && [_delegate respondsToSelector:@selector(requestWeChat:didReceiveData:)]) {
        [_delegate requestWeChat:self didReceiveData:data];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(requestWeChat:didFailWithError:)]) {
        [_delegate requestWeChat:self didFailWithError:error];
    }
}

@end

