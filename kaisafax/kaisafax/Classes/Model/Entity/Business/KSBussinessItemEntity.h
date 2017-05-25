//
//  KSBussinessItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@class KSShareEntity;
@interface KSBussinessItemEntity : KSBaseEntity
//分享状态: false 否，true 是
@property (nonatomic, assign) BOOL shareStatus;
//图片地址
@property (nonatomic, copy) NSString *imageUrl;
//H5跳转链接地址
@property (nonatomic, copy) NSString *url;
//广告文章ID
@property (nonatomic, assign) long long ID;
//广告文章标题
@property (nonatomic, copy) NSString *title;
//分享相关模型
@property (nonatomic, strong) KSShareEntity *shareInfo;
//广告开始的时间
@property (nonatomic, strong) NSDate *startTime;
//广告结束的时间
@property (nonatomic, strong) NSDate *endTime;
//广告更新的时间
@property (nonatomic, strong) NSDate *updateTime;
//banner是否要在未进入h5就拉登陆页
@property (nonatomic, assign) BOOL needToLogin;
@end
