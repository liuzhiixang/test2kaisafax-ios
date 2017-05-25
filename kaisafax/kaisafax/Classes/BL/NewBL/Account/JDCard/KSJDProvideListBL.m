//
//  KSJDProvideListBL.m
//  kaisafax
//
//  Created by Jjyo on 2017/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDProvideListBL.h"
#import "KSJDProvideListEntity.h"

//分页数据的一页数量
#define KPageMaxCount        10
#define kPageIndexStart       1


@interface KSJDProvideListBL ()

@property (nonatomic, assign) int pageIndex;//页数(从1开始)
@property (nonatomic, copy) NSArray<KSJDRecordItemEntity *> *dataList;

@end


@implementation KSJDProvideListBL



- (void)refreshJDProvideList
{
    _pageIndex = kPageIndexStart;
    [self requestPageIndex:_pageIndex];
}

- (void)requestNextPageJDProvideList
{
    [self requestPageIndex:_pageIndex];
}


- (void)requestPageIndex:(NSInteger)index
{
    [self requestWithTradeId:KJDProvideListTradeId data:@{@"pageNum": [@(index) stringValue], @"pageSize" : [@(KPageMaxCount) stringValue]}];
}

#pragma mark - BL请求回调
- (void)succeedCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    
    NSString *tradeId = responseEntity.tradeId;
    //列表
    if ([tradeId isEqualToString:KJDProvideListTradeId])
    {
        //实体结果数据
        id body = responseEntity.body;
        KSJDProvideListEntity *entity = (KSJDProvideListEntity *)body;
        //加载更多
        if (_pageIndex > kPageIndexStart) {
            NSMutableArray *array = [NSMutableArray array];
            if (_dataList.count > 0) {
                [array addObjectsFromArray:_dataList];
            }
            if (entity.list.count > 0) {
                [array addObjectsFromArray:entity.list];
            }
            self.dataList = array;
            entity.list = array;
        }
        else{
            self.dataList = entity.list;
        }
        //页数加1
        if (entity.list.count > 0) {
            _pageIndex++;
        }
    }
    [super succeedCallbackWithResponse:responseEntity];
}

/*
 - (void)failedCallbackWithResponse:(KSResponseEntity *)responseEntity
 {
 NSString *tradeId = responseEntity.tradeId;
 //列表
 if ([tradeId isEqualToString:KJDProvideListTradeId])
 {
 //实体结果数据
 id body = responseEntity.body;
 
 
 }
 [super failedCallbackWithResponse:responseEntity];
 }
 
 - (void)sysErrorCallbackWithResponse:(KSResponseEntity *)responseEntity
 {
 NSString *tradeId = responseEntity.tradeId;
 //列表
 if ([tradeId isEqualToString:KJDProvideListTradeId])
 {
 //实体结果数据
 id body = responseEntity.body;
 
 
 }
 [super sysErrorCallbackWithResponse:responseEntity];
 }
 */
@end
