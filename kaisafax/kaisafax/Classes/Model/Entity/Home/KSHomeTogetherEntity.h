//
//  KSHomeTogetherEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSNoticeEntity.h"
#import "KSBusinessEntity.h"
#import "KSBannerEntity.h"

@interface KSHomeTogetherEntity : KSBaseEntity

//公告
@property (nonatomic, strong) KSNoticeEntity *noticeModel;
//广告图
@property (nonatomic, strong) KSBusinessEntity *businessModel;
//轮播图
@property (nonatomic, strong) KSBannerEntity *bannerModel;

@end
