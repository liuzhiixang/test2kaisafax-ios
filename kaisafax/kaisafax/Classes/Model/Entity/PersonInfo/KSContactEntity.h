//
//  KSContactEntity.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@interface KSContactEntity : KSBaseEntity
/**
 *联系手机号
 */
@property (nonatomic,copy) NSString *mobile;
/**
 *联系手机号(转换)
 */
//@property (nonatomic,copy) NSString *contactMobileConvert;
/**
 *联系人
 */
@property (nonatomic,copy) NSString *name;
/**
 *关系
 */
@property (nonatomic,assign) NSInteger relation;

@end
