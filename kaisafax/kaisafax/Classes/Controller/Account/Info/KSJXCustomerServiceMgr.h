//
//  KSJXCustomerServiceMgr.h
//  kaisafax
//
//  Created by BeiYu on 2016/12/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSJXCustomerServiceMgr : NSObject
-(void)jumpToCustomerCenter:(UINavigationController*)nav;
-(void)loginJXCustomer:(UINavigationController*)nav;
-(void)loginJXSuccessed:(UINavigationController*)nav;

+ (instancetype)sharedInstance;

@end
