//
//  KSGestureVC.h
//  kaisafax
//
//  Created by semny on 16/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQGestureMgr.h"
#import "KSNVBaseVC.h"

//收拾设置错误
#define KGestureSettingErrorCode 161301

//手势密码设置
@interface KSGestureSettingVC : KSNVBaseVC

//来源
@property (nonatomic, assign) GestureFromType fromType;
//设置结束block
@property (nonatomic, copy) void(^gestureSettingFinishBlock)(UIViewController *vc, NSInteger actionType, NSError *error);
@end
