//
//  KSUserFRItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSRealmEntity.h"

/**
 *  @author semny
 *
 *  用户交易记录单条数据
 */
@interface KSUserFRItemEntity : KSBaseEntity
//交易金额
@property (nonatomic, assign) CGFloat amount;
//交易状态(资金处理状态)I("初始"),P("处理中"),A("审核中"),等
@property (nonatomic, assign) NSInteger status;
//资金操作类型 FREEZE("冻结"),UNFREEZE("解冻"),IN("转入"),OUT("转出");等
@property (nonatomic, assign) NSInteger type;
//交易时间
@property (nonatomic, strong) NSDate *recordTime;
//是否入账
@property (nonatomic, assign, getter=isIn) BOOL in;


//@property (nonatomic, copy) NSString *frId;
//@property (nonatomic, copy) NSString *userId;
//
////操作类型 FREEZE("冻结"), UNFREEZE("解冻"),IN("转入"),OUT("转出");
//@property (nonatomic, copy) NSString *operation;
//
////订单(交易)编号
//@property (nonatomic, copy) NSString *orderId;
////第三方交易编号
//@property (nonatomic, copy) NSString *transId;
//
//
//@property (nonatomic, copy) NSString *frDescription;
//@property (nonatomic, copy) NSString *priv;
////是否为迁移数据
//@property (nonatomic, assign) BOOL legacy;
////更新
//@property (nonatomic, copy) NSString *updateBy;
////操作来源(ios,android,h5)
//@property (nonatomic, copy) NSString *operaSource;
////做什么的
////@property (nonatomic, copy) NSString *object_realm;
//////记录id
////@property (nonatomic, copy) NSString *objectId;
//@property (nonatomic, strong) KSRealmEntity *object;

@end
