//
//  KSUserInfoItemModel.h
//  kaisafax
//
//  Created by BeiYu on 16/7/28.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"



/**
 *  @author semny
 *
 *  个人中心用户信息图标和标题描述
 */
@interface KSUserInfoItemModel : KSBaseEntity
//图标名字
@property (nonatomic,copy) NSString *icon;
//标题文字
@property (nonatomic,copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) BOOL arrow;

@property (nonatomic, copy) NSString *action;

@end



@interface KSUserInfoSectionModel : KSBaseEntity

//列数
@property (nonatomic, assign) NSInteger colCount;

@property (nonatomic, copy) NSArray<KSUserInfoItemModel *> *rowData;

@end
