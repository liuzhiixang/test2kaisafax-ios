//
//  KSNewAssetsEntity.h
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSNewFundEntity.h"
//#import "KSUserBaseEntity.h"
//#import "KSThirdPartyEntity.h"

//风险评估等级类型
//风险评估等级 0: '未评估',1: '保守型',2: '稳健型',3: '平衡型',4: '积极型',5: '激进型'
typedef NS_ENUM(NSUInteger, KSRiskAssessLevel)
{
    KSRiskAssessLevelUnAssess = 0,      //未评估
    KSRiskAssessLevelConservative,      //保守型
    KSRiskAssessLevelRobust,            //稳健型
    KSRiskAssessLevelBalanced,          //平衡型
    KSRiskAssessLevelActive,          //积极型
    KSRiskAssessLevelRadical,          //激进型
};

@interface KSNewAssetsEntity : KSBaseEntity

//银行卡数量
@property (assign, nonatomic) NSInteger bankCards;
//是否开通汇付账户
@property (assign, nonatomic) BOOL isOpenAccount;
//资金
@property (strong, nonatomic) KSNewFundEntity *fund;

//用户信息
//@property (strong, nonatomic) KSUserBaseEntity *user;

//第三方账户信息(汇付)
//@property (nonatomic, strong) KSThirdPartyEntity *account;

//待回款笔数
@property (assign, nonatomic) NSInteger undueInvestCount;

//待激活红包个数
@property (assign, nonatomic) NSInteger ticketsCount;

//总资产
@property (nonatomic, copy) NSString *totalAsset;

//总资产(格式化)
@property (nonatomic, copy) NSString *totalAssetFormat;

//风险评估等级 0: '未评估',1: '保守型',2: '稳健型',3: '平衡型',4: '积极型',5: '激进型'
@property (assign, nonatomic) NSInteger riskAssessLevel;

/**
 *  如果等于null,显示开通托管账户，否则显示交易记录
 *
 *  @return YES 未开通托管账户
 */
//- (BOOL)isAccountNull;

@end
