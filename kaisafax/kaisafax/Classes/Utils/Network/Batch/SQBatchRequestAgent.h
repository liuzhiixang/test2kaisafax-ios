//
//  SQBatchRequestAgent.h
//  kaisafax
//
//  Created by semny on 16/7/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQBatchRequest.h"

@interface SQBatchRequestAgent : NSObject

+ (SQBatchRequestAgent *)sharedInstance;

- (void)addBatchRequest:(SQBatchRequest *)request;

- (void)removeBatchRequest:(SQBatchRequest *)request;

@end
