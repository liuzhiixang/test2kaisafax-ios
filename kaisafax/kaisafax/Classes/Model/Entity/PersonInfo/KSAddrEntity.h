//
//  KSAddrEntity.h
//  kaisafax
//
//  Created by BeiYu on 2016/11/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@interface KSAddrEntity : KSBaseEntity
/**
 *省级编码
 */
@property (nonatomic,copy) NSString *provinceCode;
/**
 *省级名称
 */
@property (nonatomic,copy) NSString *provinceName;
/**
 *市级编码
 */
@property (nonatomic,copy) NSString *cityCode;
/**
 *市级名称
 */
@property (nonatomic,copy) NSString *cityName;
/**
 *县区级编码
 */
//@property (nonatomic,copy) NSString *countyCode;
/**
 *县区名称
 */
//@property (nonatomic,copy) NSString *countyName;
/**
 *邮编
 */
@property (nonatomic,copy) NSString *zipCode;
/**
 *收货人
 */
@property (nonatomic,copy) NSString *receiverName;
/**
 *联系人
 */
@property (nonatomic,copy) NSString *receiverMobile;
/**
 *详细地址
 */
@property (nonatomic,copy) NSString *address;

@end
