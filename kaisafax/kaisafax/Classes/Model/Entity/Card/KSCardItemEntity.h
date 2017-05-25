//
//  KSCardItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  银行卡信息(单条)
 */
@interface KSCardItemEntity : KSBaseEntity
//@property (nonatomic, copy) NSString *userId;
////银行代码
//@property (nonatomic, copy) NSString *bank;
//@property (nonatomic, strong) NSDate *recordTime;


//唯一标志号 银行卡ID
@property (nonatomic, assign) long long cardId;
//是否有效 true-是，false-否
@property (nonatomic, assign) BOOL valid;
//默认账户标志
@property (nonatomic, assign) BOOL defaultAccount;
//银行icon
@property (nonatomic, copy) NSString *bankIconUrl;
//持卡人姓名
@property (nonatomic, copy) NSString *name;
//银行卡号
@property (nonatomic, copy) NSString *account;
//银行名称
@property (nonatomic, copy) NSString *bankName;
//银行代码
@property (nonatomic, copy) NSString *bankCode;
//是否为快捷卡
@property (nonatomic, assign) BOOL express;

//id: <long>,//
//valid: <boolean>,//是否有效 true-是，false-否
//defaultAccount: <boolean>,//是否为默认银行  true-是，false-否
//bankIconUrl: <String>,//用于H5显示
//name: <String>,//持卡人名称
//account: <String>,//银行卡号
//bankName: <String>,//银行名称
//bankCode: <String>,//银行代码
//express: <boolean>//是否为快捷卡 true-是，false-否

- (NSString *)formatAccount;

@end
