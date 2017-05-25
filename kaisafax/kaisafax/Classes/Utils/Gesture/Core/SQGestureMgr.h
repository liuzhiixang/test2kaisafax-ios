//
//  SQGestureMgr.h
//  kaisafax
//
//  Created by semny on 16/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

//手势类型
typedef NS_ENUM(NSInteger, GestureType)
{
    GestureTypeUnknown = 0, //未知geture类型，无需验证或者设置
    GestureTypeSetting = 1, //设置
    GestureTypeLogin = 2    //校验
};

/**
 *  手势密码界面用途类型
 */
typedef enum
{
    GestureFromTypeInUserCenter = 1, // 设置手势密码
    GestureFromTypeInStart, // 登陆手势密码
}GestureFromType;

/**
 *  手势密码操作类型
 */
typedef enum
{
    GestureActionTypeReturn = 1, // 返回
    GestureActionTypeJump, // 跳过
    GestureActionTypeCompleted, // 操作完成(设置/验证)
}GestureActionType;

@interface SQGestureMgr : NSObject

/**
 *  @author semny
 *
 *  初始化手势管理工具
 *
 *  @return 手势管理工具单例对象
 */
+ (SQGestureMgr *)sharedInstance;

//判断是否支持手势密码及密码类型
+ (GestureType)checkAuthenticationTypeByGestureAndLogin;

//校验手势密码是否和设置的一致
+ (BOOL)checkInputGestureForDefaultAccount:(NSString *)gesture;

//设置默认账户下的手势密码
+ (void)setGestureForDefaultAccount:(NSString *)gesture;

//删除默认模式下的手势密码
+ (BOOL)deleteGestureForDefaultAccount;

//删除默认模式下的手势密码
+ (NSString *)getGestureForDefaultAccount;

//存储跳过的标志
+ (void)setIsGestureJumpedForDefaultAccount:(BOOL)isJumped;

//存储设置过的标志
//+ (void)setIsGestureSettedForDefaultAccount:(BOOL)isSetted;
@end
