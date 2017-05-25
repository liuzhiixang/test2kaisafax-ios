//
//  KSCityEntity.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@interface KSCityEntity : KSBaseEntity
@property (nonatomic,copy) NSString *typeName;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *name;

- (NSDictionary *)properties_aps;

@end
