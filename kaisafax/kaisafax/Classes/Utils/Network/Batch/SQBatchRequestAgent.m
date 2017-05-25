//
//  SQBatchRequestAgent.m
//  kaisafax
//
//  Created by semny on 16/7/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SQBatchRequestAgent.h"

@interface SQBatchRequestAgent()

@property (strong, nonatomic) NSMutableArray *requestArray;

@end

@implementation SQBatchRequestAgent

+ (SQBatchRequestAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addBatchRequest:(SQBatchRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeBatchRequest:(SQBatchRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

@end
