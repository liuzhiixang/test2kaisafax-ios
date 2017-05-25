//
//  KSAdvertEntity.h
//  kaisafax
//
//  Created by yubei on 2017/5/3.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSBussinessItemEntity.h"

@interface KSAdvertEntity : KSBaseEntity
@property (nonatomic, strong) NSArray<KSBussinessItemEntity*> *businessData;

@end
