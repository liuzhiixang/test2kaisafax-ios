//
//  KSInvestDetailVC.h
//  kaisafax
//
//  Created by Jjyo on 16/7/18.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"
@class KSLoanItemEntity,KSNewbeeEntity;
@interface KSInvestDetailVC : KSNVBackVC

@property (nonatomic, strong) KSLoanItemEntity *entity;
@property (nonatomic, strong) KSNewbeeEntity *nbEntity;

@end
