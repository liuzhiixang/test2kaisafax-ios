//
//  KSGestureVerifyVC.h
//  kaisafax
//
//  Created by semny on 16/11/17.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNVBaseVC.h"
#import "SQGestureMgr.h"

//校验错误次数超限
#define KGestureVerifyErrorCode  161301

//手势密码校验
@interface KSGestureVerifyVC : KSNVBaseVC

//来源
@property (nonatomic, assign) GestureFromType fromType;
//校验结束block
@property (nonatomic, copy) void(^gestureVerifyFinishBlock)(UIViewController *vc, NSInteger actionType, NSError *error);

@end
