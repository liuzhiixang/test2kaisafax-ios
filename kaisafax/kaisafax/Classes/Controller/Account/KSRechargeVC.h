//
//  KSRechargeVC.h
//  kaisafax
//
//  Created by Jjyo on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"
#import "KSBankBL.h"
//typedef NS_ENUM(NSUInteger,KSRechargeSourceType)
//{
//    KSRechargeSourceTypeRegister=0,     //从注册入口来的
//    KSRechargeSourceTypeAccount=1,      //从账户中心来的
//    KSRechargeSourceTypeInvestDetail=2  //从投资详情来的
//};

@interface KSRechargeVC : KSNVBackVC
@property (nonatomic,assign) KSWebSourceType type;
@property (nonatomic, assign) NSInteger bankType;

@property (nonatomic, copy) NSString *available;
//@property (nonatomic,copy) NSString *actionFlag;
@property (nonatomic, assign) NSInteger actionFlag;
@end
