//
//  KSRechargeEntity.h
//  kaisafax
//
//  Created by semny on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSBankEntity.h"
#import "KSCardItemEntity.h"
//#import "KSThirdPartyEntity.h"

/**
 *  @author semny
 *
 *  充值页面数据
 */
@interface KSRechargeEntity : KSBaseEntity
//app标志
//@property (nonatomic, copy) NSString *app;
//银行通道是可用
@property (nonatomic, assign) BOOL isAble;
//银行信息
@property (nonatomic, strong) KSBankEntity *bank;
//快捷卡信息
@property (nonatomic, strong) KSCardItemEntity *expressCard;
//可用余额
@property (nonatomic, copy) NSString *available;
//账户信息(汇付)
//@property (nonatomic, strong) KSThirdPartyEntity *account;
//@property (nonatomic, copy) NSString *loanId;

//开通无卡支付帮助链接
@property (nonatomic, copy) NSString *OPEN_NOCARD_PAY_GUIDE_URL;
//开通无卡支付链接
@property (nonatomic, copy) NSString *OPEN_NOCARD_PAY_URL;
//解绑快捷卡链接
@property (nonatomic, copy) NSString *UNBIND_QUICK_CARD_URL;

@end
