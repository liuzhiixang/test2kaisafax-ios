//
//  KSPNRAccountEntity.h
//  kaisafax
//
//  Created by semny on 17/5/8.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  第三方账户信息
 */
@interface KSPNRAccountEntity : KSBaseEntity

//第三方用户id
@property (nonatomic, copy) NSString *pnrUsrId;

@end
