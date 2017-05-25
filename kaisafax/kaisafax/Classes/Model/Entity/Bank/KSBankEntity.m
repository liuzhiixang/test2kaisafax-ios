//
//  KSBankEntity.m
//  kaisafax
//
//  Created by semny on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBankEntity.h"

@interface KSBankEntity()

//格式化后的金额数据
@property (nonatomic, strong) NSString *detailStr;

@end

@implementation KSBankEntity

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"bankId" : @"id"};
}

- (NSString *)getDetailText
{
    return [NSString stringWithFormat:@"单笔限额%@, 单日限额%@", [self shortTextFromAmount:_amount], [self shortTextFromAmount:_total]];
}

- (NSString *)shortTextFromAmount:(NSInteger)amount
{
    if (amount > 10000) {
        return [NSString stringWithFormat:@"%ld万", amount / 10000];
    }
    return [NSString stringWithFormat:@"%ld", amount];
}

@end
