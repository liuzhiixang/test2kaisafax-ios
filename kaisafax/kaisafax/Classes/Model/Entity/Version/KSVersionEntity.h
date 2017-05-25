//
//  KSVersionEntity.h
//  kaisafax
//
//  Created by semny on 16/8/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@interface KSVersionEntity : KSBaseEntity

//标题
@property (nonatomic, copy) NSString *title;
//版本更新描述
@property (nonatomic, copy) NSString *desc;
//版本数字编号
@property (nonatomic, copy) NSString * ver;
//更新地址
@property (nonatomic, copy) NSString *url;
//版本名称
@property (nonatomic, copy) NSString *verDes;
//是否强制升级
@property (nonatomic, assign) BOOL must;

@end
