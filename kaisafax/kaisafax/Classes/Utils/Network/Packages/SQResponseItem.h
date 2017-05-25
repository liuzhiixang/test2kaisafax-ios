//
//  SQResponseProtocol.h
//  kaisafax
//
//  Created by semny on 8/6/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQResponseItem : NSObject

//接口名称
//@property (nonatomic, copy) NSString *tradeId;

//从服务器返回的数据(二进制数据)
@property (nonatomic, strong) NSData *responseData;

//从服务器返回的数据(已经解析好的)
@property (nonatomic, strong) id responseObject;

////是否成功请求
//@property (nonatomic, assign) BOOL isSuccess;
//
////返回结果码
//@property (nonatomic, assign) NSInteger responseStatusCode;

//是否是从缓存文件中读取出来的
@property (nonatomic, assign) BOOL readFromCache;

//整个请求到响应的总时长
@property (nonatomic, assign) NSTimeInterval time;


@end
