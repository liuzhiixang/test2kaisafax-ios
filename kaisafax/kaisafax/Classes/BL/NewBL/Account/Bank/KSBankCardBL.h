//
//  KSBankCardBL.h
//  kaisafax
//
//  Created by semny on 16/9/21.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSBankCardBL : KSRequestBL

/**
 *  @author semny
 *
 *  解绑银行卡
 *
 *  @param cardId 银行卡id
 *
 *  @return 请求序列号
 */
- (NSInteger)doUnbindBankCard:(long long)cardId;

/**
 *  @author semny
 *
 *  获取当前用户的银行卡信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserBankCards;

//同步银行卡信息(由于服务端暂时无法自动同步汇付的银行信息)
- (NSInteger)doSyncBankCard;

@end
