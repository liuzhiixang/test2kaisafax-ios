//
//  KSUserInfoEntity.h
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSUserBaseEntity.h"
#import "KSPNRAccountEntity.h"

@interface KSUserInfoEntity : KSBaseEntity

//会话id
@property (copy, nonatomic) NSString *sessionId;

//用户基本信息
@property (nonatomic, strong) KSUserBaseEntity *user;

//第三方账户信息(汇付)
@property (nonatomic, strong) KSPNRAccountEntity *chinaPnrAccount;
@end
