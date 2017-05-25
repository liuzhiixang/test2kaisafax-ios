//
//  KSBankEntity.h
//  kaisafax
//
//  Created by semny on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
/**
 *  @author semny
 *
 *  银行信息model
 */
@interface KSBankEntity : KSBaseEntity

//@property (nonatomic, copy) NSString *bankId;
//每日限额
@property (nonatomic, assign) NSInteger total;
//每笔限额
@property (nonatomic, assign) NSInteger amount;
//银行简码
@property (nonatomic, copy) NSString *code;
//用于H5显示
@property (nonatomic, copy) NSString *bankIconUrl;
//状态 0-停用,1-启用
@property (nonatomic, assign) NSInteger status;
//银行名称
@property (nonatomic, copy) NSString *name;
//排序号
@property (nonatomic, assign) NSInteger sortNo;
//0不需要开通无卡支付 /1需要开通无卡支付
@property (nonatomic, assign) NSInteger type;





- (NSString *)getDetailText;

@end
