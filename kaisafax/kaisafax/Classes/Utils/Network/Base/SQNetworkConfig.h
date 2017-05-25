//
//  SQNetworkConfig.h
//  kaisafax
//
//  Created by semny on 8/6/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQBaseRequest.h"

@protocol SQUrlFilterProtocol <NSObject>
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(SQBaseRequest *)request;
@end

@protocol SQCacheDirPathFilterProtocol <NSObject>
- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(SQBaseRequest *)request;
@end

@interface SQNetworkConfig : NSObject

+ (SQNetworkConfig *)sharedInstance;

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *cdnUrl;
@property (strong, nonatomic, readonly) NSArray *urlFilters;
@property (strong, nonatomic, readonly) NSArray *cacheDirPathFilters;
@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;

- (void)addUrlFilter:(id<SQUrlFilterProtocol>)filter;
- (void)addCacheDirPathFilter:(id <SQCacheDirPathFilterProtocol>)filter;

@end
