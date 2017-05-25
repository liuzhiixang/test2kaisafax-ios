//
//  KSNewAssetsVC.h
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"
#import "KSNewAssetsEntity.h"

//资产明细
@interface KSNewAssetsVC : KSNVBackVC

@property (nonatomic,assign) KSWebSourceType type;

//用户资产明细
@property (strong, nonatomic) KSNewAssetsEntity *userAssets;

@end
