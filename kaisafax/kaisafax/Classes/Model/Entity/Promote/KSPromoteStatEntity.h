//
//  KSPromoteStatEntity.h
//  kaisafax
//
//  Created by semny on 16/8/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  推荐统计
 */
@interface KSPromoteStatEntity : KSBaseEntity

@property (nonatomic, assign) NSInteger r1;
@property (nonatomic, assign) NSInteger r2;

//直接推荐开户人数
@property (nonatomic, assign) NSInteger r1o;

//二代推荐开户人数
@property (nonatomic, assign) NSInteger r2o;


//直接推荐投资人数
@property (nonatomic, assign) NSInteger r1i;

//二代推荐投资人数
@property (nonatomic, assign) NSInteger r2i;

//直接推荐投资收益
@property (nonatomic, copy) NSString* r1ci;

//二代推荐投资收益
@property (nonatomic, copy) NSString* r2ci;


@end
