//
//  KSWithdrawEntity.h
//  kaisafax
//
//  Created by semny on 16/8/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSBankEntity.h"
#import "KSCardItemEntity.h"
#import "KSWithdrawTypeEntity.h"


@interface KSWithdrawEntity : KSBaseEntity
//银行卡是否支持加急提现
@property (nonatomic, assign) BOOL isImmediate;
//是否绑卡
@property (nonatomic, assign) BOOL isHasBankCard;
//银行信息
@property (nonatomic, strong) KSBankEntity *bank;
//可用余额
@property (nonatomic, copy) NSString *available;
//取现方式返回数据列表
@property (nonatomic, strong) NSArray<KSWithdrawTypeEntity *> *typeList;
//默认银行卡信息
@property (nonatomic, strong) KSCardItemEntity *bankCard;





@end
/**
 {
 "hasBankcards": true,
 "bank": {
 "id": "CCB",
 "name": "建设银行",
 "amount": 50000,
 "total": 100000,
 "type": 0,
 "status": 0,
 "sortNo": 1,
 "bankIconUrl": "http://192.168.188.98:8888/images/appBanks/ic_bank_logo_ccb.png"
 },
 "bankCard": {
 "id": "06a2e698-4e63-44e7-aff6-25c78e37921b",
 "userId": "4caf2b17-36da-485e-b2bf-707816e79f4b",
 "account": "6210********3333",
 "defaultAccount": true,
 "name": "志**",
 "bank": "CCB",
 "valid": true,
 "express": true,
 "recordTime": 1471591653000,
 "bankIconUrl": "http://192.168.188.98:8888/images/appBanks/ic_bank_logo_ccb.png",
 "bankName": "建设银行"
 },
 "typeList": [
 {
 "type": "common",
 "paymentDate": "T+1个工作日",
 "withdrawFee": "2",
 "freeWithdrawTimes": 0
 }
 ],
 "isImmediate": false,
 "withdrawTimes": 39,
 "available": 81007738.79
 }
*/
