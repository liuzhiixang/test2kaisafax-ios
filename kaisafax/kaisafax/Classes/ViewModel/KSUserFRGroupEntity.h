//
//  KSUserFRGroupEntity.h
//  kaisafax
//
//  Created by semny on 16/9/8.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @author semny
 *
 *  用户资金记录的分类处理列表
 */
@interface KSUserFRGroupEntity : NSObject

//分类日期string(格式yyyy/MM/dd)
@property (nonatomic, copy) NSString *sectionDateTitle;

//分类日期
@property (nonatomic, strong) NSDate *sectionDate;

//分类日期月份
@property (nonatomic, assign) NSUInteger sectionMonth;
//分类日期年份
@property (nonatomic, assign) NSUInteger sectionYear;
//分类日期天
@property (nonatomic, assign) NSUInteger sectionDay;

//数据列表
@property (nonatomic, strong) NSMutableArray *dataList;

@end
