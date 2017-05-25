//
//  SQRequestManagerDelegate.h
//  kaisafax
//
//  Created by semny on 17/5/10.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQBaseRequest.h"

@protocol SQRequestManagerDelegate <NSObject>

//处理完成
- (void)complete:(SQBaseRequest*)request responseObject:(id)responseObject;

//错误
- (void)failed:(SQBaseRequest*)request error:(NSError*)error;

@end
