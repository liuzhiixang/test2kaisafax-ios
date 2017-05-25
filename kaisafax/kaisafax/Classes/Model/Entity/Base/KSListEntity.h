//
//  KSListEntity.h
//  kaisafax
//
//  Created by semny on 16/9/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@interface KSListEntity : KSBaseEntity

//是否下拉刷新    YES-下拉刷新，NO-上拉加载更多
@property (nonatomic, assign) BOOL          isRefresh;
//总数
@property (nonatomic, assign) NSInteger     totalCount;
//列表锚点
@property (nonatomic, assign) NSInteger     pageIndex;

//总数
@property (nonatomic, assign) NSInteger     recordsFiltered;
//列表锚点
@property (nonatomic, assign) NSInteger     recordsTotal;


//数据列表
@property (nonatomic, copy) NSMutableArray     *dataList;

/**
 *  @author semny
 *
 *  增加新数据(必须在设置isRefresh之后)
 *
 *  @param array 新数据
 */
- (void)appendDataList:(NSArray *)array;

@end
