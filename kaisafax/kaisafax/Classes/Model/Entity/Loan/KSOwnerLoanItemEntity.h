//
//  KSOwnerLoanItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSLoanItemEntity.h"

/**
 *  物业宝标的信息(单条)
 */
@interface KSOwnerLoanItemEntity : KSBaseEntity

@property (nonatomic, copy) NSString *url;
//标的基本信息
@property (nonatomic, strong) KSLoanItemEntity *loan;
/*
 免物业费期限 期限的算法见接口(仅仅用于物业宝)
 */
@property (nonatomic, strong) KSDurationEntity *freeDuration;


- (NSString *)getFreeText;

@end
