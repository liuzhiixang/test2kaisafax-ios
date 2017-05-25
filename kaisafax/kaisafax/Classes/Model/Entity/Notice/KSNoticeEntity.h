//
//  KSNoticeEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSNoticeItemEntity.h"

/**
 *  @author semny
 *
 *  首页公告数据
 */
@interface KSNoticeEntity : KSBaseEntity
//更多公告链接地址  
//@property (nonatomic, copy) NSString *more;

@property (nonatomic, strong) NSArray<KSNoticeItemEntity*> *noticeList;

@end
