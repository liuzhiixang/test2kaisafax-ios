//
//  KSDepositResultVC.h
//  sxfax
//
//  Created by philipyu on 16/4/29.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNVBackVC.h"

@interface KSDepositResultVC : KSNVBackVC
//返回错误结果或者成功的金额
@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *result;
//区分加急和普通的提示
@property (nonatomic,copy) NSString *cashChl;
@property (nonatomic,assign) NSInteger type;

@end
