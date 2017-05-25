//
//  KSRechargeFastVC.h
//  kaisafax
//
//  Created by Jjyo on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

//#import "KSRechargeVC.h"
#import "KSBankBL.h"
#import "KSNVBackVC.h"

@interface KSRechargeFastVC : KSNVBackVC


@property (nonatomic, copy) NSString *available;
@property (nonatomic, copy) NSString *rechargeNumber;
@property (nonatomic, assign) KSBankListType type;
@property (nonatomic,assign) NSInteger resultType;
//差额，普通充值
@property (nonatomic, assign) NSInteger actionFlag;
@end
