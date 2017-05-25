//
//  KSWithdrawTypeEntity.h
//  kaisafax
//
//  Created by semny on 16/9/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  取现方式返回数据列表item
 */
@interface KSWithdrawTypeEntity : KSBaseEntity

//1 快速提现 2 普通提现 3 及时详情
@property (nonatomic, assign) NSInteger type;
//普通到账时间
@property (nonatomic, copy) NSString *paymentDate;
//提现手续费
@property (nonatomic, copy) NSString *withdrawFee;
//每月免费提现手续费剩余次数（加急默认为0不做显示）
@property (nonatomic, assign) NSInteger freeWithdrawTimes;

//已提现次数
@property (nonatomic, assign) NSInteger withdrawTimes;

@end
