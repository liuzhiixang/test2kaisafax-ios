//
//  KSJDExtractInfoEntity.h
//  kaisafax
//
//  Created by semny on 17/3/23.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

//领卡记录信息(单条)
@interface KSJDExtractItemEntity : KSBaseEntity
//发放记录Id
@property (nonatomic, assign) long long ID;

//用户Id
@property (nonatomic, assign) long long userId;

//发放金额
@property (nonatomic, copy) NSString *amount;

//状态(0:制卡中|1:成功|2:失败)
@property (nonatomic, assign) NSInteger status;

//卡号
@property (nonatomic, copy) NSString *cardNum;
//卡密
@property (nonatomic, copy) NSString *cardPwd;

//外部备注
@property (nonatomic, copy) NSString *remarkOut;

//用户手机号
@property (nonatomic, copy) NSString *mobile;

//发放时间
@property (nonatomic, strong) NSDate *createTime;

@end
