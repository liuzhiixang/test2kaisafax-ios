//
//  JSClient.h
//  kaisafax
//
//  Created by Jjyo on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#define JS_NAME @"client"

//--delegate
@protocol JSClientDelegate <NSObject>
@optional
- (void)share:(NSString *)jsonString;
- (void)startPage:(NSString *)jsonString;
//-(void)syncSession:(NSString *)sessionString;
@end

@interface JSClient : NSObject
- (instancetype)initWithDelegate:(id<JSClientDelegate>)delegate;

@property (nonatomic, weak) id<JSClientDelegate> delegate;

//协议 client.share
- (void)share:(NSString *)jsonString;
//协议 client.startPage
- (void)startPage:(NSString *)jsonString;
//协议 client.syncSession
//-(void)syncSession:(NSString *)sessionString;


////协议 client.operation(各种跳转，js加载操作)
//- (void)operation:(NSString *)jsonString;
////协议 client.result(结果操作)
//- (void)result:(NSString *)jsonString;
////协议 client.share(分享操作)
//- (void)share:(NSString *)jsonString;
////协议 client.syncSession(同步登录态操作)
//-(void)syncSession:(NSString *)sessionString;
@end

