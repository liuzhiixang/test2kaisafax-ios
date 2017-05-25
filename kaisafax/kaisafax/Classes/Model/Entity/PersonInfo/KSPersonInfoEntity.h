//
//  KSPersonInfoEntity.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
@class KSAddrEntity,KSContactEntity;
@interface KSPersonInfoEntity : KSBaseEntity
/**
 *注册时间
 */
@property (nonatomic,strong) NSDate *registerTime;
/**
 *用户名称
 */
@property (nonatomic,copy) NSString *userName;
/**
 *等级百分比
 */
@property (nonatomic,assign) NSInteger percent;
/**
 *等级名称
 */
@property (nonatomic,copy) NSString *level;
/**
 *邮箱
 */
//@property (nonatomic,copy) NSString *email;
/**
 *转化后的邮箱
 */
@property (nonatomic,copy) NSString *email;
/**
 *手机号
 */
//@property (nonatomic,copy) NSString *mobile;
/**
 *转化后的邮箱
 */
@property (nonatomic,copy) NSString *mobileConvert;
/**
 *身份证
 */
//@property (nonatomic,copy) NSString *idNumber;
/**
 *转化后的身份证
 */
@property (nonatomic,copy) NSString *idNumberConvert;
/**
 *地址
 */
@property (nonatomic,strong) KSAddrEntity *addrData;
/**
 *联系人信息
 */
@property (nonatomic,strong) KSContactEntity *contactData;
/**
 *用户类型
 */
@property (nonatomic,assign) NSInteger userType;
/**
 *业主认证地址
 */
@property (nonatomic,copy) NSString *ownerVerityUrl;
/**
 *业主地址信息
 */
@property (nonatomic,copy) NSString *ownerAddress;
/**
 *汇付usrid
 */
@property (nonatomic,copy) NSString *pnrUsrId;
@end
