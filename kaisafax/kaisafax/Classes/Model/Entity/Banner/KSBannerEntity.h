//
//  KSBannerEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBusinessEntity.h"

/**
 *  @author semny
 *
 *  首页广告轮播数据
 */
@interface KSBannerEntity : KSBaseEntity

//@property (nonatomic, assign) NSInteger recordsFiltered;
//@property (nonatomic, assign) NSInteger recordsTotal;
////array KSBussinessItemEntity
//@property (nonatomic, strong) NSArray *businessData;
@property (nonatomic, strong) NSArray<KSBussinessItemEntity*> *bannerList;

@end
