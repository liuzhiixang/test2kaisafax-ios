//
//  KSAreaEntity.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@class KSCityEntity;
@interface KSAreaEntity : KSBaseEntity
@property (strong, nonatomic) NSArray <KSCityEntity*> *sonAreaList;
@property (nonatomic,copy) NSString *typeName;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *name;

- (NSDictionary *)properties_aps;

@end
