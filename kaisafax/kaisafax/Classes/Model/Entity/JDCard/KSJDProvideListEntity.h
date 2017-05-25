//
//  KSJDProvideListEntity.h
//  kaisafax
//
//  Created by okline.kwan on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSJDRecordItemEntity.h"

@interface KSJDProvideListEntity : KSBaseEntity

//总条目数
@property (nonatomic, assign) NSInteger total;

//页码
@property (nonatomic, assign) NSInteger pageNum;

//页面条数
@property (nonatomic, assign) NSInteger pageSize;

//京东卡制卡记录表
@property (nonatomic, copy) NSMutableArray<KSJDRecordItemEntity*> *list;


@end
