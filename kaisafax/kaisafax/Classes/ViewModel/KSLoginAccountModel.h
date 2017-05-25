//
//  KSLoginAccountModel.h
//  kaisafax
//
//  Created by semny on 16/7/20.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @author semny
 *
 *  个人中心顶部视图的视图数据Model
 */
@interface KSLoginAccountModel : NSObject

//顶部栏名称
@property(nonatomic, copy) NSString *titleName;
//总的金额
@property(nonatomic, assign) CGFloat totalCapital;
//冻结资金
@property(nonatomic, assign) CGFloat frozenCapital;
//余额
@property(nonatomic, assign) CGFloat balance;
//待收本息
@property(nonatomic, assign) CGFloat principalAndInterest;

@end
