//
//  KSJDProvideRecord.h
//  kaisafax
//
//  Created by liuzhixiang on 2017/5/2.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@interface KSJDRecordItemEntity : KSBaseEntity

//发放记录Id
@property (nonatomic, assign) long long ID;

//用户Id
@property (nonatomic, assign) long long userId;

//发放金额
@property (nonatomic, copy) NSString *amount;

//外部备注
@property (nonatomic, copy) NSString *remarkOut;

//用户手机号
@property (nonatomic, copy) NSString *mobile;

//发放时间
@property (nonatomic, strong) NSDate *createTime;

@end
