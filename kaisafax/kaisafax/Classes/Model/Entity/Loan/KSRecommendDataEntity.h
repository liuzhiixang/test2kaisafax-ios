//
//  KSRecommendDataEntity.h
//  kaisafax
//
//  Created by yubei on 2017/4/25.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@class KSLoanItemEntity,KSDurationEntity;

@interface KSRecommendDataEntity : KSBaseEntity
@property (nonatomic, strong) NSArray <KSLoanItemEntity*> *recommendList;
//@property (nonatomic, strong) KSDurationEntity *duration;
@end
