//
//  KSBankCardBL.m
//  kaisafax
//
//  Created by semny on 16/9/21.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBankCardBL.h"

@implementation KSBankCardBL
/**
 *  @author semny
 *
 *  解绑银行卡
 *
 *  @return 请求序列号
 */
- (NSInteger)doUnbindBankCard:(long long)cardId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(cardId) forKey:kBankCardIdKey];
    NSString *tradeId = KUnbindBankAccountTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

/**
 *  @author semny
 *
 *  获取当前用户的银行卡信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserBankCards
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetBankCardsTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

//同步银行卡信息(由于服务端暂时无法自动同步汇付的银行信息)
- (NSInteger)doSyncBankCard
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KSyncBankCardTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

#pragma mark - 数据解析相关
/**
 *  解析，我的银行卡列表特殊处理（银行卡，同步银行卡）
 */
- (id)parserResponse:(NSDictionary *)dict withTradeId:(NSString *)tradeId
{
    id returnObj = nil;
    //用户银行卡列表的解析处理,返回的body中由于包含bankList
    if ([tradeId isEqualToString:KGetBankCardsTradeId] || [tradeId isEqualToString:KSyncBankCardTradeId])
    {
        //model数据
        NSDictionary *model = [dict objectForKey:KResponseBodyKey];
        if ([model isKindOfClass:[NSDictionary class]])
        {
            NSArray *array = [model objectForKey:kBankCardListKey];
            if ([array isKindOfClass:[NSArray class]])
            {
                Class classObj = [[KSAPIDataMgr sharedInstance] returnedClassBy:tradeId];
                returnObj = [NSArray yy_modelArrayWithClass:classObj json:array];
            }
        }
    }
    else
    {
        returnObj = [super parserResponse:dict withTradeId:tradeId];
    }
    return returnObj;
}

@end
