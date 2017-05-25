//
//  KSJDGetPwdListEntity.h
//  kaisafax
//
//  Created by mac on 17/3/24.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "KSJDExtractItemEntity.h"
#import "KSBaseEntity.h"

@interface KSJDGetPwdListEntity : KSBaseEntity

//京东卡制卡记录表
@property (nonatomic, copy) NSMutableArray<KSJDExtractItemEntity*> *data;


@end
