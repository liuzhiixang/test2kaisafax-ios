//
//  KSUserBaseEntity.m
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUserBaseEntity.h"

@interface KSUserBaseEntity()

//格式化后的登录名称
@property (nonatomic, copy) NSString *formateLoginName;
//格式化后的姓名
@property (nonatomic, copy) NSString *formateName;
//格式化后的手机号
@property (nonatomic, copy) NSString *formateMobile;

@end

@implementation KSUserBaseEntity
/**
 *  @author semny
 *
 *  根据UserId初始化用户对象
 *
 *  @param userID 用户id
 *
 *  @return 用户对象
 */
//- (instancetype)initWithUserID:(NSString *)userIdStr
//{
//    self = [super init];
//    if(self)
//    {
//        //用户id
//        _userIdStr = userIdStr;
//    }
//    return self;
//}

- (instancetype)initWithUserId:(long long)userId
{
    self = [super init];
    if(self)
    {
        //用户id
        _userId = userId;
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper
{
//    return @{@"userIdStr" : @"id"};
    return @{@"userId" : @"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"referee" : KSRealmEntity.class};
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *registerTime = dic[@"registerTime"];
//    NSNumber *lastLoginTime = dic[@"lastLoginTime"];
    
    //if (![registerTime isKindOfClass:[NSNumber class]] || ![lastLoginTime isKindOfClass:[NSNumber class]] || ![recordTime isKindOfClass:[NSNumber class]]) return NO;
    if(registerTime && [registerTime isKindOfClass:[NSNumber class]])
    {
        _registerTime = [KSBaseEntity dateWithIntervalTime:registerTime.longLongValue];
    }
//    if(lastLoginTime && [lastLoginTime isKindOfClass:[NSNumber class]])
//    {
//        _lastLoginTime = [KSBaseEntity dateWithIntervalTime:lastLoginTime.longLongValue];
//    }
    return YES;
}

// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
{
    //if (!_registerTime || !_lastLoginTime || !_recordTime) return NO;
    
    if(_registerTime && [_registerTime isKindOfClass:[NSDate class]])
    {
        long long registerTime = _registerTime.timeIntervalSince1970*1000;
        dic[@"registerTime"] = @(registerTime);
    }
//    if(_lastLoginTime && [_lastLoginTime isKindOfClass:[NSDate class]])
//    {
//        long long lastLoginTime = _lastLoginTime.timeIntervalSince1970*1000;
//        dic[@"lastLoginTime"] = @(lastLoginTime);
//    }
    return YES;
}

#pragma mark -------自定义字段-----------
- (void)setLoginName:(NSString *)loginName
{
    _loginName = loginName;
    //设置登录名称的格式化后的字符串
    _formateLoginName = loginName;
}

- (void)setName:(NSString *)name
{
    _name = name;
    //设置姓名的格式化后的字符串
    _formateName = name ;
}

//- (void)setMobile:(NSString *)mobile
//{
//    _mobile = mobile;
//    //设置手机号的格式化后的字符串
//    _formateMobile = mobile ;
//}

#pragma mark -----格式化后的字符串----------

//格式化后的登录名称
-(NSString *)getFormateLoginName
{
    return _formateLoginName;
}

//格式化后的姓名
-(NSString *)getFormateName
{
    return _formateName;
}

//格式化后的手机号
-(NSString *)getFormateMobile
{
    return _formateMobile;
}

#pragma mark -
- (NSString *)getGradeIconName
{
    if (_refGrade == KSFinancialAdvisorGrade2)
    {
        return @"ic_promote_high";
    }
    return @"ic_promote_normal";
}

//- (NSString *)getNameText
//{
//    if (_name.length == 0) {
//        return _loginName;
//    }
//    return _name;
//    
//    
//}


//获取用户的级别显示名称
- (NSString *)refGradeStr
{
    if (!_refGradeStr)
    {
        NSString *rGradeStr = nil;
        //ZERO(0, "黑名单"), ONE(1, "理财师"),TWO(2, "高级理财师"),THREE(3, "签约理财师"),FOUR(4, "资深理财师");
        switch (_refGrade)
        {
            case KSFinancialAdvisorGrade0:
                rGradeStr = NSLocalizedString(@"FinancialAdvisorGradeText0",@"Black");
                break;
            case KSFinancialAdvisorGrade1:
                rGradeStr = NSLocalizedString(@"FinancialAdvisorGradeText1",@"Financial Advisor");
                break;
            case KSFinancialAdvisorGrade2:
                rGradeStr = NSLocalizedString(@"FinancialAdvisorGradeText2",@"High Financial Advisor");
                break;
            case KSFinancialAdvisorGrade3:
                rGradeStr = NSLocalizedString(@"FinancialAdvisorGradeText3",@"Sign Financial Advisor");
                break;
            case KSFinancialAdvisorGrade4:
                rGradeStr = NSLocalizedString(@"FinancialAdvisorGradeText4",@"Senior Financial Advisor");
                break;
            default:
                break;
        }
        _refGradeStr = rGradeStr;
    }
    return _refGradeStr;
}

//获取显示用的用户名(优先级从前到后 name,loginname)
- (NSString *)showName
{
    //推广界面返回的直接有这个字段
    if (!_showName || _showName.length<= 0)
    {
        //    用户名
        NSString *userName = _name;
        if (!userName || userName.length <= 0)
        {
            userName = _loginName;
        }
        //    if (!userName || userName.length <= 0)
        //    {
        //        userName = _mobile;
        //    }
        _showName = userName;
    }
    return _showName;
}

//判断是否为业主
- (BOOL)isStaff
{
    NSInteger userType = _type;
    BOOL isStaff = (userType==KSUserTypeStaff || userType == KSUserTypeStaffAndOwner);
    return isStaff;
}
@end
