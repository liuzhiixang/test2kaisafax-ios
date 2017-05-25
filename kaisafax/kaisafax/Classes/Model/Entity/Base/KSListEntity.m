//
//  KSListEntity.m
//  kaisafax
//
//  Created by semny on 16/9/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSListEntity.h"

@interface KSListEntity()

//@property (nonatomic, copy) NSMutableArray *tempDataList;

@end

@implementation KSListEntity

/**
 *  @author semny
 *
 *  增加新数据(必须在设置isRefresh之后)
 *
 *  @param array 新数据
 */
- (void)appendDataList:(NSArray *)array
{
    if (_isRefresh)
    {
        //如果是刷新
        if (array && array.count > 0)
        {
            _dataList = [NSMutableArray arrayWithArray:array];
        }
        else
        {
            [_dataList removeAllObjects];
            _dataList = nil;
        }
    }
    else
    {
        if (!_dataList || _dataList.count <= 0)
        {
            _dataList = [NSMutableArray array];
        }
        [_dataList addObjectsFromArray:array];
    }
}

@end
