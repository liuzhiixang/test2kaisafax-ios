//
//  SQRequestProtocol.h
//  kaisafax
//
//  Created by semny on 8/6/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQRequestConst.h"

@interface SQRequestItem : NSObject

//请求方法 GET / POST
@property (nonatomic, assign) SQRequestMethod method;

//是否使用CDN的host地址(YES:使用,NO:不使用)
@property (nonatomic, assign) BOOL isUseCND;

//请求的地址
@property (nonatomic, copy) NSString *requestUrl;
//请求的CdnURL
@property (nonatomic, copy) NSString *cdnUrl;
//请求的BaseURL
@property (nonatomic, copy) NSString *baseUrl;

//如果使用CacheWithIdentifier则可以设置此 cacheIdentifier，如果不填写此属性，则自动使用URL
//@property (nonatomic, copy) NSString *cacheIdentifier;

//使用的Cache策略
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

//需要跟随请求发送的数据(POST的时候使用)
@property (nonatomic, strong) NSData *data;

//需要跟随请求发送的数据(字典数据，可以给GET请求组合使用，也可以转化后给POST使用)
@property (nonatomic, strong) NSDictionary *requestArgument;

// 用于检查JSON是否合法的对象,默认为空，不设置json格式的检测模版
@property (nonatomic, strong) id jsonValidator;

@end
