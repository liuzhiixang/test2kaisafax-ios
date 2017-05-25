//
//  KSRechargeResultVC.h
//  sxfax
//
//  Created by philipyu on 16/4/29.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNVBackVC.h"

//typedef NS_ENUM(NSUInteger,KSRechargeSourceType)
//{
//    KSRechargeSourceTypeRegister=0,     //从注册入口来的
//    KSRechargeSourceTypeAccount=1,      //从账户中心来的
//    KSRechargeSourceTypeInvestDetail=2,  //从投资详情来的
//    KSRechargeSourceTypeHome=3   //从首页来的
//};



@interface KSRechargeResultVC : KSNVBackVC

@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *result;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,assign) NSInteger type;

//操作标志(普通充值，差额充值)
@property (nonatomic,assign) NSInteger actionFlag;

@end
