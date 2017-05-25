//
//  KSAPIDataMgr.h
//  kaisafax
//
//  Created by semny on 16/7/29.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSAPIDataMgr : NSObject

/**
 *  初始化API的数据包管理单例对象
 *
 *  @return API的数据包管理单例对象
 */
+(id)sharedInstance;

/**
 *  获取请求返回的数据类对象(空的，需要填充属性)
 *
 *  @param tradeId 网络请求业务接口编号(老的服务端没有定义)
 *
 *  @return 网络请求返回的数据类对象
 */
-(Class)returnedClassBy:(NSString *)tradeId;

@end
