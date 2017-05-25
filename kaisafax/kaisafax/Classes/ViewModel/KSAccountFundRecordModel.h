//
//  KSAccountFundRecordModel.h
//  kaisafax
//
//  Created by BeiYu on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSUserFRItemEntity;

@interface KSAccountFundRecordModel : NSObject

/**
是否显示date
 */
@property (nonatomic,assign) BOOL isShowDate;
/**
 资金数据模型
 */
@property (nonatomic,strong) KSUserFRItemEntity *data;

@end
