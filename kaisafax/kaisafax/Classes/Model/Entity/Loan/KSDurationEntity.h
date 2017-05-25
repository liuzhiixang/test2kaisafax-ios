//
//  KSDurationENtity.h
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
typedef NS_ENUM(NSInteger,KSUnitType)
{
    KSUnitYear = 1,
    KSUnitMonth,
    KSUnitDay
};

@interface KSDurationEntity : KSBaseEntity
//期限数据
@property (nonatomic, assign) NSInteger value;
//单位类型 1:年 2:月 3:天
@property (nonatomic, assign) KSUnitType unitType;

@end
