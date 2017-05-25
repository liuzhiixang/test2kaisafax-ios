//
//  KSInviteUserEntity.h
//  kaisafax
//
//  Created by semny on 16/8/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSUserBaseEntity.h"

/**
 *  @author semny
 *
 *  推荐人数据
 */
@interface KSInviteUserEntity : KSBaseEntity

@property (nonatomic, strong) KSUserBaseEntity *user;

//是否已投资
@property (nonatomic, assign) BOOL isFirstInvest;
//是否开户
@property (nonatomic, assign) BOOL isOpenAccount;


//首次投标金额
/*@property (nonatomic, assign) CGFloat firstInvest;
//是否可投体验标
@property (nonatomic, assign) BOOL testLoan;

//推荐奖励金额
@property (nonatomic, assign) CGFloat inviteBonus;
*/
//投资状态
- (NSString *)getInvestStatus;

@end
