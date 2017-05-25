//
//  KSDueDateEntity.h
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  回款日期
 */
@interface KSDueDateEntity : KSBaseEntity
//@property (nonatomic, copy) NSString *month;
//@property (nonatomic, copy) NSString *chronology_calendarType;
//@property (nonatomic, copy) NSString *chronology_id;
//@property (nonatomic, copy) NSString *era;
//@property (nonatomic, assign) NSInteger dayOfYear;
//@property (nonatomic, copy) NSString *dayOfWeek;
//@property (nonatomic, assign) BOOL leapYear;
//还款日期，年
@property (nonatomic, assign) NSInteger year;
//还款日期 日
@property (nonatomic, assign) NSInteger dayOfMonth;
//还款日期 月
@property (nonatomic, assign) NSInteger monthValue;

@end
