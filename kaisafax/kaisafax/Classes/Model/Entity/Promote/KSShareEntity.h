//
//  KSShareEntity.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  分享数据
 */
@interface KSShareEntity : KSBaseEntity

//分享图片地址
@property (nonatomic, copy) NSString *image;

//分享标题
@property (nonatomic, copy) NSString *title;
//分享内容
@property (nonatomic, copy) NSString *content;
//分享链接地址
@property (nonatomic, copy) NSString *url;

@end
