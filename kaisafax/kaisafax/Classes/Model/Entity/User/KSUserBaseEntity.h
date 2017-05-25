//
//  KSUserBaseEntity.h
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSRealmEntity.h"

//理财师级别
typedef NS_ENUM(NSInteger,KSFinancialAdvisorGrade)
{
    KSFinancialAdvisorGrade0 = 0,      //黑名单
    KSFinancialAdvisorGrade1 = 1,      //理财师
    KSFinancialAdvisorGrade2 = 2,      //高级理财师
    KSFinancialAdvisorGrade3 = 3,      //签约理财师
    KSFinancialAdvisorGrade4 = 4,      //资深理财师
};

//用户类型
typedef NS_ENUM(NSInteger,KSUserType)
{
    KSUserTypeNormal = 1,      //普通用户
    KSUserTypeOwner,            //业主用户
    KSUserTypeStaff,            //员工
    KSUserTypeStaffAndOwner,      //员工&业主
};

//用户投资状态
typedef NS_ENUM(NSInteger,KSUserStatus)
{
    KSUserStatusUnInvest = 0,      //未投资用户
    KSUserStatusInvestedOther,     //投资了非新手标
};

/**
 *  @author semny
 *
 *  用户基本信息实体(不包含imei)
 */
@interface KSUserBaseEntity : KSBaseEntity

//用户id字符串
//@property (copy, nonatomic) NSString *userIdStr;
//用户ID
@property (assign, nonatomic) long long userId;
//登录名
@property (copy, nonatomic) NSString *loginName;

//身份证名称 用户名称
@property (copy, nonatomic) NSString *name;

//推荐码
@property (copy, nonatomic) NSString *refCode;

//推荐级别
//**枚举** 理财等级 ZERO(0, "黑名单"), ONE(1, "理财师"),TWO(2, "高级理财师"),THREE(3, "签约理财师"),FOUR(4, "资深理财师");
@property (assign, nonatomic) NSInteger refGrade;
@property (copy, nonatomic) NSString *refGradeStr;

//用户类型
//**枚举** 用户类型  1:"普通用户",2:"业主用户",3:"员工用户",4:"员工&业主"
@property (assign, nonatomic) NSInteger type;
@property (copy, nonatomic) NSString *typeStr;

//状态
//**枚举** 状态 0-未投资用户，1-投资了非新手标用户
@property (assign, nonatomic) NSInteger status;
@property (copy, nonatomic) NSString *statusStr;

//注册来源
@property (copy, nonatomic) NSString *regSource;

//注册时间
@property (strong, nonatomic) NSDate *registerTime;

//显示名称，服务端已经处理
@property (copy, nonatomic) NSString *showName;

/***
//最近登录时间
@property (strong, nonatomic) NSDate *lastLoginTime;

//密码过期(暂时为默认值NO)
@property (assign, nonatomic) BOOL passwordExpired;

////账号是否有效(暂时为默认值YES)
//@property (assign, nonatomic) BOOL enabled;

//身份证号
@property (copy, nonatomic) NSString *idNumber;
//手机号
@property (copy, nonatomic) NSString *mobile;
//邮箱
@property (copy, nonatomic) NSString *email;

//是否为企业用户
@property (assign, nonatomic) BOOL enterprise;

//是否为旧数据/迁移数据
@property (assign, nonatomic) BOOL legacy;

//推荐人
//@property (copy, nonatomic) NSString *referee_objectId;
//@property (copy, nonatomic) NSString *referee_realm;
@property (strong, nonatomic) KSRealmEntity *referee;

//员工组织代码
@property (copy, nonatomic) NSString *orgCode;

//业主组织代码
@property (copy, nonatomic) NSString *ownerCode;
//业务人员组织代码
@property (copy, nonatomic) NSString *busiCode;
//理财经理
@property (copy, nonatomic) NSString *financialManager;
//电销人员
@property (copy, nonatomic) NSString *electricPin;
//业务关系建立时间
@property (copy, nonatomic) NSString *lastUpdateBusRelConTimeStr;
//业务员标志
@property (assign, nonatomic) BOOL busi;
//职员标志
@property (assign, nonatomic) BOOL staff;
//业主标志
@property (assign, nonatomic) BOOL owner;
*/

/**
 *  @author semny
 *
 *  根据UserId初始化用户对象
 *
 *  @param userID 用户id
 *
 *  @return 用户对象
 */
//- (instancetype)initWithUserID:(NSInteger)userID;
- (instancetype)initWithUserId:(long long)userId;

#pragma mark -----格式化后的字符串----------

//格式化后的登录名称
-(NSString *)getFormateLoginName;
//格式化后的姓名
-(NSString *)getFormateName;
//格式化后的手机号
-(NSString *)getFormateMobile;

#pragma mark -
//- (UIImage *)getGradeIcon;

//- (NSString *)getNameText;

//用户级别的icon图片文件名
- (NSString *)getGradeIconName;

//获取用户的级别显示名称
//- (NSString *)getGradeText;

//获取显示用的用户名(优先级从前到后 name,loginname)
//- (NSString *)getShowUserName;

//判断是否为业主
- (BOOL)isStaff;
@end
