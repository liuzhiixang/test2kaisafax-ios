//
//  KSRewardItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSRedPackageEntity.h"
#import "KSRealmEntity.h"


/**
 *  @author semny
 *
 *  奖励信息(单条，红包)
 */
@interface KSRewardItemEntity : KSBaseEntity

//生效时间
@property (nonatomic, assign) NSDate * invokedTime;
//红包状态
@property (nonatomic, assign) NSInteger status;
//实际奖励奖金 红包的实际金额 可能存在扣税
@property (nonatomic, assign) NSString * actualBonus;

//提取时间
@property (nonatomic, strong) NSDate *consumedTime;
//奖券ID(序列号)
@property (nonatomic, assign) long rId;
//到账时间
@property (nonatomic, strong) NSDate *withdrawTime;

//激活日期
@property (nonatomic, strong) NSDate *allocatedTime;
//过期日期
@property (nonatomic, strong) NSDate *expiredTime;
//原始奖励金额 红包的原始金额
@property (nonatomic, assign) CGFloat originalBonus;
//事件类型 1:立投即送，2:单笔投资满送
@property (nonatomic, assign) NSInteger eventType;

//@property (nonatomic, copy) NSString *packId;
//@property (nonatomic, copy) NSString *parentId;
//@property (nonatomic, copy) NSString *owner_realm;
//@property (nonatomic, copy) NSString *owner_objectId;
/*
@property (nonatomic, strong) KSRealmEntity *owner;
@property (nonatomic, strong) KSRealmEntity *target;
@property (nonatomic, strong) KSRealmEntity *creator;
*/
//红包信息
@property (nonatomic, strong) KSRedPackageEntity *pack;
//红包target
@property (nonatomic, strong)KSRealmEntity *target;

@end
