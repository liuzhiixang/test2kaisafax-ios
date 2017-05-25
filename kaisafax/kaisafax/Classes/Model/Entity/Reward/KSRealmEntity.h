//
//  KSRealmEntity.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  不知道是啥玩意儿，反正很多接口报文在用，所以提取公共
 */
@interface KSRealmEntity : KSBaseEntity
@property (nonatomic, copy) NSString *realm;
@property (nonatomic, copy) NSString *objectId;
@end
