//
//  KSAreaArrayEntity.h
//  kaisafax
//
//  Created by yubei on 2017/5/3.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
@class KSAreaEntity;
@interface KSAreaArrayEntity : KSBaseEntity
@property (nonatomic, strong) NSArray<KSAreaEntity*> *result;
@end
