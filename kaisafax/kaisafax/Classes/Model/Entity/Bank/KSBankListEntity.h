//
//  KSBankListEntity.h
//  kaisafax
//
//  Created by semny on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSBankEntity.h"

@interface KSBankListEntity : KSBaseEntity
//开通无卡支付帮助链接
@property (nonatomic, copy) NSString *OPEN_NOCARD_PAY_GUIDE_URL;
//开通无卡支付链接
@property (nonatomic, copy) NSString *OPEN_NOCARD_PAY_URL;
//解绑快捷卡链接
//@property (nonatomic, copy) NSString *UNBIND_QUICK_CARD_URL;
//银行信息列表 KSBankEntity
@property (nonatomic, strong) NSArray<KSBankEntity *> *bankList;

@end
