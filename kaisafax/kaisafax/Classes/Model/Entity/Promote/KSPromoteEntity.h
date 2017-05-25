//
//  KSPromoteEntity.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSShareEntity.h"
#import "KSUserBaseEntity.h"

/**
 *  @author semny
 *
 *  推广信息数据
 */
@interface KSPromoteEntity : KSBaseEntity




//已结算推广收益
@property (nonatomic, copy)NSString* payedCommission;
//结算中推广收益
@property (nonatomic ,copy) NSString *inItCommission;
//累积推广收益
@property (nonatomic, copy) NSString* totalCommission;

//NORMAL("正常"),DELETED("被删除"),USED("启用"),UNUSED("不启用"); 如果没有就是false
@property (nonatomic, assign)NSInteger status;

//统一的分享信息
@property (nonatomic, strong) KSShareEntity *shareInfo;

@end
