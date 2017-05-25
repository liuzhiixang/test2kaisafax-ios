//
//  KSJDExtractListEntity.h
//  kaisafax
//
//  Created by semny on 17/3/23.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSJDExtractItemEntity.h"

@interface KSJDExtractListEntity : KSBaseEntity

//账户余额
@property (nonatomic, strong) NSString *jdAccount;

//总条目数
@property (nonatomic, assign) NSInteger total;

//页码
@property (nonatomic, assign) NSInteger pageNum;

//页面条数
@property (nonatomic, assign) NSInteger pageSize;

//京东卡制卡记录表
@property (nonatomic, copy) NSMutableArray<KSJDExtractItemEntity*> *list;

@end
